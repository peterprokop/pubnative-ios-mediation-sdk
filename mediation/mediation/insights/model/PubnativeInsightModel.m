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
    }
    return self;
}

- (BOOL)isEmpty
{
    BOOL result = YES;
    if(self.networks && [self.networks count] > 0 &&
       self.placements && [self.placements count] > 0)
    {
        result = NO;
    }
    return result;
}

@end
