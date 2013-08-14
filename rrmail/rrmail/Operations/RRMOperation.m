//
//  RRMOperation.m
//  rrmail
//
//  Created by Yoann Gini on 07/08/13.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "RRMOperation.h"

#import <libkern/OSAtomic.h>

@interface RRMOperation ()
{
	OSSpinLock _lock;
}

@end

@implementation RRMOperation

#pragma mark Accessors

-(void)setIsExecuting:(BOOL)isExecuting {
	[self willChangeValueForKey:@"isExecuting"];
	_isExecuting = isExecuting;
	[self didChangeValueForKey:@"isExecuting"];
}

-(void)setIsFinished:(BOOL)isFinished {
	[self willChangeValueForKey:@"isFinished"];
	_isFinished = isFinished;
	[self didChangeValueForKey:@"isFinished"];
}

- (BOOL) isConcurrent {
    return YES;
}

#pragma mark NSOperation

- (id)init
{
    self = [super init];
    if (self) {
        _lock = OS_SPINLOCK_INIT;
    }
    return self;
}

-(void)start {	
	OSSpinLockLock(&_lock);
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		[self operationStart];
	});
	
	OSSpinLockUnlock(&_lock);
}

#pragma mark NSOperationRedefinition

- (void)operationStart {	
	OSSpinLockLock(&_lock);
	
	if ([self isCancelled]) {
        [self operationDone];
    } else {
		self.isFinished = NO;
		self.isExecuting = YES;
		self.canStop = NO;
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			[self operationGo];
		});
	}
	
	OSSpinLockUnlock(&_lock);
	
	if (self.canStop) {
		[self operationDone];
	}
}

- (void)operationGo {
	
}

- (void)operationDone {
    
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		OSSpinLockLock(&_lock);
		self.isFinished = YES;
		self.isExecuting = NO;
		OSSpinLockUnlock(&_lock);
	});
}

@end
