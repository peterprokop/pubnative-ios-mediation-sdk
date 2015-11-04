//
//  NSString+PubnativeStringUtil.m
//  mediation
//
//  Created by Mohit on 29/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "NSString+PubnativeStringUtil.h"

NSString * const kEmptyString = @"";

@implementation NSString (PubnativeStringUtil)

- (BOOL) isEmptyString
{
    BOOL isEmpty = NO;
    
    NSCharacterSet *whiteSpaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedString = [self stringByTrimmingCharactersInSet:whiteSpaceCharacterSet];
    
    if ([trimmedString isEqualToString:kEmptyString]) {
        isEmpty = YES;
    }
    
    return isEmpty;
}

@end
