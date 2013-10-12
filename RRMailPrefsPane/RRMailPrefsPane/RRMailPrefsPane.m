//
//  RRMailPrefsPane.m
//  RRMailPrefsPane
//
//  Created by Florian BONNIEC on 9/2/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
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
    
    self.displayInfoViewController = [[DisplayInfoViewController alloc] initWithNibName:@"DisplayInfoView" bundle:[NSBundle bundleWithIdentifier:@"com.inig-services.RRMailPrefsPane"]];
    [self.displayInfoViewController setDelegate:self];
    
    [self.mainView addSubview:self.displayInfoViewController.view];
    [self.displayInfoViewController.view setFrame:NSRectFromCGRect(CGRectMake(0, 40, self.displayInfoViewController.view.frame.size.width, self.displayInfoViewController.view.frame.size.height))];
    
    
    self.addSSViewController = [[AddSourceServerViewController alloc] initWithNibName:@"AddSourceServerView" bundle:[NSBundle bundleWithIdentifier:@"com.inig-services.RRMailPrefsPane"]];
    self.addSSAccountViewController = [[AddSourceServerAccountViewController alloc] initWithNibName:@"AddSourceServerAccountView" bundle:[NSBundle bundleWithIdentifier:@"com.inig-services.RRMailPrefsPane"]];
    
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

- (void)runRrmailctlWithArguments:(NSArray*)arguments dataForSTDIN:(NSData*)stdinData andReturnSTDOUT:(NSData**)stdoutData
{
	FILE *commandSTDInAndOut = 0;
	
	OSErr processError =  errAuthorizationSuccess;
	
	// Convert array into void-* array.
    const char **argv = (const char **)malloc(sizeof(char *) * [arguments count] + 1);
    int argvIndex = 0;
    for (NSString *string in arguments) {
        argv[argvIndex] = [string UTF8String];
        argvIndex++;
    }
    argv[argvIndex] = nil;
	
	processError = AuthorizationExecuteWithPrivileges([[authView authorization] authorizationRef], [kRRMCommandLineFullPath UTF8String],
                                                            kAuthorizationFlagDefaults, (char *const *)argv, &commandSTDInAndOut);
    free(argv);
	
	if (processError != errAuthorizationSuccess) {
		NSLog(@"Error returned by AuthorizationExecuteWithPrivileges: %d", processError);
	}
	else {
		NSFileHandle * twoWayFileHandle = [[NSFileHandle alloc] initWithFileDescriptor:fileno(commandSTDInAndOut) closeOnDealloc:YES];
		
		if (stdinData) {
			[twoWayFileHandle writeData:stdinData];
		}
		else if (stdoutData) {
			*stdoutData = [twoWayFileHandle readDataToEndOfFile];
		}
		twoWayFileHandle = nil;
	}
}

@end
