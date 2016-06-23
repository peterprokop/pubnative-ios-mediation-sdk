//
//  PubnativeInsightModel.h
//  mediation
//
//  Created by Alvarlega on 23/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubnativeJSONModel.h"
#import "PubnativeNetworkModel.h"
#import "PubnativePlacementModel.h"

extern NSString * const CONFIG_GLOBAL_KEY_REFRESH;
extern NSString * const CONFIG_GLOBAL_KEY_IMPRESSION_TIMEOUT;
extern NSString * const CONFIG_GLOBAL_KEY_CONFIG_URL;
extern NSString * const CONFIG_GLOBAL_KEY_IMPRESSION_BEACON;
extern NSString * const CONFIG_GLOBAL_KEY_CLICK_BEACON;
extern NSString * const CONFIG_GLOBAL_KEY_REQUEST_BEACON;

@interface PubnativeInsightModel : PubnativeJSONModel

@property (nonatomic, strong) NSDictionary<NSString*, NSObject*>                  *globals;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>                  *request_params;
@property (nonatomic, strong) NSDictionary<NSString*, PubnativeNetworkModel*>     *networks;
@property (nonatomic, strong) NSDictionary<NSString*, PubnativePlacementModel*>   *placements;

- (BOOL)isEmpty;

@end
