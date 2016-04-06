//
//  PubnativeDeliveryRuleModel.m
//  mediation
//
//  Created by Mohit on 21/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeDeliveryRuleModel.h"

@implementation PubnativeDeliveryRuleModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if(self){
        self.imp_cap_day = dictionary[@"imp_cap_day"];
        self.imp_cap_hour = dictionary[@"imp_cap_hour"];
        self.pacing_cap_hour = dictionary[@"pacing_cap_hour"];
        self.pacing_cap_minute = dictionary[@"pacing_cap_minute"];
        self.no_ads = dictionary[@"no_ads"];
        self.segment_ids = dictionary[@"segment_ids"];
    }
    return self;
}

- (BOOL)isDisabled
{
    return [self.no_ads boolValue];
}

@end
