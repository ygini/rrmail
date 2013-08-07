//
//  RRMController.m
//  rrmail
//
//  Created by Yoann Gini on 07/08/13.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "RRMController.h"

#import "RRMOperationPOP3.h"
#import "RRMConstants.h"

#import <libkern/OSAtomic.h>

@interface RRMController ()
{
	NSString *_configurationFilePath;
	
	OSSpinLock _configurationLock;
	OSSpinLock _operationQueueLock;
	NSDictionary *_configuration;
	
	NSMutableDictionary *_operationQueues;
}

@end

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
            else
            {
                OperationClass = nil;
            }
			
			if (OperationClass) {
				serverAddress = [serverConfig objectForKey:kRRMSourceServerAddressKey];
				
				operationQueue = [_operationQueues objectForKey:serverAddress];
				if (!operationQueue) {
					maxConcurrentOperations = [serverConfig objectForKey:kRRMSourceServerMaxConcurrentOperationsKey];
					if (!maxConcurrentOperations) {
						maxConcurrentOperations = [NSNumber numberWithInt:10];
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
											nil];
				
				for (NSDictionary *userSettings in [serverConfig objectForKey:kRRMSourceServerAccountListKey]) {
					operationMail = [(id<RRMOperationMail>)[OperationClass alloc] initWithServerConfiguration:serverConfigForOperation
																							andUserSettings:userSettings];
					
					[operationQueue addOperation:operationMail];
				}
			}
			else
			{
				// ... Server type unsupported ...
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
	return 0;
}

-(NSUInteger)operationQueueCount
{
	return 0;
}

#pragma mark Internal

-(void)readConfigurationfFile:(void(^)(NSError *error))completionHandler
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		OSSpinLockLock(&_configurationLock);
		NSDictionary *configuration = [[NSDictionary alloc] initWithContentsOfFile:_configurationFilePath];
		
		if (!configuration) {
			NSError *error = [NSError errorWithDomain:(NSString*)kRRMErrorDomain
												 code:kRRMErrorCodeUnableToReadConfigFile
											 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
													   _configurationFilePath, kRRMErrorFilePathKey,
													   nil]];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				completionHandler(error);
			});
			
			return;
		}
		
		[_configuration release], _configuration = nil;
		_configuration = [configuration copy];
		// ... check configuration if needed? ...
		
		[configuration release];
		OSSpinLockUnlock(&_configurationLock);
		
		// Configuration read with success, call the completion handler without error to continue operations.
		dispatch_async(dispatch_get_main_queue(), ^{
			completionHandler(nil);
		});
	});
}

@end