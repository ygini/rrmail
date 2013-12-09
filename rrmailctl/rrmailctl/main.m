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

int main(int argc, const char * argv[])
{
	uid_t userid = getuid();
	if (setuid(0) == 0) {
		return DDCliAppRunWithClass([RRMailConfigController class]);
	}
	else {
		printf("Must be run as root\n");
		return EXIT_FAILURE;
	}
	setuid(userid);
    return 0;
}

