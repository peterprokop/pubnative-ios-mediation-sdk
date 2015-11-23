//
//  PubnativeDeliveryRuleModel.h
//  mediation
//
//  Created by Mohit on 21/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "JSONModel.h"

@interface PubnativeDeliveryRuleModel : JSONModel

@property (nonatomic, strong)NSNumber   *imp_cap_day;
@property (nonatomic, strong)NSNumber   *imp_cap_hour;
@property (nonatomic, strong)NSNumber   *pacing_cap_hour;
@property (nonatomic, strong)NSNumber   *pacing_cap_minute;
@property (nonatomic, assign)BOOL       no_ads;

- (BOOL) isActive;

@end
