//
//  RRMOperation.h
//  rrmail
//
//  Created by Yoann Gini on 07/08/13.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RRMOperation : NSOperation

@property(assign, nonatomic) BOOL isExecuting;
@property(assign, nonatomic) BOOL isFinished;
@property(assign, nonatomic) BOOL canStop;

@end

@interface RRMOperation (NSOperationRedefinition)
- (void)operationStart;
- (void)operationGo;
- (void)operationDone;
@end