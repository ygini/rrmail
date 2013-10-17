//
//  RRMailConfigController.m
//  ConfigureRRMail
//
//  Created by Florian BONNIEC on 9/3/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import "RRMailConfigController.h"
#import "RRMConstants.h"
#import <ServiceManagement/ServiceManagement.h>
#import <Security/Security.h>

@interface RRMailConfigController ()
{
	NSMutableDictionary *_launchInfo;
}

@property (assign, nonatomic) BOOL startInterval;
@property (assign, nonatomic) BOOL rrmailConfig;
@property (retain, nonatomic) NSNumber *updateStartInterval;
@property (assign, nonatomic) BOOL updateRrmailConfig;
@property (assign, nonatomic) BOOL load;
@property (assign, nonatomic) BOOL unload;
@property (assign, nonatomic) BOOL status;
@property (assign, nonatomic) BOOL version;
@property (assign, nonatomic) BOOL help;
@property (assign, nonatomic) BOOL doNotDelete;
@property (assign, nonatomic) BOOL undoDoNotDelete;
@property (retain, nonatomic) NSString *rrmailFullPath;
@end

#ifdef DEBUG
#define		TARGET_SM_DOMAIN		kSMDomainSystemLaunchd
#else
#define		TARGET_SM_DOMAIN		kSMDomainUserLaunchd
#endif


@implementation RRMailConfigController

#pragma mark - Object lifecyle

- (id)init
{
    self = [super init];
    if (self) {
		NSMutableDictionary *jobDict = [NSMutableDictionary dictionaryWithContentsOfURL:[self launchdPlistURL]];
		if (jobDict) {
			_launchInfo = [jobDict mutableCopy];
		}
		else {
			_launchInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
					 kRRMLaunchdJobLabel, @"Label",
					 @[kRRMServiceFullPath], @"ProgramArguments",
					 [NSNumber numberWithInt:180], @"StartInterval",
					 @"_postfix", @"UserName",
					 @"_postfix", @"GroupName",
					 nil];
			[_launchInfo writeToURL:[self launchdPlistURL] atomically:YES];
		}
	}
    return self;
}

- (void)dealloc
{
    [_launchInfo release], _launchInfo = nil;
    [_updateStartInterval release], _updateStartInterval = nil;
	[super dealloc];
}

#pragma mark - Command Line Management

- (void) application: (DDCliApplication *) app
    willParseOptions: (DDGetoptLongParser *) optionsParser;
{
    DDGetoptOption optionTable[] =
    {
        // Long						Short   Argument options
        {@"startInterval",			'i',    DDGetoptNoArgument},
        {@"updateStartInterval",	'I',    DDGetoptRequiredArgument},
		{@"rrmailConfig",			0,		DDGetoptNoArgument},
        {@"updateRrmailConfig",		0,		DDGetoptNoArgument},
        {@"load",					'l',    DDGetoptNoArgument},
        {@"unload",					'u',    DDGetoptNoArgument},
        {@"status",					's',    DDGetoptNoArgument},
        {@"version",				'v',    DDGetoptNoArgument},
        {@"help",					'h',    DDGetoptNoArgument},
        {@"rrmailFullPath",			0,		DDGetoptRequiredArgument},
		{@"doNotDelete",			'd',	DDGetoptNoArgument},
		{@"undoDoNotDelete",		'D',	DDGetoptNoArgument},
        {nil,						0,      0},
    };
    [optionsParser addOptionsFromTable: optionTable];
}

- (void) printUsage: (FILE *) stream;
{
    ddfprintf(stream, @"%@: Usage [OPTIONS] <argument> [...]\n", DDCliApp);
}

- (void) printHelp;
{
    [self printUsage:stdout];
	[self printVersion];
    printf("\n"
           "  -i, --startInterval						Get the start interval in seconds\n"
           "  -i, --startInterval						Get the start interval in seconds\n"
           "  -I, --updateStartInterval <time>				Update the start interval in seconds\n"
           "  -l, --load							Load the launchd service\n"
           "  -u, --unload							Unload the launchd service\n"
           "  -v, --version							Display version and exit\n"
           "  -h, --help							Display this help and exit\n"
           "\n");
}

- (void) printVersion;
{
    ddprintf(@"%@ version %s\n", DDCliApp, CURRENT_MARKETING_VERSION);
}

- (BOOL)argumentCheckup
{
	BOOL returnValue = YES;
	
	if (self.doNotDelete && self.undoDoNotDelete) {
		printf("Unlike Schrödinger's cat, your e-mail can't be deleted and not deleted in the same time\n");
		returnValue = NO;
	}
	
	if (self.load && self.unload) {
		printf("Well… Do you want to load or unload the service?!\n");
		returnValue = NO;
	}
	
	if (self.startInterval && self.updateStartInterval) {
		printf("Impossible to read and set the start internval in the same time…\n");
		returnValue = NO;
	}
	
	if (self.rrmailConfig && self.updateRrmailConfig) {
		printf("Impossible to read and set the configuration in the same time…\n");
		returnValue = NO;
	}
	
	return returnValue;
}

