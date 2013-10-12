//
//  main.m
//  ConfigureRRMail
//
//  Created by Florian BONNIEC on 9/3/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDCommandLineInterface.h"
#import "RRMailConfigController.h"

BOOL commandLineMustBeRunAsRoot()
{
#ifdef DEBUG
	return YES;
#else
	static BOOL isRunAsRoot = NO;
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *userName = NSUserName();
		if ([@"root" isEqualToString:userName]) {
			isRunAsRoot = YES;
		}
    });
	return isRunAsRoot;
#endif
}

int main(int argc, const char * argv[])
{
	if (commandLineMustBeRunAsRoot()) {
		return DDCliAppRunWithClass([RRMailConfigController class]);
	}
	else {
		printf("Must be run as root\n");
		return EXIT_FAILURE;
	}
    


    @autoreleasepool {

        NSDictionary * arguments = [[NSUserDefaults standardUserDefaults] volatileDomainForName:NSArgumentDomain];
        
        
        // Update Scheduler
        NSString * intervalTime = [arguments objectForKey:@"intervalTime"];
        if (intervalTime)
        {
            [[RRMailConfigController sharedInstance]setCheckMailIntervalTime:intervalTime.intValue];
            return 0;
        }
        
        // Update RRMailConfig
        NSDictionary * serverConfig = [arguments objectForKey:@"rrmailConfig"];
        if (serverConfig)
        {
            [[RRMailConfigController sharedInstance]updateRRMailConfig:serverConfig];
            return 0;
        }
        
        // LoadUnload Sheduler
        NSString * strLoadUnloadScheduler = [arguments objectForKey:@"luScheduler"];
        if (strLoadUnloadScheduler)
        {
            [[RRMailConfigController sharedInstance]loadUnloadSchedulerWithInit:strLoadUnloadScheduler.intValue];
            return 0;
        }
        
        // LoadUnload Sheduler
        NSString * strCheckSchedulerLoading = [arguments objectForKey:@"checkSchedulerLoading"];
        if (strCheckSchedulerLoading)
        {
           BOOL isLoading = [[RRMailConfigController sharedInstance]checkIfSchedulerIsLoading];
            
            if (isLoading == YES) {
                NSLog(@"YES");
                printf("YES");
            }
            else
            {
                NSLog(@"NO");
                printf("NO");
            }
            return 0;
        }
        
        // Create RRMailConfig File createRRMailConfigFile
        NSString * strCreateRRMailConfigFile = [arguments objectForKey:@"createRRMailConfigFile"];
        if (strCreateRRMailConfigFile)
        {
            [[RRMailConfigController sharedInstance]createRRMailConfigFile];
            return 0;
        }
        
    }
    
    return 0;
}

