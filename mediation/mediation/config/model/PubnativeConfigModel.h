//
//  PubnativeConfigModel.h
//  mediation
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "PubnativeNetworkModel.h"
#import "PubnativePlacementModel.h"

extern NSString * const CONFIG_GLOBAL_KEY_REFRESH;
extern NSString * const CONFIG_GLOBAL_KEY_IMPRESSION_TIMEOUT;
extern NSString * const CONFIG_GLOBAL_KEY_CONFIG_URL;
extern NSString * const CONFIG_GLOBAL_KEY_IMPRESSION_BEACON;
extern NSString * const CONFIG_GLOBAL_KEY_CLICK_BEACON;
extern NSString * const CONFIG_GLOBAL_KEY_REQUEST_BEACON;

@interface PubnativeConfigModel : JSONModel

@property (nonatomic, strong) NSDictionary *globals;
@property (nonatomic, strong) NSDictionary *request_params;
@property (nonatomic, strong) NSDictionary *networks;
@property (nonatomic, strong) NSDictionary *placements;

- (BOOL)isEmpty;

@end
