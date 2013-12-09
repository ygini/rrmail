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
{
	BOOL _isLoadingConfigurationFromDisk;
}
- (NSData*)runCommandWithArguments:(NSArray*)arguments andDataForSTDIN:(NSData*)stdinData waitForAnswer:(BOOL)waitForAnswer;
- (NSString*)rrmailctlPath;
- (NSString*)rrmailPath;
- (void)loadConfiguration;
- (void)saveConfigurationOnDisk;
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

- (id)init
{
    self = [super init];
    if (self) {
		_isLoadingConfigurationFromDisk = NO;
        [self addObserver:self forKeyPath:@"authorization" options:0 context:NULL];
        [self addObserver:self forKeyPath:@"configuration" options:0 context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"authorization"];
    [self removeObserver:self forKeyPath:@"configuration"];
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
	NSString *state = [NSString stringWithCString:[rawState bytes] encoding:NSASCIIStringEncoding];
	if ([@"onl" isEqualToString:[state substringToIndex:3]]) {
		NSLog(@"OK");
	}
	else{
		NSLog(@"Pas OK");
	}
	return [NSNumber numberWithBool:[@"onl" isEqualToString:[state substringToIndex:3]]];
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
	return [[NSBundle bundleForClass:[self class]] pathForResource:@"rrmailctl" ofType:@""];
}

- (NSString*)rrmailPath
{
	return [[NSBundle bundleForClass:[self class]] pathForResource:@"rrmail" ofType:@""];
}

- (void)loadConfiguration
{
	_isLoadingConfigurationFromDisk = YES;
	NSData *rawConfig = [self runCommandWithArguments:@[@"--rrmailConfig"] andDataForSTDIN:nil waitForAnswer:YES];
	self.configuration = [NSPropertyListSerialization propertyListFromData:rawConfig
														  mutabilityOption:NSPropertyListMutableContainersAndLeaves
																	format:NULL
														  errorDescription:nil];
	
	if (0 == [self.configuration count]) {
		self.configuration = [NSMutableDictionary dictionaryWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"SampleConf" ofType:@"plist"]];
	}
	
	_isLoadingConfigurationFromDisk = NO;
}

- (void)saveConfigurationOnDisk
{
	if (self.authorization) {
		NSData *rawConfig = [NSPropertyListSerialization dataFromPropertyList:self.configuration
																	   format:NSPropertyListXMLFormat_v1_0
															 errorDescription:nil];
		[self runCommandWithArguments:@[@"--updateRrmailConfig"] andDataForSTDIN:rawConfig waitForAnswer:NO];
	}
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (self == object && [@"authorization" isEqualToString:keyPath]) {
		if (self.authorization.authorizationRef) {
			[self loadConfiguration];
		}
		else {
			self.configuration = nil;
		}
	}
	else if (self == object && [@"configuration" isEqualToString:keyPath] && !_isLoadingConfigurationFromDisk){
		[self saveConfigurationOnDisk];
	}
}

@end
