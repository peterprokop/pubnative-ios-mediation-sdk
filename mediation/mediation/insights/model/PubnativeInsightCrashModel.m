//
//  PubnativeInsightCrashModel.m
//  mediation
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PubnativeInsightCrashModel.h"

NSString * const kPubnativeInsightCrashModelErrorNoFill = @"no_fill";
NSString * const kPubnativeInsightCrashModelErrorTimeout = @"timeout";
NSString * const kPubnativeInsightCrashModelErrorConfig = @"configuration";
NSString * const kPubnativeInsightCrashModelErrorAdapter = @"adapter";

@implementation PubnativeInsightCrashModel

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.error = [aDecoder decodeObjectForKey:@"error"];
        self.details = [aDecoder decodeObjectForKey:@"details"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.error forKey:@"error"];
    [aCoder encodeObject:self.details forKey:@"details"];
}

@end
