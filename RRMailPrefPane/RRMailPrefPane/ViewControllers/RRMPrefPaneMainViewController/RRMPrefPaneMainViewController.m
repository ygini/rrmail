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

- (IBAction)editSelectedServer:(id)sender {
	RRMPrefPaneServerSettingsWindowController *serverSettings = [RRMPrefPaneServerSettingsWindowController prepareServerSettingsWindowWithSourceInfo:[self.serverList.selectedObjects lastObject]];
	
	[NSApp beginSheet:serverSettings.window
	   modalForWindow:[NSApp mainWindow]
		modalDelegate:self
	   didEndSelector:@selector(serverEditionDidEnd:returnCode:contextInfo:)
		  contextInfo:(void*)CFBridgingRetain(serverSettings)];
}

- (void)serverEditionDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(CFTypeRef)contextInfo
{
	RRMPrefPaneServerSettingsWindowController *serverSettings = CFBridgingRelease(contextInfo);
	
	if (NSOKButton == returnCode) {
		NSUInteger selectedIndex = self.serverList.selectionIndex;
		NSMutableDictionary * configuration = [self.rrmailctl.configuration mutableCopy];
		NSMutableArray *serverList = [configuration valueForKey:(NSString *)kRRMServerListKey];
		
		[serverList removeObjectAtIndex:selectedIndex];
		[serverList insertObject:serverSettings.serverInfo atIndex:selectedIndex];
		
		self.rrmailctl.configuration = configuration;
	}
	
	[serverSettings.window orderOut:self];
}

@end
