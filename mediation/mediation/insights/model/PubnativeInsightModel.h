//
//  PubnativeInsightModel.h
//  mediation
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubnativeInsightDataModel.h"
#import "PubnativeInsightsManager.h"
#import "PubnativePriorityRuleModel.h"

@interface PubnativeInsightModel : NSObject

@property (nonatomic, strong) NSString                          *requestInsightUrl;
@property (nonatomic, strong) NSString                          *impressionInsightUrl;
@property (nonatomic, strong) NSString                          *clickInsightUrl;
@property (nonatomic, strong) PubnativeInsightDataModel         *data;
@property (nonatomic, strong) NSDictionary<NSString*,NSString*> *params;

- (void)sendRequestInsight;
- (void)sendImpressionInsight;
- (void)sendClickInsight;
- (void)trackUnreachableNetworkWithPriorityRuleModel:(PubnativePriorityRuleModel*)priorityRuleModel responseTime:(NSNumber*)responseTime exception:(NSException*)exception;
- (void)trackAttemptedNetworkWithPriorityRuleModel:(PubnativePriorityRuleModel*)priorityRuleModel responseTime:(NSNumber*)responseTime exception:(NSException*)exception;
- (void)trackSuccededNetworkWithPriorityRuleModel:(PubnativePriorityRuleModel*)priorityRuleModel responseTime:(NSNumber*)responseTime;

@end
