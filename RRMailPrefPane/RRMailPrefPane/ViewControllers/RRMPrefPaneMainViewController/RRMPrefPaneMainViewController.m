//
//  RRMPrefPaneMainViewController.m
//  RRMailPrefPane
//
//  Created by Yoann Gini on 13/10/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import "RRMPrefPaneMainViewController.h"

#import <Sparkle/Sparkle.h>
#import "RRMConstants.h"
#import <RRMPrefPaneServerSettingsWindowController.h>

@interface RRMPrefPaneMainViewController ()

@property (strong) IBOutlet NSArrayController *serverList;
@property (strong) IBOutlet NSArrayController *accountList;

- (IBAction)editSelectedServer:(id)sender;
@end

@implementation RRMPrefPaneMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)viewWillLoad
{
	self.rrmailctl = [RRMailCTL sharedInstance];
}

- (IBAction)addServer:(id)sender {
	RRMPrefPaneServerSettingsWindowController *serverSettings = [RRMPrefPaneServerSettingsWindowController prepareServerSettingsWindowWithSourceInfo:nil];
	
	[NSApp beginSheet:serverSettings.window
	   modalForWindow:[NSApp mainWindow]
		modalDelegate:self
	   didEndSelector:@selector(serverAdditionDidEnd:returnCode:contextInfo:)
		  contextInfo:(void*)CFBridgingRetain(serverSettings)];
}

- (IBAction)editSelectedServer:(id)sender {
	RRMPrefPaneServerSettingsWindowController *serverSettings = [RRMPrefPaneServerSettingsWindowController prepareServerSettingsWindowWithSourceInfo:[self.serverList.selectedObjects lastObject]];
	
	[NSApp beginSheet:serverSettings.window
	   modalForWindow:[NSApp mainWindow]
		modalDelegate:self
	   didEndSelector:@selector(serverEditionDidEnd:returnCode:contextInfo:)
		  contextInfo:(void*)CFBridgingRetain(serverSettings)];
}

- (IBAction)deleteSelectedServer:(id)sender {
	if ([self.serverList.selectedObjects count] > 0) {
		NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Delete the server \"%@\"?", [[self.serverList.selectedObjects lastObject] objectForKey:kRRMSourceServerAddressKey]]
										 defaultButton:@"OK"
									   alternateButton:@"Cancel"
										   otherButton:nil
							 informativeTextWithFormat:@"Deleting a server permanently removes it and any accounts related. Previously forwarded e-mails won't been lost. This action cannot be undone."];
		
		[alert beginSheetModalForWindow:[NSApp mainWindow]
						  modalDelegate:self
						 didEndSelector:@selector(serverDeletionDidEnd:returnCode:contextInfo:)
							contextInfo:NULL];
	}
}

- (void)serverAdditionDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(CFTypeRef)contextInfo
{
	RRMPrefPaneServerSettingsWindowController *serverSettings = CFBridgingRelease(contextInfo);
	
	if (NSOKButton == returnCode) {
		NSMutableDictionary * configuration = [self.rrmailctl.configuration mutableCopy];
		NSMutableArray *serverListArray = [configuration valueForKey:(NSString *)kRRMServerListKey];
		
		[serverListArray addObject:serverSettings.serverInfo];
		
		self.rrmailctl.configuration = configuration;
		
		self.serverList.selectionIndex = [serverListArray count] - 1;
	}
	
	[serverSettings.window orderOut:self];
}

- (void)serverEditionDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(CFTypeRef)contextInfo
{
	RRMPrefPaneServerSettingsWindowController *serverSettings = CFBridgingRelease(contextInfo);
	
	if (NSOKButton == returnCode) {
		NSUInteger selectedIndex = self.serverList.selectionIndex;
		NSMutableDictionary * configuration = [self.rrmailctl.configuration mutableCopy];
		NSMutableArray *serverListArray = [configuration valueForKey:(NSString *)kRRMServerListKey];
		
		[serverListArray removeObjectAtIndex:selectedIndex];
		[serverListArray insertObject:serverSettings.serverInfo atIndex:selectedIndex];
		
		self.rrmailctl.configuration = configuration;
		
		self.serverList.selectionIndex = selectedIndex;
	}
	
	[serverSettings.window orderOut:self];
}

- (void)serverDeletionDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(CFTypeRef)contextInfo
{
	if (NSOKButton == returnCode) {
		NSUInteger selectedIndex = self.serverList.selectionIndex;
		NSMutableDictionary * configuration = [self.rrmailctl.configuration mutableCopy];
		NSMutableArray *serverListArray = [configuration valueForKey:(NSString *)kRRMServerListKey];
		
		[serverListArray removeObjectAtIndex:selectedIndex];
		
		self.rrmailctl.configuration = configuration;
		
		self.serverList.selectionIndex = selectedIndex - 1;
	}
}

@end
