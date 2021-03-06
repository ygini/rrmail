//
//  RRMOperationPOP3.m
//  rrmail
//
//  Created by Yoann Gini on 07/08/13.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "RRMOperationPOP3.h"
#import "RRMConstants.h"
#import <libkern/OSAtomic.h>

#import <MailCore/MailCore.h>

#include "CocoaSyslog.h"


@interface RRMOperationPOP3 ()
{
	NSDictionary *_serverConfig;
	NSDictionary *_userSettings;
    
    NSUInteger _messageCount;
	
	OSSpinLock _messageCountLock;
	
	MCOPOPSession *_popSession;
	MCOSMTPSession *_smtpSession;
    
}

- (void)getMessageContentWithFetchedMessages:(NSArray *)fetchedHeaders;
- (void)transferData:(NSData*)fetchedData withOriginalPOPMessageIndex:(uint32_t)index;
- (void)decreaseMessageCount;

@end

@implementation RRMOperationPOP3

#pragma mark Object lifecycle

- (id)initWithServerConfiguration:(NSDictionary*)serverConfig andUserSettings:(NSDictionary*)userSettings
{
    self = [super init];
    if (self) {
        _serverConfig = [serverConfig copy];
		_userSettings = [userSettings copy];
        
        _messageCountLock = OS_SPINLOCK_INIT;
    }
    return self;
}

#pragma mark RRMOperation

- (void)operationGo {

	[[CocoaSyslog sharedInstance] messageLevel6Info:@"[POP] Start fetch operation for %@ at %@",
     [_userSettings objectForKey:kRRMSourceServerLoginKey],
     [_serverConfig objectForKey:kRRMSourceServerAddressKey]];
	

    _popSession = [[MCOPOPSession alloc] init];
    [_popSession setHostname:[_serverConfig objectForKey:kRRMSourceServerAddressKey]];
    NSString * strPort = (NSString *)[_serverConfig objectForKey:kRRMSourceServerTCPPortKey];
    [_popSession setPort:strPort.intValue];
    [_popSession setUsername:[_userSettings objectForKey:kRRMSourceServerLoginKey]];
    [_popSession setPassword:[_userSettings objectForKey:kRRMSourceServerPasswordKey]];
    
    NSString * useSLL = [_serverConfig objectForKey:kRRMSourceServerRequireSSLKey];
    if ( useSLL.boolValue == YES) {
        [_popSession setConnectionType:MCOConnectionTypeTLS];
    }
    else
    {
        [_popSession setConnectionType:MCOConnectionTypeClear];
    }
    
    _smtpSession = [[MCOSMTPSession alloc] init];
    [_smtpSession setHostname:[_userSettings objectForKey:kRRMTargetServerKey]];
    [_smtpSession setPort:25];
    [_smtpSession setConnectionType:MCOConnectionTypeClear];
    
    MCOPOPFetchMessagesOperation *fetchMessagesOperation = [_popSession fetchMessagesOperation];
    
    [fetchMessagesOperation start:^(NSError * error, NSArray * fetchedMessages) {
        
        if(error) {
			[[CocoaSyslog sharedInstance] messageLevel3Error:@"[POP] Unable to download message"];
			[[CocoaSyslog sharedInstance] messageLevel7Debug:@"[POP] MailCore2 error message: %@", error];
			[self operationDone];
        }
        else
        {
			_messageCount = [fetchedMessages count];
            
            [[CocoaSyslog sharedInstance] messageLevel6Info:@"[POP] Found %d message(s) from %@ at %@", _messageCount, [_popSession username], [_popSession hostname]];
            
			if (_messageCount == 0)
			{
				[self operationDone];
			}
			else
			{
				[self getMessageContentWithFetchedMessages:fetchedMessages];
			}
        }
    }];
}

#pragma mark - POP handling

