//
//  RRMailCTL.h
//  RRMailPrefPane
//
//  Created by Yoann Gini on 13/10/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SecurityFoundation/SFAuthorization.h>

@interface RRMailCTL : NSObject

@property (strong) SFAuthorization *authorization;

@property (strong, nonatomic) IBOutlet NSMutableDictionary *configuration;
@property (weak, nonatomic) IBOutlet NSNumber *serviceIsLoaded;
@property (weak, nonatomic) IBOutlet NSString *startInterval;

+ (instancetype)sharedInstance;

- (void)loadService;
- (void)unloadService;
- (NSString*)environement;

@end
