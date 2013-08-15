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
	    [[RRMController sharedInstance] readConfigurationfFile];
	    [[RRMController sharedInstance] startOperations];
	    
		do {
			@autoreleasepool {
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
				[[NSRunLoop currentRunLoop] runMode:NSRunLoopCommonModes beforeDate:[NSDate distantFuture]];
			}
		} while ([[RRMController sharedInstance] totalOperationCount] > 0);
	}
    return 0;
}