- (void)getMessageContentWithFetchedMessages:(NSArray *)fetchedMessages
{
    NSMutableArray *fetchedAndOrderedMessage = [fetchedMessages mutableCopy];
	
	[fetchedAndOrderedMessage sortUsingComparator:^NSComparisonResult(MCOPOPMessageInfo * obj1, MCOPOPMessageInfo * obj2)
	 {
         if ([obj1 index] < [obj2 index])
         {
             return NSOrderedAscending;
         }
         else if ([obj1 index] == [obj2 index])
         {
             return NSOrderedSame;
         }
         else
         {
             return NSOrderedDescending;
         }
     }];
    
    for (MCOPOPMessageInfo * header in fetchedMessages) {

        MCOPOPFetchMessageOperation * op = [_popSession fetchMessageOperationWithIndex:header.index];
        [op start:^(NSError * error, NSData * data) {
            if ([error code] != MCOErrorNone)
            {
                [[CocoaSyslog sharedInstance] messageLevel3Error:@"[POP] Unable to download message with Index %d", [header index]];
				[[CocoaSyslog sharedInstance] messageLevel7Debug:@"[POP] MailCore2 error message: %@", error];
                [self decreaseMessageCount];
            }
			else
			{
                [[CocoaSyslog sharedInstance] messageLevel6Info:@"[POP] Message %d from %@ at %@ fetched (%u bytes)", [header index], [_popSession username], [_popSession hostname], [data length]];
				[self transferData:data withOriginalPOPMessageIndex:[header index]];
			}
        }];
    }
    
}


- (void)transferData:(NSData*)fetchedData withOriginalPOPMessageIndex:(uint32_t)index
{
    
	MCOMessageParser * messageParser = [[MCOMessageParser alloc] initWithData:fetchedData];
    MCOSMTPSendOperation *sendOperation = [_smtpSession sendOperationWithData:fetchedData
																		 from:messageParser.header.from
																   recipients:[NSArray arrayWithObjects:[MCOAddress addressWithMailbox:[_userSettings objectForKey:kRRMTargetServerAccountKey]], nil]];
    [sendOperation start:^(NSError *error)
     {
         if(error)
         {
             [[CocoaSyslog sharedInstance] messageLevel3Error:@"[POP-SMTP] Unable to to send message %u to %@ at %@", index, [_userSettings objectForKey:kRRMTargetServerAccountKey], [_smtpSession hostname]];
             [[CocoaSyslog sharedInstance] messageLevel7Debug:@"[POP-SMTP] MailCore2 error message: %@", error];
             
             [self decreaseMessageCount];
         }
         else
         {
             [[CocoaSyslog sharedInstance] messageLevel6Info:@"[POP-SMTP] Message %u transfered to %@ at %@", index, [_userSettings objectForKey:kRRMSourceServerLoginKey], [_smtpSession hostname]];
    
             MCOIndexSet * indexes = [MCOIndexSet indexSet];
             [indexes addIndex:index];
             
             MCOPOPOperation *deletePOPOperation = [_popSession deleteMessagesOperationWithIndexes:indexes];
             [deletePOPOperation start:^(NSError *error) {
                 if(error)
                 {
                     [[CocoaSyslog sharedInstance] messageLevel3Error:@"[POP-SMTP] Unable to delete message (%@ at %@)", [_userSettings objectForKey:kRRMTargetServerAccountKey], [_smtpSession hostname]];
                     [[CocoaSyslog sharedInstance] messageLevel7Debug:@"[POP-SMTP] MailCore2 error message: %@", error];
                 }
                 else
                 {
                     [[CocoaSyslog sharedInstance] messageLevel6Info:@"[POP-SMTP] Successfully delete message (%@ at %@)", [_userSettings objectForKey:kRRMSourceServerLoginKey], [_smtpSession hostname]];
                 }
                                  
                 [self decreaseMessageCount];
             }];
         }
     }];
    
}


#pragma mark - Internal

- (void)decreaseMessageCount
{
	OSSpinLockLock(&_messageCountLock);
	_messageCount--;
	
	if (_messageCount == 0) {
		[self operationDone];
	}
	OSSpinLockUnlock(&_messageCountLock);
}

@end
