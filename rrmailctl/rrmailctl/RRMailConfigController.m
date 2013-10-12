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
	NSMutableDictionary *_info;
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
			_info = [jobDict mutableCopy];
		}
		else {
			_info = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
					 kRRMLaunchdJobLabel, @"Label",
					 @[kRRMServiceFullPath], @"ProgramArguments",
					 [NSNumber numberWithInt:180], @"StartInterval",
					 @"_postfix", @"UserName",
					 @"_postfix", @"GroupName",
					 nil];
			[_info writeToURL:[self launchdPlistURL] atomically:YES];
		}
    }
    return self;
}

- (void)dealloc
{
    [_info release], _info = nil;
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
	return [[_info objectForKey:@"StartInterval"] integerValue];
}

- (void)setCurrentIntervalTime:(NSInteger)interval
{
	BOOL manageLoadState = [self serviceIsLoaded];
	if (manageLoadState) {
		[self unloadLaunchService];
	}
	

	[_info setObject:[NSNumber numberWithInteger:interval] forKey:@"StartInterval"];
	
	[_info writeToURL:[self launchdPlistURL] atomically:YES];
	
	if (manageLoadState) {
		[self loadLaunchService];
	}
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






+(RRMailConfigController *)sharedInstance
{

    static RRMailConfigController* sharedInstanceRRMConfigController = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstanceRRMConfigController = [[RRMailConfigController alloc] init];
	});
	
	return sharedInstanceRRMConfigController;
}

-(void) setCheckMailIntervalTime:(int)timeInterval
{
    BOOL isSchedulerLoaded = [self checkIfSchedulerIsLoading];
    
    if (isSchedulerLoaded == YES) {
        [self loadUnloadSchedulerWithInit:0];
    }
    
    NSError *error = nil;
    NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES)objectAtIndex:0];
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/LaunchDaemons", stringPath]  error:&error];
    
    if ([filePathsArray indexOfObject:@"com.rrmail.scheduler.plist"] != NSNotFound) {
        
        
        NSString *path = [NSString stringWithFormat:@"%@/LaunchDaemons/com.rrmail.scheduler.plist", stringPath];
        NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
     
        [savedStock setObject:[NSNumber numberWithInt:timeInterval] forKey:@"StartInterval"];
        
        [savedStock writeToFile:path atomically:YES];
    }
    
    if (isSchedulerLoaded == YES)
    {
        [self loadUnloadSchedulerWithInit:1];
    }
}

-(void)updateRRMailConfig:(NSDictionary *)rrmailConfig
{
    NSMutableDictionary * _rrmailConfig = [NSMutableDictionary dictionaryWithDictionary:rrmailConfig];
    
    NSString * numberLogLevel = [_rrmailConfig valueForKey:@"appLogLevel"];
    [_rrmailConfig setObject:[NSNumber numberWithInt:numberLogLevel.intValue] forKey:@"appLogLevel"];
    
    NSArray * arrayServerList = [_rrmailConfig valueForKey:@"serverList"];
    
    NSMutableArray * mArray = [[NSMutableArray alloc]init];
    
    for ( NSMutableDictionary * _serverConfig in arrayServerList) {
       
        NSMutableDictionary * dic = _serverConfig.mutableCopy;
        
        NSString * numberMaxConcurrentOperations = [dic objectForKey:@"sourceServerMaxConcurrentOperations"];
        [dic setObject:[NSNumber numberWithInt:numberMaxConcurrentOperations.intValue] forKey:@"sourceServerMaxConcurrentOperations"];

        NSString * strSSL = [dic objectForKey:@"sourceServerRequireSSL"];
        [dic setObject:[NSNumber numberWithBool:strSSL.boolValue] forKey:@"sourceServerRequireSSL"];
        
        NSString * numberTCPPort = [dic objectForKey:@"sourceServerTCPPort"];
        [dic setObject:[NSNumber numberWithInt:numberTCPPort.intValue] forKey:@"sourceServerTCPPort"];
        
        [mArray addObject:dic];
    }
    
    [_rrmailConfig setObject:mArray forKey:@"serverList"];

    
    
    NSString *error;
    NSData *plistDataDic = [NSPropertyListSerialization dataFromPropertyList:_rrmailConfig format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    
    
  
    [plistDataDic writeToFile:@"/etc/rrmail.plist" atomically:YES];
}

-(void)loadUnloadSchedulerWithInit:(int)value
{
    NSString *path;
    NSData* data;
    NSTask * buildTask;
    NSPipe *pingpipe = [NSPipe pipe];
    NSFileHandle *pingfile;

    if (value == 0) {
        path  = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"UnLoadRRMailScheduler" ofType:@"command"]];
    }
    else if (value == 1) {
        path  = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"LoadRRMailScheduler" ofType:@"command"]];
    }
    else
        return;
    
    @try {
        buildTask = [[NSTask alloc] init];
        buildTask.launchPath = path;
        [buildTask setStandardOutput:pingpipe];
        pingfile = [pingpipe fileHandleForReading];
        [buildTask launch];
        [buildTask waitUntilExit];
    }
    @catch (NSException * exception) {
        NSLog(@"\n\n\nmon exeption : %@\n\n\n ", [exception description]);
    }
    @finally {
        
        NSString* tmpString;
        
        data = [pingfile readDataToEndOfFile];
        
        if ((data != nil) && [data length]) {
            tmpString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    
}

}

-(BOOL)checkIfSchedulerIsLoading
{
    NSString *path;
    NSData* data;
    NSTask * buildTask;
    NSPipe *pingpipe = [NSPipe pipe];
    NSFileHandle *pingfile;
    
    path  = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"CheckSchedulerLoading" ofType:@"command"]];
    
    @try {
        buildTask = [[NSTask alloc] init];
        buildTask.launchPath = path;
        [buildTask setStandardOutput:pingpipe];
        pingfile = [pingpipe fileHandleForReading];
        [buildTask launch];
        [buildTask waitUntilExit];
    }
    @catch (NSException * exception) {
        NSLog(@"\n\n\nmon exeption : %@\n\n\n ", [exception description]);
    }
    @finally {
        
        NSString* tmpString;
        
        data = [pingfile readDataToEndOfFile];
        
        if ((data != nil) && [data length]) {
            tmpString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        
        if (tmpString == nil) {
            return NO;
        }
        else
            return YES;
    }
}

- (void)createRRMailConfigFile
{
    NSBundle * bundle = [NSBundle mainBundle];
    
    NSString * path  = [NSString stringWithFormat:@"%@", [bundle pathForResource:@"rrmailconfig" ofType:@"plist"]];
        
    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    [savedStock writeToFile:@"/etc/rrmail.plist" atomically:YES];
}

@end
