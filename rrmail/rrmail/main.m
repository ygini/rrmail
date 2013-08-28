//
//  main.m
//  rrmail
//
//  Created by Yoann Gini on 07/08/13.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RRMController.h"
#import "RRMConstants.h"

int main(int argc, const char * argv[])
{
	@autoreleasepool {
		[[CocoaSyslog sharedInstance] setApplicationIdentity:@"rrmail"];
		[[CocoaSyslog sharedInstance] setConsoleOutput:YES];
		[[CocoaSyslog sharedInstance] setFacility:CSLLogFacilityMail];
		[[CocoaSyslog sharedInstance] openLog];
		
		[[CocoaSyslog sharedInstance] messageLevel6Info:@"Application did start"];
		
	    NSError *error = [[RRMController sharedInstance] readConfigurationfFile];
        if (!error) {
            [[RRMController sharedInstance] startOperations];
            
            do {
                @autoreleasepool {
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                    [[NSRunLoop currentRunLoop] runMode:NSRunLoopCommonModes beforeDate:[NSDate distantFuture]];
                }
            } while ([[RRMController sharedInstance] totalOperationCount] > 0);
        }
        else
        {
			[[CocoaSyslog sharedInstance] messageLevel3Error:@"Impossible to read application settings, please check content of %@", kRRMControllerDefaultConfigFile];
            [[CocoaSyslog sharedInstance] messageLevel7Debug:@"Error message: %@", error];

        }
		
		[[CocoaSyslog sharedInstance] messageLevel6Info:@"Process did end, application gonna terminate"];
		
		[[CocoaSyslog sharedInstance] closeLog];
        
	}
    return 0;
}


