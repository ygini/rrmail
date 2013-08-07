//
//  RRMController.h
//  rrmail
//
//  Created by Yoann Gini on 07/08/13.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RRMController : NSObject

+(RRMController*)sharedInstance;

-(RRMController*)initWithConfigurationFilePath:(const NSString*)configurationFilePath;

-(void)readConfigurationfFile:(void(^)(NSError *error))completionHandler;

-(void)startOperations;
-(void)startOperationsAndWait;
-(void)waitEndOfAllOperations;


-(NSUInteger)totalOperationCount;
-(NSUInteger)operationQueueCount;
@end
