//
//  INIGBoolToStringValueTransformer.m
//  RRMailPrefPane
//
//  Created by Yoann Gini on 13/10/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import "INIGBoolToStringValueTransformer.h"

@implementation INIGBoolToStringValueTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value {
    if ([value boolValue])
    {
        return @"YES";
    }
    return @"NO";
}


@end
