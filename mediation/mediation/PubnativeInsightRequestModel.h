//
//  PubnativeInsightRequestModel.h
//  mediation
//
//  Created by Alvarlega on 23/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "Foundation/Foundation.h"
#import "PubnativeInsightsManager.h"
#import "PubnativeInsightModel.h"

@interface PubnativeInsightRequestModel : NSObject

@property (nonatomic, strong) NSString                                      *appToken;
@property (nonatomic, strong) NSString                                      *baseUrl;
@property (nonatomic, strong) NSObject<PubnativeInsightModel>               *dataModel;
@property (nonatomic, strong) NSObject<PubnativeInsightsManagerDelegate>    *delegate;

@end
