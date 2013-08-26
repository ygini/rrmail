//
//  RRMController+CheckConfiguration.h
//  rrmail
//
//  Created by Florian BONNIEC on 8/26/13.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

#import "RRMController.h"

@interface RRMController (CheckConfiguration)

-(NSError *)ccWithConfiguration:(NSDictionary *)_configuration;
-(BOOL)verifyHost:(NSString *)_hostName;

@end
