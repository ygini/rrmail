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
        
        // Update Scheduler
        NSDictionary * arguments = [[NSUserDefaults standardUserDefaults] volatileDomainForName:NSArgumentDomain];
        
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

    }
    
    return 0;
}

