//
//  main.m
//  rrmail
//
//  Created by Yoann Gini on 07/08/13.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RRMController.h"

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
            // error
            [[CocoaSyslog sharedInstance] messageLevel7Debug:@"[Config Check] RRMail error message: %@", error];

        }
		
		[[CocoaSyslog sharedInstance] closeLog];
        
	}
    return 0;
}


