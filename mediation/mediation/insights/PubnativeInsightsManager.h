//
//  PubnativeInsightsManager.h
//  mediation
//
//  Created by Alvarlega on 23/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "Foundation/Foundation.h"
#import "PubnativeInsightModel.h"

@protocol PubnativeInsightsManagerDelegate <NSObject>

- (void)configDidFinishWithModel:(PubnativeInsightModel *)model;

@end

@interface PubnativeInsightsManager : NSObject

+ (void)configWithAppToken:(NSString *)appToken delegate:(NSObject<PubnativeInsightsManagerDelegate> *)delegate;

@end
