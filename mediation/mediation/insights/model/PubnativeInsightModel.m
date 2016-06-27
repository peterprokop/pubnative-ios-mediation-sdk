//
//  PubnativeInsightModel.m
//  mediation
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PubnativeInsightModel.h"
#import "PubnativeInsightCrashModel.h"

@implementation PubnativeInsightModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.data = [[PubnativeInsightDataModel alloc] init];
    }
    return self;
}

- (void)sendRequestInsight
{
    [PubnativeInsightsManager trackDataWithUrl:self.requestInsightUrl parameters:self.params data:self.data];
}

- (void)sendImpressionInsight
{
    [PubnativeInsightsManager trackDataWithUrl:self.impressionInsightUrl parameters:self.params data:self.data];
}

- (void)sendClickInsight
{
    [PubnativeInsightsManager trackDataWithUrl:self.clickInsightUrl parameters:self.params data:self.data];
}

- (void)trackUnreachableNetworkWithPriorityRuleModel:(PubnativePriorityRulesModel*)priorityRuleModel
                                        responseTime:(NSNumber*)responseTime
                                           exception:(NSException*)exception
{
    PubnativeInsightCrashModel *crashModel = [[PubnativeInsightCrashModel alloc] init];
    crashModel.error = exception.description;
    crashModel.details = exception.reason;
}

@end
