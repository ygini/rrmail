//
//  RRMController.m
//  rrmail
//
//  Created by Yoann Gini on 07/08/13.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "RRMController.h"
#import "RRMController+CheckConfiguration.h"

#import "RRMOperationPOP3.h"
#import "RRMOperationIMAP.h"
#import "RRMConstants.h"

#import <libkern/OSAtomic.h>

#import "RRMController_Internal.h"

#import "CocoaSyslog.h"


@implementation RRMController

#pragma mark Object Lifecycle

+(RRMController*)sharedInstance
{
	static RRMController* sharedInstanceRRMController = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstanceRRMController = [[RRMController alloc] initWithConfigurationFilePath:kRRMControllerDefaultConfigFile];
	});
	
	return sharedInstanceRRMController;
}

-(RRMController*)initWithConfigurationFilePath:(const NSString*)configurationFilePath
{
    self = [super init];
    if (self) {
        _configurationFilePath = [configurationFilePath copy];
		_configurationLock = OS_SPINLOCK_INIT;;
		_operationQueueLock = OS_SPINLOCK_INIT;
		_operationQueues = [NSMutableDictionary new];
	}
    return self;
}

- (void)dealloc
{
    [_configurationFilePath release], _configurationFilePath = nil;
	[_operationQueues release], _operationQueues = nil;
    [super dealloc];
}

#pragma mark API

-(void)startOperations
{
	OSSpinLockLock(&_configurationLock);
	OSSpinLockLock(&_operationQueueLock);
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{		
		NSArray *sourceServerList = [_configuration objectForKey:kRRMServerListKey];
		
		NSString *serverType = nil;
		NSString *serverAddress = nil;
		NSOperationQueue *operationQueue = nil;
		NSNumber *maxConcurrentOperations = nil;
		NSDictionary *serverConfigForOperation = nil;
		Class OperationClass = nil;
		id<RRMOperationMail> operationMail = nil;
		
		for (NSDictionary *serverConfig in sourceServerList) {
			serverType = [serverConfig objectForKey:kRRMSourceServerTypeKey];
			
			if ([serverType isEqualToString:(NSString*)kRRMSourceServerTypePOP3Value]) {
				OperationClass = [RRMOperationPOP3 class];
			}
			else if ([serverType isEqualToString:(NSString*)kRRMSourceServerTypeIMAPValue])
			{
				OperationClass = [RRMOperationIMAP class];
			}
            else
            {
                OperationClass = nil;
            }
			
			if (OperationClass) {
				serverAddress = [serverConfig objectForKey:kRRMSourceServerAddressKey];
				[[CocoaSyslog sharedInstance] messageLevel5Notice:@"Load operations for server %@", serverAddress];
				
				operationQueue = [_operationQueues objectForKey:serverAddress];
				if (!operationQueue) {
					maxConcurrentOperations = [serverConfig objectForKey:kRRMSourceServerMaxConcurrentOperationsKey];
					if (maxConcurrentOperations.intValue == 0) {
						maxConcurrentOperations = [NSNumber numberWithInt:NSOperationQueueDefaultMaxConcurrentOperationCount];
					}
					operationQueue = [[NSOperationQueue alloc] init];
					[operationQueue setMaxConcurrentOperationCount:[maxConcurrentOperations integerValue]];
					[_operationQueues setObject:operationQueue forKey:serverAddress];
					[operationQueue release];
				}
				
				serverConfigForOperation = [NSDictionary dictionaryWithObjectsAndKeys:
											[serverConfig objectForKey:kRRMSourceServerAddressKey], kRRMSourceServerAddressKey,
											[serverConfig objectForKey:kRRMSourceServerTCPPortKey], kRRMSourceServerTCPPortKey,
											[serverConfig objectForKey:kRRMSourceServerRequireSSLKey], kRRMSourceServerRequireSSLKey,
											[_configuration objectForKey:kRRMSpecialDoNotDelete], kRRMSpecialDoNotDelete,
											nil];
				
				for (NSDictionary *userSettings in [serverConfig objectForKey:kRRMSourceServerAccountListKey]) {
					[[CocoaSyslog sharedInstance] messageLevel6Info:@"Load operation for user %@ on server %@", [userSettings objectForKey:kRRMSourceServerLoginKey], serverAddress];
					operationMail = [(id<RRMOperationMail>)[OperationClass alloc] initWithServerConfiguration:serverConfigForOperation
																							andUserSettings:userSettings];
					
					[operationQueue addOperation:operationMail];
					[operationMail release];
				}
			}
			else
			{
				[[CocoaSyslog sharedInstance] messageLevel3Error:@"Unsupported protocol \"%@\" for server %@.",
				 serverType,
				 [serverConfig objectForKey:kRRMSourceServerAddressKey]];
			}
		}
		
		OSSpinLockUnlock(&_configurationLock);
		OSSpinLockUnlock(&_operationQueueLock);

	});
}
				   
-(void)startOperationsAndWait
{
	[self startOperations];
	[self waitEndOfAllOperations];
}

-(void)waitEndOfAllOperations
{
	OSSpinLockLock(&_operationQueueLock);
	
	for (NSOperationQueue *queue in [_operationQueues allValues]) {
		[queue waitUntilAllOperationsAreFinished];
	}
	
	OSSpinLockUnlock(&_operationQueueLock);
}

-(NSUInteger)totalOperationCount
{
	NSUInteger count = 0;
	
	OSSpinLockLock(&_operationQueueLock);
	for (NSOperationQueue *queue in [_operationQueues allValues]) {
		count += [queue operationCount];
	}
	OSSpinLockUnlock(&_operationQueueLock);

	return count;
}

-(NSUInteger)operationQueueCount
{
	return [_operationQueues count];
}

-(void)readConfigurationfFile:(void(^)(NSError *error))completionHandler
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		NSError *err = [self readConfigurationfFile];
		dispatch_async(dispatch_get_main_queue(), ^{
			completionHandler(err);
		});
	});
}


-(NSError*)readConfigurationfFile
{
	OSSpinLockLock(&_configurationLock);
 
    NSError *error = nil;
	NSDictionary *configuration = [[NSDictionary alloc] initWithContentsOfFile:_configurationFilePath];
	
	if (!configuration) {
		error = [NSError errorWithDomain:(NSString*)kRRMErrorDomain
											 code:kRRMErrorCodeUnableToReadConfigFile
										 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
												   _configurationFilePath, kRRMErrorFilePathKey,
												   nil]];
	}
    else
    {
        [_configuration release], _configuration = nil;
        _configuration = [configuration copy];
        
        error = [self checkConfigurationAndAddDefaults];
        
        [configuration release];
    }

	OSSpinLockUnlock(&_configurationLock);

	return error;
}

@end
