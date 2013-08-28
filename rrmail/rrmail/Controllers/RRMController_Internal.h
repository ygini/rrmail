//
//  RRMController_Internal.h
//  rrmail
//
//  Created by Yoann Gini on 28/08/13.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "RRMController.h"

@interface RRMController ()
{
	NSString *_configurationFilePath;
	
	OSSpinLock _configurationLock;
	OSSpinLock _operationQueueLock;
	NSDictionary *_configuration;
	
	NSMutableDictionary *_operationQueues;
}

@end