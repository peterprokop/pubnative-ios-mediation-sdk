//
//  PubnativeDeliveryRuleModel.h
//  mediation
//
//  Created by Mohit on 21/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PubnativeDeliveryRuleModel : NSObject

@property (nonatomic, strong)NSNumber   *imp_cap_day;
@property (nonatomic, strong)NSNumber   *imp_cap_hour;
@property (nonatomic, strong)NSNumber   *pacing_cap_hour;
@property (nonatomic, strong)NSNumber   *pacing_cap_minute;
@property (nonatomic, assign)NSNumber   *no_ads;
@property (nonatomic, strong)NSArray    *segment_ids;

+ (instancetype)modelWithDictionary:(NSDictionary*)dictionary;
- (BOOL)isDisabled;

@end
