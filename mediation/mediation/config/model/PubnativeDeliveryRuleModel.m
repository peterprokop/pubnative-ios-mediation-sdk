//
//  PubnativeDeliveryRuleModel.m
//  mediation
//
//  Created by Mohit on 21/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeDeliveryRuleModel.h"
#import "PubnativeDeliveryManager.h"

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

- (BOOL)isDayImpressionCapActive
{
    return self.imp_cap_day > 0;
}

- (BOOL)isHourImpressionCapActive
{
    return self.imp_cap_hour > 0;
}
- (BOOL)isPacingCapActive
{
    return self.pacing_cap_hour > 00 || self.pacing_cap_minute > 0;
}

- (BOOL)isFrequencyCapReachedWithPlacement:(NSString*)placementName
{
    BOOL frequencyCapReached = false;
    if ([self isDayImpressionCapActive]) {
        frequencyCapReached = [self.imp_cap_day intValue] <= [PubnativeDeliveryManager currentDayCountForPlacementName:placementName];
    }
    if (!frequencyCapReached && [self isHourImpressionCapActive]) {
        frequencyCapReached = [self.imp_cap_hour intValue] <= [PubnativeDeliveryManager currentHourCountForPlacementName:placementName];
    }
    return frequencyCapReached;
}

@end
