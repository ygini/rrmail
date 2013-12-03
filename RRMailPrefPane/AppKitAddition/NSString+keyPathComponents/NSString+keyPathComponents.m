//
//  NSString+keyPathComponents.m
//  RRMailPrefPane
//
//  Created by Yoann Gini on 13/10/13.
//  Copyright (c) 2013 iNig-Services. All rights reserved.
//

#import "NSString+keyPathComponents.h"

@implementation NSString (keyPathComponents)

-(NSArray *)keyPathComponents
{
	return [self componentsSeparatedByString:@"."];
}

+ (instancetype)stringWithKeyPathComponents:(NSArray*)keyPathComponents
{
	NSMutableString *tmpString = [NSMutableString new];
	NSInteger nbrOfComponents = [keyPathComponents count];
	for (NSInteger i = 0; i < nbrOfComponents; i++) {
		[tmpString appendString:[keyPathComponents objectAtIndex:i]];
		if (i < nbrOfComponents - 1) {
			[tmpString appendString:@"."];
		}
	}
	
	return [NSString stringWithString:tmpString];
}

@end
