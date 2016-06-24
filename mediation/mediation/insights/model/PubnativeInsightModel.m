//
//  PubnativeInsightModel.m
//  mediation
//
//  Created by Alvarlega on 23/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PubnativeInsightModel.h"

NSString * const CONFIG_GLOBAL_KEY_REFRESH              = @"refresh";
NSString * const CONFIG_GLOBAL_KEY_IMPRESSION_TIMEOUT   = @"impression_timeout";
NSString * const CONFIG_GLOBAL_KEY_CONFIG_URL           = @"config_url";
NSString * const CONFIG_GLOBAL_KEY_IMPRESSION_BEACON    = @"impression_beacon";
NSString * const CONFIG_GLOBAL_KEY_CLICK_BEACON         = @"click_beacon";
NSString * const CONFIG_GLOBAL_KEY_REQUEST_BEACON       = @"request_beacon";

@implementation PubnativeInsightModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if(self){
        self.globals = dictionary[@"globals"];
        self.request_params = dictionary[@"request_params"];
        self.networks = [PubnativeNetworkModel parseDictionaryValues:dictionary[@"networks"]];
        self.placements = [PubnativePlacementModel parseDictionaryValues:dictionary[@"placements"]];
        self.network = dictionary[@"network"];
        self.attempted_networks = dictionary[@"attempted_networks"];
        self.unreachable_networks = dictionary[@"unreachable_networks"];
        self.delivery_segment_ids = dictionary[@"delivery_segment_ids"];
        self.placement_name = dictionary[@"placement_name"];
        self.pub_app_version = dictionary[@"pub_app_version"];
        self.pub_app_bundle_id = dictionary[@"pub_app_bundle_id"];
        self.os_version = dictionary[@"os_version"];
        self.sdk_version = dictionary[@"sdk_version"];
        self.connection_type = dictionary[@"connection_type"];
        self.device_name = dictionary[@"device_name"];
        self.ad_format_code = dictionary[@"ad_format_code"];
        self.creative_url = dictionary[@"creative_url"];
        self.video_start = dictionary[@"video_start"];
        self.video_complete = dictionary[@"video_complete"];
        self.retry = dictionary[@"retry"];
        self.age = dictionary[@"age"];
        self.education = dictionary[@"education"];
        self.interests = dictionary[@"interests"];
        self.gender = dictionary[@"gender"];
        self.iap = dictionary[@"iap"];
        self.iap_total = dictionary[@"iap_total"];
    }
    return self;
}

@end
