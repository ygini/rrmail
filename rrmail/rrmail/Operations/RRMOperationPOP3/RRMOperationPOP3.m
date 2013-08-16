//
//  RRMOperationPOP3.m
//  rrmail
//
//  Created by Yoann Gini on 07/08/13.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "RRMOperationPOP3.h"
#import "RRMConstants.h"

#import <MailCore/MailCore.h>


@interface RRMOperationPOP3 ()
{
	NSDictionary *_serverConfig;
	NSDictionary *_userSettings;
    
    NSUInteger _messageCount;
	
	OSSpinLock _messageCountLock;
	
	MCOPOPSession *_popSession;
	MCOSMTPSession *_smtpSession;
    
    BOOL doIt;
}

- (void)getMessageContentWithFetchedMessages:(NSArray *)fetchedHeaders;
- (void)transferData:(NSData*)fetchedData;
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
        
        doIt = YES;

    }
    return self;
}

- (void)dealloc
{
    [_popSession release], _popSession = nil;
    [_smtpSession release], _smtpSession = nil;
    [_serverConfig release], _serverConfig = nil;
	[_userSettings release], _userSettings = nil;
    [super dealloc];
}

#pragma mark RRMOperation

- (void)operationGo {
	NSLog(@"Get e-mail from %@ for %@ and redirect it to %@ for %@", [_serverConfig objectForKey:kRRMSourceServerAddressKey], [_userSettings objectForKey:kRRMSourceServerLoginKey], [_userSettings objectForKey:kRRMTargetServerKey], [_userSettings objectForKey:kRRMTargetServerAccountKey]);
	
#warning ygi: settings are used without data validation, we need to fix that ASAP.
    _popSession = [[MCOPOPSession alloc] init];
    [_popSession setHostname:[_serverConfig objectForKey:kRRMSourceServerAddressKey]];
//    NSString * strPort = (NSString *)[_serverConfig objectForKey:kRRMSourceServerTCPPortKey];
//    [_popSession setPort:strPort.intValue];
    [_popSession setUsername:[_userSettings objectForKey:kRRMSourceServerLoginKey]];
    [_popSession setPassword:[_userSettings objectForKey:kRRMSourceServerPasswordKey]];
    [_popSession setConnectionType:MCOConnectionTypeStartTLS];
	
	_smtpSession = [[MCOSMTPSession alloc] init];
    [_smtpSession setHostname:[_serverConfig objectForKey:kRRMSourceServerAddressKey]];
    [_smtpSession setPort:25];
    [_smtpSession setUsername:[_userSettings objectForKey:kRRMSourceServerLoginKey]];
    [_smtpSession setPassword:[_userSettings objectForKey:kRRMSourceServerPasswordKey]];
    [_smtpSession setConnectionType:MCOConnectionTypeStartTLS];
    
    
    MCOPOPFetchMessagesOperation *fetchMessagesOperation = [_popSession fetchMessagesOperation];
	
    
    [fetchMessagesOperation start:^(NSError * error, NSArray * fetchedMessages) {
        
        if(error) {
            NSLog(@"Error downloading messages :%@", error);

			[self operationDone];
        }
        else
        {
			_messageCount = [fetchedMessages count];
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

#pragma mark - IMAP handling

- (void)getMessageContentWithFetchedMessages:(NSArray *)fetchedMessages
{
    for (MCOPOPMessageInfo * header in fetchedMessages) {

        MCOPOPFetchMessageOperation * op = [_popSession fetchMessageOperationWithIndex:header.index];
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
