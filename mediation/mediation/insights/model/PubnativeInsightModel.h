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


@property (nonatomic, strong) NSDictionary<NSString*, NSString*>                  *network;
@property (nonatomic, strong) NSDictionary<NSString*, NSArray<NSString *>*>       *attempted_networks;
@property (nonatomic, strong) NSDictionary<NSString*, NSArray*>                   *unreachable_networks;
@property (nonatomic, strong) NSDictionary<NSString*, NSArray*>                   *delivery_segment_ids;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>                  *placement_name;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>                  *pub_app_version;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>                  *pub_app_bundle_id;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>                  *os_version;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>                  *sdk_version;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>                  *connection_type; //typ “wifi” or “cellular"
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>                  *device_name;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>                  *ad_format_code;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>                  *creative_url; // Creative selected from the ad_format_code value of the config
@property (nonatomic, strong) NSDictionary<NSString*, NSNumber*>                  *video_start;
@property (nonatomic, strong) NSDictionary<NSString*, NSNumber*>                  *video_complete;
@property (nonatomic, strong) NSDictionary<NSString*, NSNumber*>                  *retry;
// User info
@property (nonatomic, strong) NSDictionary<NSString*, NSNumber*>                  *age;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>                  *education;
@property (nonatomic, strong) NSDictionary<NSString*, NSArray*>                   *interests;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>                  *gender;
@property (nonatomic, strong) NSDictionary<NSString*, NSNumber*>                  *iap; // In app purchase enabled, Just open it for the user to fill
@property (nonatomic, strong) NSDictionary<NSString*, NSNumber*>                  *iap_total; // In app purchase total spent, just open for the user to fill

@end
