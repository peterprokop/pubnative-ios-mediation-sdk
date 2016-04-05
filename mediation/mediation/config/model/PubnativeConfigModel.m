//
//  PubnativeConfigModel.m
//  mediation
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeConfigModel.h"

NSString * const CONFIG_GLOBAL_KEY_REFRESH              = @"refresh";
NSString * const CONFIG_GLOBAL_KEY_IMPRESSION_TIMEOUT   = @"impression_timeout";
NSString * const CONFIG_GLOBAL_KEY_CONFIG_URL           = @"config_url";
NSString * const CONFIG_GLOBAL_KEY_IMPRESSION_BEACON    = @"impression_beacon";
NSString * const CONFIG_GLOBAL_KEY_CLICK_BEACON         = @"click_beacon";
NSString * const CONFIG_GLOBAL_KEY_REQUEST_BEACON       = @"request_beacon";

@interface PubnativeConfigModel ()

@property (nonatomic, strong) NSDictionary *dictionaryValue;

@end

@implementation PubnativeConfigModel

+ (instancetype)modelWithDictionary:(NSDictionary*)dictionary
{
    PubnativeConfigModel *result = nil;
    if(dictionary){
        result = [[PubnativeConfigModel alloc] init];
        result.globals = dictionary[@"globals"];
        result.request_params = dictionary[@"request_params"];
        
        NSDictionary *networks = dictionary[@"networks"];
        NSMutableDictionary *parsedNetworks = nil;
        if(networks){
            parsedNetworks = [NSMutableDictionary dictionary];
            for (NSString *key in [networks allKeys]) {
                NSDictionary *value = networks[key];
                PubnativeNetworkModel *parsed = [PubnativeNetworkModel modelWithDictionary:value];
                [parsedNetworks setObject:parsed forKey:key];
            }
        }
        result.networks = parsedNetworks;
        
        NSDictionary *placements = dictionary[@"placements"];
        NSMutableDictionary *parsedPlacements = nil;
        if(placements){
            parsedPlacements = [NSMutableDictionary dictionary];
            for (NSString *key in [networks allKeys]) {
                NSDictionary *value = placements[key];
                PubnativePlacementModel *parsed = [PubnativePlacementModel modelWithDictionary:value];
                [parsedPlacements setObject:parsed forKey:key];
            }
        }
        result.placements = parsedPlacements;
    }
    return result;
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

- (NSDictionary*)toDictionary
{
    return self.dictionaryValue;
}

@end
