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
- (void)transferData:(NSData*)fetchedData;
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
	NSLog(@"Get e-mail from %@ for %@ and redirect it to %@ for %@", [_serverConfig objectForKey:kRRMSourceServerAddressKey], [_userSettings objectForKey:kRRMSourceServerLoginKey], [_userSettings objectForKey:kRRMTargetServerKey], [_userSettings objectForKey:kRRMTargetServerAccountKey]);

#warning ygi: settings are used without data validation, we need to fix that ASAP.
    
    _imapSession = [[MCOIMAPSession alloc] init];
    [_imapSession setHostname:[_serverConfig objectForKey:kRRMSourceServerAddressKey]];
    NSString * strPort = (NSString *)[_serverConfig objectForKey:kRRMSourceServerTCPPortKey];
    [_imapSession setPort:strPort.intValue];
    [_imapSession setUsername:[_userSettings objectForKey:kRRMSourceServerLoginKey]];
    [_imapSession setPassword:[_userSettings objectForKey:kRRMSourceServerPasswordKey]];
    [_imapSession setConnectionType:MCOConnectionTypeTLS];
	
	_smtpSession = [[MCOSMTPSession alloc] init];
    [_smtpSession setHostname:[_userSettings objectForKey:kRRMTargetServerKey]];
    [_smtpSession setPort:25];
    [_smtpSession setConnectionType:MCOConnectionTypeClear];
    
    
    MCOIMAPMessagesRequestKind requestKind = MCOIMAPMessagesRequestKindHeaders;
    NSString *folder = @"INBOX";
    MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX)];
    
    MCOIMAPFetchMessagesOperation *fetchHeadersOperation = [_imapSession fetchMessagesByUIDOperationWithFolder:folder requestKind:requestKind uids:uids];
	
    
    [fetchHeadersOperation start:^(NSError * error, NSArray * fetchedHeaders, MCOIndexSet * vanishedMessages) {
        if(error) {
            NSLog(@"Error downloading message headers:%@", error);
			[self operationDone];
        }
        else
        {
			_messageCount = [fetchedHeaders count];
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
    for (MCOIMAPMessage * header in fetchedHeaders) {
        MCOIMAPFetchContentOperation * op = [_imapSession fetchMessageByUIDOperationWithFolder:@"INBOX" uid:[header uid]];
        [op start:^(NSError * error, NSData * data) {
            if ([error code] != MCOErrorNone) {
#warning ygi: need to add error handling
                [self decreaseMessageCount];
            }
			else
			{
				[self transferData:data];
			}
        }];
    }
}

- (void)transferData:(NSData*)fetchedData
{
#warning ygi: we need to update MailCore2 to handle SMTP operation with custom rcpt list, otherwise it will work only if original rcpt list are correctly reconized by remote server
    
    MCOSMTPSendOperation *sendOperation = [_smtpSession sendOperationWithData:fetchedData];
    [sendOperation start:^(NSError *error) {
        if(error) {
            NSLog(@"%@ Error sending email:%@", [_userSettings objectForKey:kRRMSourceServerLoginKey], error);
        } else {
            NSLog(@"%@ Successfully sent email!", [_userSettings objectForKey:kRRMSourceServerLoginKey]);
        }
		[self decreaseMessageCount];
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
