//
//  NSString+keyPathComponents.h
//  RRMailPrefPane
//
//  Created by Yoann Gini on 13/10/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (keyPathComponents)

-(NSArray *)keyPathComponents;
+ (instancetype)stringWithKeyPathComponents:(NSArray*)keyPathComponents;

@end
