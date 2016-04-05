//
//  PubnativePriorityRulesModel.m
//  mediation
//
//  Created by Mohit on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativePriorityRulesModel.h"

@implementation PubnativePriorityRulesModel

+ (instancetype)modelWithDictionary:(NSDictionary*)dictionary
{
    PubnativePriorityRulesModel *result;
    
    if(dictionary) {
        
        result = [[PubnativePriorityRulesModel alloc] init];
        result.identifier = dictionary[@"id"];
        result.network_code = dictionary[@"network_code"];
        result.params = dictionary[@"params"];
        result.segment_ids = dictionary[@"segment_ids"];
    }
    
    return result;
}

@end
