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
    NSError *error = nil;
    NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES)objectAtIndex:0];
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/LaunchDaemons", stringPath]  error:&error];
    
    if ([filePathsArray indexOfObject:@"com.rrmail.scheduler.plist"] != NSNotFound) {
        
        
        NSString *path = [NSString stringWithFormat:@"%@/LaunchDaemons/com.rrmail.scheduler.plist", stringPath];
        NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
     
        [savedStock setObject:[NSNumber numberWithInt:timeInterval] forKey:@"StartInterval"];
        
        [savedStock writeToFile:path atomically:YES];
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

@end
