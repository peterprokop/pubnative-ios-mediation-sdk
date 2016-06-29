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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if(self){
        self.error = dictionary[@"error"];
        self.details = dictionary[@"details"];
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *result =[[NSMutableDictionary alloc] init];
    [result setValue:self.error forKey:@"error"];
    [result setValue:self.details forKey:@"details"];
    return result;
}

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
