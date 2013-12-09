//
//  INIGNumberToStringValueTransformer.m
//  RRMailPrefPane
//
//  Created by Yoann Gini on 13/10/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import "INIGNumberToStringValueTransformer.h"

@implementation INIGNumberToStringValueTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

- (id)transformedValue:(NSNumber*)value {
    return value.stringValue;
}

-(id)reverseTransformedValue:(NSString*)value {
	NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber * number = [formatter numberFromString:value];
	
	return number;
}


@end
