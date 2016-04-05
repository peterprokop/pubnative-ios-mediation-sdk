//
//  PubnativeDeliveryRuleModel.m
//  mediation
//
//  Created by Mohit on 21/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeDeliveryRuleModel.h"

@implementation PubnativeDeliveryRuleModel

+ (instancetype)modelWithDictionary:(NSDictionary*)dictionary
{
    PubnativeDeliveryRuleModel *result;
    
    if(dictionary){
        result = [[PubnativeDeliveryRuleModel alloc] init];
        result.imp_cap_day = dictionary[@"imp_cap_day"];
        result.imp_cap_hour = dictionary[@"imp_cap_hour"];
        result.pacing_cap_hour = dictionary[@"pacing_cap_hour"];
        result.pacing_cap_minute = dictionary[@"pacing_cap_minute"];
        result.no_ads = dictionary[@"no_ads"];
        result.segment_ids = dictionary[@"segment_ids"];
    }
    
    return result;
}

- (BOOL)isDisabled
{
    return [self.no_ads boolValue];
}

@end
