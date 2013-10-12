//
//  RRMailConfigController.h
//  ConfigureRRMail
//
//  Created by Florian BONNIEC on 9/3/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDCommandLineInterface.h"

@interface RRMailConfigController : NSObject <DDCliApplicationDelegate>

+(RRMailConfigController *)sharedInstance;
-(void) setCheckMailIntervalTime:(int)timeInterval;
-(void)updateRRMailConfig:(NSDictionary *)rrmailConfig;
-(void)loadUnloadSchedulerWithInit:(int)value;
-(BOOL)checkIfSchedulerIsLoading;
-(void)createRRMailConfigFile;

@end
