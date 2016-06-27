//
//  PubnativeInsightRequestModel.m
//  mediation
//
//  Created by Alvarlega on 23/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PubnativeInsightRequestModel.h"

NSString * const kInsightRequestModelUrlKey = @"url";
NSString * const kInsightRequestModelParametersKey = @"parameters";
NSString * const kInsightRequestModelDataKey = @"data";

@implementation PubnativeInsightRequestModel

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.url = [aDecoder decodeObjectForKey:kInsightRequestModelUrlKey];
        self.params = [aDecoder decodeObjectForKey:kInsightRequestModelParametersKey];
        self.data = [aDecoder decodeObjectForKey:kInsightRequestModelDataKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.url forKey:kInsightRequestModelUrlKey];
    [aCoder encodeObject:self.params forKey:kInsightRequestModelParametersKey];
    [aCoder encodeObject:self.data forKey:kInsightRequestModelDataKey];
}

@end