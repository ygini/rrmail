//
//  RRMailCTL.m
//  RRMailPrefPane
//
//  Created by Yoann Gini on 13/10/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import "RRMailCTL.h"

#import "NSString+keyPathComponents.h"

@interface RRMailCTL ()
-(void)silentSetConfiguration:(NSMutableDictionary *)configuration;
- (NSData*)runCommandWithArguments:(NSArray*)arguments andDataForSTDIN:(NSData*)stdinData waitForAnswer:(BOOL)waitForAnswer;
- (NSString*)rrmailctlPath;
- (NSString*)rrmailPath;
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
		NSData *rawConfig = [self runCommandWithArguments:@[@"--rrmailConfig"] andDataForSTDIN:nil waitForAnswer:YES];
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
	[self silentSetConfiguration:configuration];
	[self didChangeValueForKey:@"configuration"];
}

-(void)silentSetConfiguration:(NSMutableDictionary *)configuration
{
	if (self.authorization) {
		NSData *rawConfig = [NSPropertyListSerialization dataFromPropertyList:configuration
																	   format:NSPropertyListXMLFormat_v1_0
															 errorDescription:nil];
		[self runCommandWithArguments:@[@"--updateRrmailConfig"] andDataForSTDIN:rawConfig waitForAnswer:NO];
	}
}

- (void)loadService
{
	[self willChangeValueForKey:@"serviceIsLoaded"];
	[self runCommandWithArguments:@[@"--rrmailFullPath", [self rrmailPath], @"-l"] andDataForSTDIN:nil waitForAnswer:NO];
	[self didChangeValueForKey:@"serviceIsLoaded"];
}

- (void)unloadService
{
	[self willChangeValueForKey:@"serviceIsLoaded"];
	[self runCommandWithArguments:@[@"-u"] andDataForSTDIN:nil waitForAnswer:NO];
	[self didChangeValueForKey:@"serviceIsLoaded"];
}

- (NSNumber *)serviceIsLoaded
{
	NSData *rawState = [self runCommandWithArguments:@[@"-s"] andDataForSTDIN:nil waitForAnswer:YES];
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
	NSData *rawState = [self runCommandWithArguments:@[@"-i"] andDataForSTDIN:nil waitForAnswer:YES];
	NSString *startInterval = [NSString stringWithCString:[rawState bytes] encoding:NSUTF8StringEncoding];
	return startInterval;
}

-(void)setStartInterval:(NSString *)startInterval
{
	[self runCommandWithArguments:@[@"-I", startInterval] andDataForSTDIN:nil waitForAnswer:NO];
}

#pragma mark - SPI

- (NSData*)runCommandWithArguments:(NSArray*)arguments andDataForSTDIN:(NSData*)stdinData waitForAnswer:(BOOL)waitForAnswer
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
	
	processError = AuthorizationExecuteWithPrivileges([self.authorization authorizationRef], [[self rrmailctlPath] UTF8String], kAuthorizationFlagDefaults, (char *const *)argv, &commandSTDInAndOut);
    free(argv);
	
	if (processError != errAuthorizationSuccess) {
		NSLog(@"Error returned by AuthorizationExecuteWithPrivileges: %d", processError);
	}
	else if (stdinData || waitForAnswer) {
		NSFileHandle * twoWayFileHandle = [[NSFileHandle alloc] initWithFileDescriptor:fileno(commandSTDInAndOut) closeOnDealloc:YES];
		
		if (stdinData) {
			[twoWayFileHandle writeData:stdinData];
		}
		
		if (waitForAnswer) {
			stdoutData = [twoWayFileHandle readDataToEndOfFile];
		}
		
		twoWayFileHandle = nil;
	}
	
	return stdoutData;
}

- (NSString*)rrmailctlPath
{
	return [[NSBundle bundleForClass:[self class]] pathForAuxiliaryExecutable:@"rrmailctl"];
}

- (NSString*)rrmailPath
{
	return [[NSBundle bundleForClass:[self class]] pathForAuxiliaryExecutable:@"rrmail"];
}

-(void)setValue:(id)value forKeyPath:(NSString *)keyPath
{
	NSMutableArray *keyPathComponents = [[keyPath keyPathComponents] mutableCopy];
	if ([keyPathComponents count] > 1) {
		if ([@"configuration" isEqualToString:[keyPathComponents objectAtIndex:0]]) {
			[keyPathComponents removeObjectAtIndex:0];
			NSString *adaptedKeyPath = [NSString stringWithKeyPathComponents:keyPathComponents];
			NSMutableDictionary *configuration = self.configuration;
			[configuration setValue:value forKeyPath:adaptedKeyPath];
			[self silentSetConfiguration:configuration];
		}
		else {
			[super setValue:value forKeyPath:keyPath];
		}
	}
	else {
		[super setValue:value forKeyPath:keyPath];
	}
}

@end
