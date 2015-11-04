//
//  PubnativeDeliveryRuleModel.m
//  mediation
//
//  Created by Mohit on 21/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeDeliveryRuleModel.h"

@implementation PubnativeDeliveryRuleModel

- (BOOL) isActive
{
    return !self.no_ads;
}

- (BOOL) isFrequencyCapReachedForPlacementKey:(NSString *)placementKey
{
    // TODO: Implement it as per delivery manager
    return false;
}

@end
