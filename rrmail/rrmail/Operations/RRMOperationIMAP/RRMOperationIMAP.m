//
//  RRMOperationIMAP.m
//  rrmail
//
//  Created by Yoann Gini on 15/08/13.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "RRMOperationIMAP.h"
#import "RRMConstants.h"
#import <libkern/OSAtomic.h>

#import <MailCore/MailCore.h>

#include "CocoaSyslog.h"

@interface RRMOperationIMAP ()
{
	NSDictionary *_serverConfig;
	NSDictionary *_userSettings;
    
	NSUInteger _messageCount;
	
	OSSpinLock _messageCountLock;
	
	MCOIMAPSession *_imapSession;
	MCOSMTPSession *_smtpSession;
}

- (void)getMessageContentWithFetchedHeaders:(NSArray *)fetchedHeaders;
- (void)transferData:(NSData*)fetchedData withOriginalIMAPMessageUID:(uint32_t)uid;
- (void)decreaseMessageCount;

@end

@implementation RRMOperationIMAP


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

- (void)dealloc
{
    [_imapSession release], _imapSession = nil;
    [_smtpSession release], _smtpSession = nil;
    [_serverConfig release], _serverConfig = nil;
	[_userSettings release], _userSettings = nil;
    [super dealloc];
}

#pragma mark RRMOperation

- (void)operationGo {
	[[CocoaSyslog sharedInstance] messageLevel6Info:@"[IMAP] Start fetch operation for %@ at %@",
	   [_userSettings objectForKey:kRRMSourceServerLoginKey],
	   [_serverConfig objectForKey:kRRMSourceServerAddressKey]];
	
#warning ygi: settings are used without data validation, we need to fix that ASAP.
    
    _imapSession = [[MCOIMAPSession alloc] init];
    [_imapSession setHostname:[_serverConfig objectForKey:kRRMSourceServerAddressKey]];
    NSString * strPort = (NSString *)[_serverConfig objectForKey:kRRMSourceServerTCPPortKey];
    [_imapSession setPort:strPort.intValue];
    [_imapSession setUsername:[_userSettings objectForKey:kRRMSourceServerLoginKey]];
    [_imapSession setPassword:[_userSettings objectForKey:kRRMSourceServerPasswordKey]];

    NSString * useSLL = [_serverConfig objectForKey:kRRMSourceServerRequireSSLKey];
    if ( useSLL.boolValue == YES) {
        [_imapSession setConnectionType:MCOConnectionTypeTLS];
    }
    else
    {
        [_imapSession setConnectionType:MCOConnectionTypeClear];
    }
    
    
	_smtpSession = [[MCOSMTPSession alloc] init];
    [_smtpSession setHostname:[_userSettings objectForKey:kRRMTargetServerKey]];
    [_smtpSession setPort:25];
    [_smtpSession setConnectionType:MCOConnectionTypeClear];
    
    
    
    MCOIMAPMessagesRequestKind requestKind = MCOIMAPMessagesRequestKindHeaders;
    NSString *folder = @"INBOX";
    MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX)];
    
    MCOIMAPFetchMessagesOperation *fetchHeadersOperation = [_imapSession fetchMessagesByUIDOperationWithFolder:folder requestKind:requestKind uids:uids];
	
    
    [fetchHeadersOperation start:^(NSError * error, NSArray * fetchedHeaders, MCOIndexSet * vanishedMessages)
	 {
        if(error) {
            NSLog(@"Error downloading message headers:%@", error);
			[[CocoaSyslog sharedInstance] messageLevel3Error:@"[IMAP] Unable to download message headers"];
			[[CocoaSyslog sharedInstance] messageLevel7Debug:@"[IMAP] MailCore2 error message: %@", error];
			[self operationDone];
        }
        else
        {
			_messageCount = [fetchedHeaders count];
			
			[[CocoaSyslog sharedInstance] messageLevel6Info:@"[IMAP] Found %d message(s) from %@ at %@", _messageCount, [_imapSession username], [_imapSession hostname]];
			if (_messageCount == 0)
			{
				[self operationDone];
			}
			else
			{
				[self getMessageContentWithFetchedHeaders:fetchedHeaders];
			}
        }        
    }];	
}

#pragma mark - IMAP handling

