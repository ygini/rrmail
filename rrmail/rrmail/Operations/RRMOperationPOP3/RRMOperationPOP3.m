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
	
    MCOIMAPSession *session = [[MCOIMAPSession alloc] init];
    [session setHostname:[_serverConfig objectForKey:kRRMSourceServerAddressKey]];
    [session setPort:993];
    [session setUsername:[_userSettings objectForKey:kRRMSourceServerLoginKey]];
    [session setPassword:[_userSettings objectForKey:kRRMSourceServerPasswordKey]];
    [session setConnectionType:MCOConnectionTypeTLS];
    
//    [session setHostname:@"mail.inig-services.com"];
//    [session setPort:993];
//    [session setUsername:@"florian@inig-services.com"];
//    [session setPassword:@"B53F-9C5FA4ED93A1"];
//    [session setConnectionType:MCOConnectionTypeTLS];

    
    
    MCOIMAPMessagesRequestKind requestKind = MCOIMAPMessagesRequestKindHeaders;
    NSString *folder = @"INBOX";
    MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(1, UINT64_MAX)];
    
    
    MCOIMAPFetchMessagesOperation *fetchOperation = [session fetchMessagesByUIDOperationWithFolder:folder requestKind:requestKind uids:uids];
   
    
    [fetchOperation start:^(NSError * error, NSArray * fetchedMessages, MCOIndexSet * vanishedMessages) {
        //We've finished downloading the messages!
        
        //Let's check if there was an error:
        if(error) {
            NSLog(@"Error downloading message headers:%@", error);
        }
        else
            [self transferDataWithFetchedMessages:fetchedMessages andSession:session];

        //And, let's print out the messages...
//        NSLog(@"The post man delivereth:%@", fetchedMessages);
        
        
    }];
    
	// Start async operation and when it's done, call [self operationDone]; from anywhere in this instance.
    
    [self operationDone];

}

- (void)transferDataWithFetchedMessages:(NSArray *)fetchedMessages andSession:(MCOIMAPSession*)_session
{
    
    
    
    for (MCOIMAPMessage * messageParser in fetchedMessages) {
        
//        NSLog(@"%@", messageParser.attachments);
        
        MCOIMAPFetchContentOperation * op = [_session fetchMessageByUIDOperationWithFolder:@"INBOX" uid:[messageParser uid]];
        [op start:^(NSError * error, NSData * data) {
            if ([error code] != MCOErrorNone) {
                return;
            }
                        
            MCOMessageParser * msg = [MCOMessageParser messageParserWithData:data];
            NSLog(@"Mon contenu est :\n%@\n", msg.plainTextBodyRendering);
            
        }];

    }
    
    /*
    
        MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
        smtpSession.hostname = @"mrs.storymaker.fr";
//        smtpSession.hostname = @"mail.gandi.net";

        smtpSession.port = 25;
        smtpSession.username = @"hui2sier@storymaker.fr";
        smtpSession.password = @"bistoufly13";
        smtpSession.connectionType = MCOConnectionTypeStartTLS;
        
        MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
        
//        NSLog(@"message from is: %@ ", messageParser.header.from);
//        NSLog(@"message to is: %@ ", messageParser.header.to);

        [[builder header] setSender:messageParser.header.sender];
        [[builder header] setFrom:[MCOAddress addressWithDisplayName:nil mailbox:messageParser.header.from.mailbox]];
        [[builder header] setReferences:messageParser.header.references];

        
        NSMutableArray *to = [[NSMutableArray alloc] init];
        for(MCOAddress *toAddress in messageParser.header.to) {
        NSLog(@"ladresse est : %@", toAddress.nonEncodedRFC822String);
        MCOAddress *newAddress = [MCOAddress addressWithMailbox:@"hui2sier@gmail.com"];
            [to addObject:newAddress];
        }
        [[builder header] setTo:to];
        
        
        
        NSMutableArray *cc = [[NSMutableArray alloc] init];
        for(MCOAddress *ccAddress in messageParser.header.cc) {
//        MCOAddress *newAddress = [MCOAddress addressWithMailbox:ccAddress];
            [cc addObject:ccAddress];
        }
        [[builder header] setCc:cc];
        
        NSMutableArray *bcc = [[NSMutableArray alloc] init];
        for(MCOAddress *bccAddress in messageParser.header.bcc) {
//        MCOAddress *newAddress = [MCOAddress addressWithMailbox:bccAddress];
        [bcc addObject:bccAddress];
        }
        [[builder header] setBcc:bcc];
        
        [[builder header] setSubject:messageParser.header.subject];
//    [builder setAttachments:messageParser.attachments];
        NSData * rfc822Data = [builder data];
    
        
        
        
        MCOSMTPSendOperation *sendOperation = [smtpSession sendOperationWithData:rfc822Data];
        [sendOperation start:^(NSError *error) {
            if(error) {
                NSLog(@"%@ Error sending email:%@", [_userSettings objectForKey:kRRMSourceServerLoginKey], error);
            } else {
                NSLog(@"%@ Successfully sent email!", [_userSettings objectForKey:kRRMSourceServerLoginKey]);
            }
        }];
    
    */
     
     
}

@end
