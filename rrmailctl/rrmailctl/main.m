//
//  main.m
//  ConfigureRRMail
//
//  Created by Florian BONNIEC on 9/3/13.
//  Copyright (c) 2013 Florian BONNIEC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RRMailConfigController.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        NSDictionary * arguments = [[NSUserDefaults standardUserDefaults] volatileDomainForName:NSArgumentDomain];
        
        
        // Update Scheduler
        NSString * intervalTime = [arguments objectForKey:@"intervalTime"];
        if (intervalTime) {
            [[RRMailConfigController sharedInstance]setCheckMailIntervalTime:intervalTime.intValue];
        }
        
        // Update RRMailConfig
        NSDictionary * serverConfig = [arguments objectForKey:@"rrmailConfig"];
        if (serverConfig)
        {
            [[RRMailConfigController sharedInstance]updateRRMailConfig:serverConfig];
        }
        
        // LoadUnload Sheduler
        NSString * strLoadUnloadScheduler = [arguments objectForKey:@"luScheduler"];
        if (strLoadUnloadScheduler) {
            [[RRMailConfigController sharedInstance]loadUnloadSchedulerWithInit:strLoadUnloadScheduler.intValue];
        }
        
        // LoadUnload Sheduler
        NSString * strCheckSchedulerLoading = [arguments objectForKey:@"checkSchedulerLoading"];
        if (strCheckSchedulerLoading) {
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
        }
        
        // Create RRMailConfig File createRRMailConfigFile
        NSString * strCreateRRMailConfigFile = [arguments objectForKey:@"createRRMailConfigFile"];
        if (strCreateRRMailConfigFile) {
            [[RRMailConfigController sharedInstance]createRRMailConfigFile];
        }
        
    }
    
    return 0;
}

