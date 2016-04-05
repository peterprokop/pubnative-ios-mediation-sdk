//
//  PubnativePlacementModel.m
//  mediation
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativePlacementModel.h"

@implementation PubnativePlacementModel

+ (instancetype)modelWithDictionary:(NSDictionary*)dictionary
{
    PubnativePlacementModel *result;
    if(dictionary){
        result = [[PubnativePlacementModel alloc] init];

        result.ad_format_code = dictionary[@"ad_format_code"];
        
        // priority_rules
        NSArray *priorityRulesArrray = dictionary[@"priority_rules"];
        NSMutableArray *priorityRules;
        if(priorityRulesArrray){
            priorityRules = [NSMutableArray array];
            for (NSDictionary *priorityDictionary in priorityRulesArrray) {
                PubnativePriorityRulesModel *priority = [PubnativePriorityRulesModel modelWithDictionary:priorityDictionary];
                if(priority){
                    [priorityRules addObject:priority];
                }
            }
        }
        result.priority_rules = priorityRules;
        
        // delivery_rule
        result.delivery_rule = [PubnativeDeliveryRuleModel modelWithDictionary:dictionary[@"delivery_rule"]];
    }
    return result;
}

@end
