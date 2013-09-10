//
//  RRMailPrefsPane.m
//  RRMailPrefsPane
//
//  Created by Florian BONNIEC on 9/2/13.
//  Copyright (c) 2013 Florian BONNIEC. All rights reserved.
//

#import "RRMailPrefsPane.h"
#import "RRMConstants.h"



@interface  RRMailPrefsPane()

@property (nonatomic,strong) NSWindow * windowSheet;
@property (nonatomic,strong) IBOutlet DisplayInfoViewController *displayInfoViewController;
@property (nonatomic,strong) IBOutlet AddSourceServerViewController *addSSViewController;
@property (nonatomic,strong) IBOutlet AddSourceServerAccountViewController *addSSAccountViewController;

@end

@implementation RRMailPrefsPane


- (void)mainViewDidLoad
{
    
    self.displayInfoViewController = [[DisplayInfoViewController alloc] initWithNibName:@"DisplayInfoView" bundle:[NSBundle bundleWithIdentifier:@"com.florianbonniec.RRMailPrefsPane"]];
    [self.displayInfoViewController setDelegate:self];
    
    [self.mainView addSubview:self.displayInfoViewController.view];
    [self.displayInfoViewController.view setFrame:NSRectFromCGRect(CGRectMake(0, 40, self.displayInfoViewController.view.frame.size.width, self.displayInfoViewController.view.frame.size.height))];
    
    
    self.addSSViewController = [[AddSourceServerViewController alloc] initWithNibName:@"AddSourceServerView" bundle:[NSBundle bundleWithIdentifier:@"com.florianbonniec.RRMailPrefsPane"]];
    self.addSSAccountViewController = [[AddSourceServerAccountViewController alloc] initWithNibName:@"AddSourceServerAccountView" bundle:[NSBundle bundleWithIdentifier:@"com.florianbonniec.RRMailPrefsPane"]];
    
    self.windowSheet = [[NSWindow alloc]init];
    
    // Setup security.
    AuthorizationItem items = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights rights = {1, &items};
    [authView setAuthorizationRights:&rights];
    authView.delegate = self;
    [authView updateStatus:nil];
    
    
    [self.displayInfoViewController enableOrDisableAllButton:[self isUnlocked]];    
    
}

- (BOOL)isUnlocked {
    return [authView authorizationState] == SFAuthorizationViewUnlockedState;
}

//
// SFAuthorization delegates
//

- (void)authorizationViewDidAuthorize:(SFAuthorizationView *)view
{
    [self.displayInfoViewController enableOrDisableAllButton:[self isUnlocked]];
}

- (void)authorizationViewDidDeauthorize:(SFAuthorizationView *)view
{
    [self.displayInfoViewController enableOrDisableAllButton:[self isUnlocked]];
}

- (void)callRRMailConfigWithParameters:(NSMutableArray *)args
{
    // Convert array into void-* array.
    const char **argv = (const char **)malloc(sizeof(char *) * [args count] + 1);
    int argvIndex = 0;
    for (NSString *string in args) {
        argv[argvIndex] = [string UTF8String];
        argvIndex++;
    }
    argv[argvIndex] = nil;
        
    OSErr processError = AuthorizationExecuteWithPrivileges([[authView authorization] authorizationRef], [@"/Users/florianbonniec/rrmailctl" UTF8String],
                                                            kAuthorizationFlagDefaults, (char *const *)argv, NULL);
    free(argv);
    
    if (processError != errAuthorizationSuccess)
        NSLog(@"Error: %d", processError);
}


//- (void)updatePrefPaneInterface
//{    
//    NSError *error = nil;
//    NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES)objectAtIndex:0];
//    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/LaunchDaemons", stringPath]  error:&error];
//    
//    if ([filePathsArray indexOfObject:@"com.rrmail.scheduler.plist"] != NSNotFound) {
//        
//        NSString *path = [NSString stringWithFormat:@"%@/LaunchDaemons/com.rrmail.scheduler.plist", stringPath];
//        NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
//
//        NSNumber * startInterval = [savedStock valueForKey:@"StartInterval"];
//        
//        [textFieldTimeIntrval setStringValue:startInterval.stringValue];
//    }
//    
//    
//    NSMutableDictionary *rrmailConfig = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/etc/rrmail.plist"];
//    
//    for (NSMutableDictionary * _serverConfig in [rrmailConfig objectForKey:@"serverList"])
//    {
//        NSString * strSourceServerAddressKey = [_serverConfig objectForKey:kRRMSourceServerAddressKey];
//        [buttonSelectSSAddress addItemWithTitle:strSourceServerAddressKey];
//
////        NSString * strSSL = [_serverConfig objectForKey:kRRMSourceServerRequireSSLKey];
////
////        NSNumber * numberMaxConcurrentOperations = [_serverConfig objectForKey:kRRMSourceServerMaxConcurrentOperationsKey];
//
//        NSNumber * numberTCPPort = [_serverConfig objectForKey:kRRMSourceServerTCPPortKey];
//
//        [textFieldSourceServerPort setStringValue:numberTCPPort.stringValue];
//        for (NSMutableDictionary * _userSettings in  [_serverConfig objectForKey:@"sourceServerAccountList"])
//        {
//            NSLog(@"%@", _userSettings);
//        }
//    }
//
//}

//- (IBAction)goAddSourceServerView:(id)sender
//{
//    [self.windowSheet setFrame:self.addSSViewController.view.bounds display:NO];
//    [self.windowSheet.contentView addSubview:self.addSSViewController.view];
//    
//    [self.addSSViewController setDelegate:self];
//    
//    
//    [NSApp beginSheet:self.windowSheet
//       modalForWindow:self.mainView.window
//        modalDelegate:self
//       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
//          contextInfo:NULL];
//}



- (void)closeSheet
{
    [self.windowSheet orderOut:self];
    [NSApp endSheet:self.windowSheet];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	
}


- (void)displayInfoViewController:(DisplayInfoViewController *)controller callRRMailConfigWithParameters:(NSMutableArray *)parameters
{
    [self callRRMailConfigWithParameters:parameters];
}

- (void)addSourceServerViewController:(AddSourceServerViewController *)controller
{
    [self closeSheet];
    [self.windowSheet.contentView remove:self.addSSViewController];
}

- (void)addSourceServerAccountViewController:(AddSourceServerAccountViewController *)controller
{
    [self closeSheet];
    [self.windowSheet.contentView remove:self.addSSAccountViewController];
}
@end
