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
    
}

@end

@implementation RRMOperationPOP3

#pragma mark Object lifecycle

- (id)initWithServerConfiguration:(NSDictionary*)serverConfig andUserSettings:(NSDictionary*)userSettings
{
    self = [super init];
    if (self) {
        _serverConfig = [serverConfig copy];
		_userSettings = [userSettings copy];
    }
    return self;
}

- (void)dealloc
{
    [_serverConfig release], _serverConfig = nil;
	[_userSettings release], _userSettings = nil;
    [super dealloc];
}

#pragma mark RRMOperation

- (void)operationGo {
	    
	NSLog(@"Get e-mail from %@ for %@ and redirect it to %@ for %@", [_serverConfig objectForKey:kRRMSourceServerAddressKey], [_userSettings objectForKey:kRRMSourceServerLoginKey], [_userSettings objectForKey:kRRMTargetServerKey], [_userSettings objectForKey:kRRMTargetServerAccountKey]);
	
    // Create session to get mail from selected account 
    
    MCOIMAPSession *session = [[MCOIMAPSession alloc] init];
    [session setHostname:[_serverConfig objectForKey:kRRMSourceServerAddressKey]];
    
    NSString * strPort = (NSString *)[_serverConfig objectForKey:kRRMSourceServerTCPPortKey];
    [session setPort:strPort.intValue];
    
    [session setUsername:[_userSettings objectForKey:kRRMSourceServerLoginKey]];
    [session setPassword:[_userSettings objectForKey:kRRMSourceServerPasswordKey]];
    [session setConnectionType:MCOConnectionTypeTLS];
    
    
    // Get header's mail using for test

    MCOIMAPMessagesRequestKind requestKind = MCOIMAPMessagesRequestKindHeaders;
    
    
    // Select target folder
    
    NSString *folder = @"INBOX";
    
    MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX)];
    
    
    // Create your request
    
    MCOIMAPFetchMessagesOperation *fetchOperation = [session fetchMessagesByUIDOperationWithFolder:folder requestKind:requestKind uids:uids];
   
    
    [fetchOperation start:^(NSError * error, NSArray * fetchedMessages, MCOIndexSet * vanishedMessages) {
        //We've finished downloading the messages!
        
        //Let's check if there was an error:
        if(error) {
            NSLog(@"Error downloading message headers:%@", error);
        }
        else
        {
            // if succes you've got email header, so get mail content using uid's mail
            
            [self getMessageContentWithFetchedMessages:fetchedMessages andSession:session];
        }
        //And, let's print out the messages...
//        NSLog(@"The post man delivereth:%@", fetchedMessages);
        
        
    }];
    
    
	// Start async operation and when it's done, call [self operationDone]; from anywhere in this instance.
    
    [self operationDone];

}



- (void)getMessageContentWithFetchedMessages:(NSArray *)fetchedMessages andSession:(MCOIMAPSession*)_session
{
    
    // if no error you've got email header, so get mail content using uid's mail

    for (MCOIMAPMessage * message in fetchedMessages) {
                
        MCOIMAPFetchContentOperation * op = [_session fetchMessageByUIDOperationWithFolder:@"INBOX" uid:[message uid]];
        [op start:^(NSError * error, NSData * data) {
            if ([error code] != MCOErrorNone) {
                return;
            }
            
            // if succes parse message using MCOMessageParser
            
            MCOMessageParser * messageParser = [MCOMessageParser messageParserWithData:data];
            
            
            // Create new message to send 
            
            [self transferDataWithFetchedMessages:message andSession:_session andParsedMessage:messageParser];

            
        }];
        
    }
}

- (void)transferDataWithFetchedMessages:(MCOIMAPMessage *)message andSession:(MCOIMAPSession*)_session andParsedMessage:(MCOMessageParser *)parsedMessage
{
    
    // Create session to send mail using target server
    
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];

    [smtpSession setHostname:[_serverConfig objectForKey:kRRMSourceServerAddressKey]];
    [smtpSession setPort:25];
    [smtpSession setUsername:[_userSettings objectForKey:kRRMSourceServerLoginKey]];
    [smtpSession setPassword:[_userSettings objectForKey:kRRMSourceServerPasswordKey]];
    [smtpSession setConnectionType:MCOConnectionTypeStartTLS];
    
    // Build your new message using MCOMessageBuilder
    // You can use "[builder setHeader:message.header]" to set directly the header from "message.header" or custom you own message
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
        
//    NSMutableArray *to = [[NSMutableArray alloc] init];
//    for(MCOAddress *toAddress in message.header.to) {
//        NSLog(@"ladresse est : %@", toAddress.nonEncodedRFC822String);
//        MCOAddress *newAddress = [MCOAddress addressWithDisplayName:nil mailbox:@"hui2sier@gmail.com"];
//        [to addObject:newAddress];
//    }
    
    
    // Redirect your mail on target address    
    NSMutableArray *to = [[NSMutableArray alloc] init];
    MCOAddress *newAddress = [MCOAddress addressWithDisplayName:nil mailbox:[_userSettings objectForKey:kRRMTargetServerAccountKey]];
    [to addObject:newAddress];
    
    [[builder header] setTo:to];
    
    // Set Date
    [[builder header] setDate:parsedMessage.header.date];
    
    // Set Sender
    [[builder header] setSender:message.header.sender];
    
    // Set From
    [[builder header] setFrom:message.header.from];
    
    // Set References
    [[builder header] setReferences:message.header.references];
    
    // Set ReplyTo as the first recipient from downloaded mail
    [[builder header] setReplyTo:message.header.to];

    // Set cc
    [[builder header] setCc:message.header.cc];
        
    // Set bcc
    [[builder header] setBcc:message.header.bcc];
    
    // Set subject
    [[builder header] setSubject:message.header.subject];
        
    // Set Html body from parsed message
    [builder setHTMLBody:parsedMessage.htmlBodyRendering];
    
    // Set Attachments body from parsed message
    [builder setAttachments:parsedMessage.attachments];
    
    // Create data from builder
    NSData * rfc822Data = [builder data];
    
    
    // Send data using MCOSMTPSendOperation
    MCOSMTPSendOperation *sendOperation = [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
            NSLog(@"%@ Error sending email:%@", [_userSettings objectForKey:kRRMSourceServerLoginKey], error);
        } else {
            NSLog(@"%@ Successfully sent email!", [_userSettings objectForKey:kRRMSourceServerLoginKey]);
        }
    }];
     
}

@end