- (int) application: (DDCliApplication *) app
   runWithArguments: (NSArray *) arguments;
{
	BOOL printHelp = YES;
	
	if (![self argumentCheckup]) {
		printf("Impossible to understand logic behind the arguments list\n");
		return EXIT_FAILURE;
	}
	
	if (self.help) {
		[self printHelp];
		return EXIT_SUCCESS;
	}
	
	if (self.version) {
		[self printVersion];
		return EXIT_SUCCESS;
	}
	
	if (self.status) {
		[self printStatus];
		return EXIT_SUCCESS;
	}
	
	if (self.doNotDelete) {
		[self deletePrevention:YES];
		printHelp = NO;
	}
	else if (self.undoDoNotDelete) {
		[self deletePrevention:NO];
		printHelp = NO;
	}
	
	if (self.rrmailFullPath) {
		[self setRrmailPath:self.rrmailFullPath];
	}
	
	if (self.startInterval) {
		printf("%li\n", (long)[self currentIntervalTime]);
		printHelp = NO;
	}
	else if (self.updateStartInterval) {
		[self setCurrentIntervalTime:self.updateStartInterval.integerValue];
		printHelp = NO;
	}
	
	if (self.rrmailConfig) {
		[self sendRawConfigFileToSTDOUT];
		printHelp = NO;
	}
	else if (self.updateRrmailConfig) {
		[self writeRawConfigFileFromSTDIN];
		printHelp = NO;
	}
	
	if (self.load) {
		[self loadLaunchService];
		printHelp = NO;
	}
	else if (self.unload) {
		[self unloadLaunchService];
		printHelp = NO;
	}
	
	if (printHelp) [self printHelp];
	
    return EXIT_SUCCESS;
}

#pragma mark - Configuration Management

- (NSURL*)launchdFolderURL
{
	static NSURL *libraryURL= nil;
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		NSSearchPathDomainMask domainMask = kSMDomainSystemLaunchd == TARGET_SM_DOMAIN ? NSLocalDomainMask : NSUserDomainMask;
		NSError *err = nil;
		
		libraryURL = [[[[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory
																   inDomain:domainMask
														  appropriateForURL:nil
																	 create:NO
																	  error:&err]
					   URLByAppendingPathComponent:@"LaunchDaemons"]
					  retain];
    });

	return libraryURL;
}

- (NSURL*)launchdPlistURL
{
	static NSURL *launchdPlistURL= nil;
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		launchdPlistURL = [[[[self launchdFolderURL]
						 URLByAppendingPathComponent:(NSString*)kRRMLaunchdJobLabel]
						URLByAppendingPathExtension:@"plist"]
		retain];
    });
	
	return launchdPlistURL;

}

- (NSInteger)currentIntervalTime
{
	return [[_launchInfo objectForKey:@"StartInterval"] integerValue];
}

- (void)setCurrentIntervalTime:(NSInteger)interval
{
	BOOL manageLoadState = [self serviceIsLoaded];
	if (manageLoadState) {
		[self unloadLaunchService];
	}
	

	[_launchInfo setObject:[NSNumber numberWithInteger:interval] forKey:@"StartInterval"];
	
	[_launchInfo writeToURL:[self launchdPlistURL] atomically:YES];
	
	if (manageLoadState) {
		[self loadLaunchService];
	}
}

- (void)setRrmailPath:(NSString*)path
{
	BOOL manageLoadState = [self serviceIsLoaded];
	if (manageLoadState) {
		[self unloadLaunchService];
	}
	
	[_launchInfo setObject:@[self.rrmailFullPath] forKey:@"ProgramArguments"];
	
	[_launchInfo writeToURL:[self launchdPlistURL] atomically:YES];
	
	if (manageLoadState) {
		[self loadLaunchService];
	}
}

- (void)deletePrevention:(BOOL)flag
{
	NSMutableDictionary *configuration = [NSMutableDictionary dictionaryWithContentsOfFile:(NSString*)kRRMServiceConfigPath];
	[configuration setObject:[NSNumber numberWithBool:flag] forKey:kRRMSpecialDoNotDelete];
	[configuration writeToFile:(NSString*)kRRMServiceConfigPath atomically:YES];
	NSError *err = nil;
	[[NSFileManager defaultManager]setAttributes:@{NSFilePosixPermissions: @0600}
									ofItemAtPath:(NSString*)kRRMServiceConfigPath
										   error:&err];
}

- (void)unloadLaunchService
{
	[NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" arguments:@[@"unload", [[self launchdPlistURL] path]]];
}

- (void)loadLaunchService
{
	[NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" arguments:@[@"load", [[self launchdPlistURL] path]]];
}

- (BOOL)serviceIsLoaded
{
	NSDictionary *jobDict = (NSDictionary *)SMJobCopyDictionary(TARGET_SM_DOMAIN, (CFStringRef)kRRMLaunchdJobLabel);
	if (jobDict) {
		[jobDict release];
		return YES;
	}
	
	return NO;
}

- (void)sendRawConfigFileToSTDOUT
{
	NSError *error = nil;
	[(NSFileHandle*)[NSFileHandle fileHandleWithStandardOutput] writeData:[[NSString stringWithContentsOfFile:(NSString*)kRRMServiceConfigPath
																					  encoding:NSUTF8StringEncoding
																						 error:&error]
															dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)writeRawConfigFileFromSTDIN
{
	[[[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile] writeToFile:(NSString*)kRRMServiceConfigPath atomically:YES];
	NSError *err = nil;
	[[NSFileManager defaultManager]setAttributes:@{NSFilePosixPermissions: @0600}
									ofItemAtPath:(NSString*)kRRMServiceConfigPath
										   error:&err];
}

-(void)printStatus
{
	if ([self serviceIsLoaded]) {
		printf("online\n");
	}
	else {
		printf("offline\n");
	}
}

@end
