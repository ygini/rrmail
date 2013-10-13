//
//  RRMailCTL.m
//  RRMailPrefPane
//
//  Created by Yoann Gini on 13/10/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import "RRMailCTL.h"

@interface RRMailCTL ()
- (NSData*)runCommandWithArguments:(NSArray*)arguments andDataForSTDIN:(NSData*)stdinData;
- (NSString*)commandLinePath;
@end

@implementation RRMailCTL

#pragma mark - API

+ (instancetype)sharedInstance {
    static RRMailCTL* RRMailCTLsharedInstance = nil;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		RRMailCTLsharedInstance = [RRMailCTL new];
	});
    return RRMailCTLsharedInstance;
}

-(NSMutableDictionary *)configuration
{
	if (self.authorization) {
		NSData *rawConfig = [self runCommandWithArguments:@[@"--rrmailConfig"] andDataForSTDIN:nil];
		return [NSPropertyListSerialization propertyListFromData:rawConfig
												mutabilityOption:NSPropertyListMutableContainersAndLeaves
														  format:NULL
												errorDescription:nil];
	}
	
	return nil;
}

-(void)setConfiguration:(NSMutableDictionary *)configuration
{
	[self willChangeValueForKey:@"configuration"];
	if (self.authorization) {
		NSData *rawConfig = [NSPropertyListSerialization dataFromPropertyList:configuration
																	   format:NSPropertyListXMLFormat_v1_0
															 errorDescription:nil];
		[self runCommandWithArguments:@[@"--updateRrmailConfig"] andDataForSTDIN:rawConfig];
	}
	[self didChangeValueForKey:@"configuration"];
}

- (void)loadService
{
	[self willChangeValueForKey:@"serviceIsLoaded"];
	[self runCommandWithArguments:@[@"-l"] andDataForSTDIN:nil];
	[self didChangeValueForKey:@"serviceIsLoaded"];
}

- (void)unloadService
{
	[self willChangeValueForKey:@"serviceIsLoaded"];
	[self runCommandWithArguments:@[@"-u"] andDataForSTDIN:nil];
	[self didChangeValueForKey:@"serviceIsLoaded"];
}

- (NSNumber *)serviceIsLoaded
{
	NSData *rawState = [self runCommandWithArguments:@[@"-s"] andDataForSTDIN:nil];
	NSString *state = [NSString stringWithCString:[rawState bytes] encoding:NSUTF8StringEncoding];
	return [NSNumber numberWithBool:[@"online" isEqualToString:state]];
}

-(void)setServiceIsLoaded:(NSNumber *)wantToLoadService
{
	if ([wantToLoadService boolValue]) {
		[self loadService];
	} else {
		[self unloadService];
	}
}

- (NSString *)startInterval
{
	NSData *rawState = [self runCommandWithArguments:@[@"-i"] andDataForSTDIN:nil];
	NSString *startInterval = [NSString stringWithCString:[rawState bytes] encoding:NSUTF8StringEncoding];
	return startInterval;
}

-(void)setStartInterval:(NSString *)startInterval
{
	[self runCommandWithArguments:@[@"-I", startInterval] andDataForSTDIN:nil];
}

#pragma mark - SPI

- (NSData*)runCommandWithArguments:(NSArray*)arguments andDataForSTDIN:(NSData*)stdinData
{
	FILE *commandSTDInAndOut = 0;
	NSData *stdoutData = nil;
	OSErr processError =  errAuthorizationSuccess;
	
    const char **argv = (const char **)malloc(sizeof(char *) * [arguments count] + 1);
    int argvIndex = 0;
    for (NSString *string in arguments) {
        argv[argvIndex] = [string UTF8String];
        argvIndex++;
    }
    argv[argvIndex] = nil;
	
	processError = AuthorizationExecuteWithPrivileges([self.authorization authorizationRef], [[self commandLinePath] UTF8String], kAuthorizationFlagDefaults, (char *const *)argv, &commandSTDInAndOut);
    free(argv);
	
	if (processError != errAuthorizationSuccess) {
		NSLog(@"Error returned by AuthorizationExecuteWithPrivileges: %d", processError);
	}
	else {
		NSFileHandle * twoWayFileHandle = [[NSFileHandle alloc] initWithFileDescriptor:fileno(commandSTDInAndOut) closeOnDealloc:YES];
		
		if (stdinData) {
			[twoWayFileHandle writeData:stdinData];
		}
		
		stdoutData = [twoWayFileHandle readDataToEndOfFile];
		
		twoWayFileHandle = nil;
	}
	
	return stdoutData;
}

- (NSString*)commandLinePath
{
	return [[NSBundle bundleForClass:[self class]] pathForAuxiliaryExecutable:@"rrmailctl"];
}

@end
