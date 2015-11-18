//
//  PubnativePlacementModel.h
//  mediation
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "PubnativeDeliveryRuleModel.h"
#import "PubnativePriorityRulesModel.h"

@interface PubnativePlacementModel : JSONModel

@property (nonatomic, strong)NSString                               *ad_format_code;
@property (nonatomic, strong)NSArray<PubnativePriorityRulesModel>   *priority_rules;
@property (nonatomic, strong)PubnativeDeliveryRuleModel             *delivery_rule;

@end
