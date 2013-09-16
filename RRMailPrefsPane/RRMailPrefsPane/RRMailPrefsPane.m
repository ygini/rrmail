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

- (BOOL)callRRMailConfigWithParameters:(NSMutableArray *)args
{
	FILE *processOutput;

    // Convert array into void-* array.
    const char **argv = (const char **)malloc(sizeof(char *) * [args count] + 1);
    int argvIndex = 0;
    for (NSString *string in args) {
        argv[argvIndex] = [string UTF8String];
        argvIndex++;
    }
    argv[argvIndex] = nil;
        
    OSErr processError = AuthorizationExecuteWithPrivileges([[authView authorization] authorizationRef], [@"/usr/bin/rrmailctl/rrmailctl" UTF8String],
                                                            kAuthorizationFlagDefaults, (char *const *)argv, &processOutput);
    free(argv);
    
    if (processError != errAuthorizationSuccess)
        NSLog(@"Error: %d", processError);
    

    // Setup the two-way pipe.
    NSFileHandle * helperHandle = [[NSFileHandle alloc] initWithFileDescriptor:fileno(processOutput)];
    NSData *data = [helperHandle readDataToEndOfFile];
    NSString * tmpString;
    
    // Convert the data into a string.
    tmpString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
	fclose(processOutput);
    
    [self.displayInfoViewController updatePrefPaneInterfaceTimeInterval];
    
    return tmpString.boolValue;
}

- (BOOL)displayInfoViewController:(DisplayInfoViewController *)controller callRRMailConfigWithParameters:(NSMutableArray *)parameters
{
    return [self callRRMailConfigWithParameters:parameters];
}


@end
