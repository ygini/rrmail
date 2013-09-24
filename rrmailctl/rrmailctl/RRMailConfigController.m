//
//  RRMailConfigController.m
//  ConfigureRRMail
//
//  Created by Florian BONNIEC on 9/3/13.
//  Copyright (c) 2013 Florian BONNIEC. All rights reserved.
//

#import "RRMailConfigController.h"

@implementation RRMailConfigController

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
