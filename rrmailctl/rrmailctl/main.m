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
	
    return 0;
}