- (void)getMessageContentWithFetchedHeaders:(NSArray *)fetchedHeaders
{
	NSMutableArray *fetchedAndOrderedHeaders = [fetchedHeaders mutableCopy];
	
	[fetchedAndOrderedHeaders sortUsingComparator:^NSComparisonResult(MCOIMAPMessage * obj1, MCOIMAPMessage * obj2)
	 {
		if ([obj1 uid] < [obj2 uid])
		{
			return NSOrderedAscending;
		}
		else if ([obj1 uid] == [obj2 uid])
		{
			return NSOrderedSame;
		}
		else
		{
			return NSOrderedDescending;
		}
	}];
	
    for (MCOIMAPMessage * header in fetchedAndOrderedHeaders) {
        MCOIMAPFetchContentOperation * op = [_imapSession fetchMessageByUIDOperationWithFolder:@"INBOX" uid:[header uid]];
        [op start:^(NSError * error, NSData * data)
		{
            if ([error code] != MCOErrorNone)
			{
				[[CocoaSyslog sharedInstance] messageLevel3Error:@"[IMAP] Unable to download message with UID %u", [header uid]];
				[[CocoaSyslog sharedInstance] messageLevel7Debug:@"[IMAP] MailCore2 error message: %@", error];
				[self decreaseMessageCount];
            }
			else
			{
				[[CocoaSyslog sharedInstance] messageLevel6Info:@"[IMAP] Message %u from %@ at %@ fetched (%u bytes)", [header uid], [_imapSession username], [_imapSession hostname], [data length]];
				[self transferData:data withOriginalIMAPMessageUID:[header uid]];
			}
        }];
    }
	
	[fetchedAndOrderedHeaders release];
}

- (void)transferData:(NSData*)fetchedData withOriginalIMAPMessageUID:(uint32_t)uid
{

	MCOMessageParser * messageParser = [[MCOMessageParser alloc] initWithData:fetchedData];
    MCOSMTPSendOperation *sendOperation = [_smtpSession sendOperationWithData:fetchedData
																		 from:messageParser.header.from
																   recipients:[NSArray arrayWithObjects:[MCOAddress addressWithMailbox:[_userSettings objectForKey:kRRMTargetServerAccountKey]], nil]];
    [sendOperation start:^(NSError *error)
	{
        if(error)
		{
			[[CocoaSyslog sharedInstance] messageLevel3Error:@"[IMAP-SMTP] Unable to to send message %u to %@ at %@", uid, [_userSettings objectForKey:kRRMTargetServerAccountKey], [_smtpSession hostname]];
			[[CocoaSyslog sharedInstance] messageLevel7Debug:@"[IMAP-SMTP] MailCore2 error message: %@", error];
			[self decreaseMessageCount];
        }
		else
		{
			[[CocoaSyslog sharedInstance] messageLevel6Info:@"[IMAP-SMTP] Message %u transfered to %@ at %@", uid, [_userSettings objectForKey:kRRMSourceServerLoginKey], [_smtpSession hostname]];

			MCOIMAPOperation *changeFlagsIMAPOperation = [_imapSession storeFlagsOperationWithFolder:@"INBOX"
																								uids:[MCOIndexSet indexSetWithIndex:uid]
																								kind:MCOIMAPStoreFlagsRequestKindSet
																							   flags:MCOMessageFlagDeleted];
			
			[changeFlagsIMAPOperation start:^(NSError * error)
			 {
				if(!error) {
					[[CocoaSyslog sharedInstance] messageLevel6Info:@"[IMAP-SMTP] Message %u marked for deletion (%@ at %@)", uid, [_userSettings objectForKey:kRRMSourceServerLoginKey], [_smtpSession hostname]];
					MCOIMAPOperation *deleteIMAPOperation = [_imapSession expungeOperation:@"INBOX"];
					[deleteIMAPOperation start:^(NSError *error) {
						if(error)
						{
							[[CocoaSyslog sharedInstance] messageLevel3Error:@"[IMAP-SMTP] Unable to expunge inbox (%@ at %@)", [_userSettings objectForKey:kRRMTargetServerAccountKey], [_smtpSession hostname]];
							[[CocoaSyslog sharedInstance] messageLevel7Debug:@"[IMAP-SMTP] MailCore2 error message: %@", error];
						}
						else
						{
							[[CocoaSyslog sharedInstance] messageLevel6Info:@"[IMAP-SMTP] Successfully expunged inbox (%@ at %@)", [_userSettings objectForKey:kRRMSourceServerLoginKey], [_smtpSession hostname]];
						}
						[self decreaseMessageCount];
					}];
				} else {
					[[CocoaSyslog sharedInstance] messageLevel3Error:@"[IMAP-SMTP] Unable to mark message %u for deletion (%@ at %@)", uid, [_userSettings objectForKey:kRRMTargetServerAccountKey], [_smtpSession hostname]];
					[[CocoaSyslog sharedInstance] messageLevel7Debug:@"[IMAP-SMTP] MailCore2 error message: %@", error];
					[self decreaseMessageCount];
				}
			}];
			
        }
    }];
	[messageParser release];
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
