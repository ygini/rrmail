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
	    __block BOOL allOperationsAreDone = NO;
		
	    [[RRMController sharedInstance] readConfigurationfFile:^(NSError *error) {
			if (error) {
				// ... Error handling ...
			}
			else
			{
				[[RRMController sharedInstance] startOperationsAndWait];
//				allOperationsAreDone = YES;
			}
		}];
	    
        
		do {
			@autoreleasepool {
				// Default and Common are differents modes, we need to run both with NSURLConnection
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
				[[NSRunLoop currentRunLoop] runMode:NSRunLoopCommonModes beforeDate:[NSDate distantFuture]];
			}
		} while (!allOperationsAreDone);
	}
    return 0;
}


