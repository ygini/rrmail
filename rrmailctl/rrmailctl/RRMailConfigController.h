//
//  RRMailConfigController.h
//  ConfigureRRMail
//
//  Created by Florian BONNIEC on 9/3/13.
//  Copyright (c) 2013 Florian BONNIEC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RRMailConfigController : NSObject

+(RRMailConfigController *)sharedInstance;
-(void) setCheckMailIntervalTime:(int)timeInterval;
-(void)updateRRMailConfig:(NSDictionary *)rrmailConfig;

@end
