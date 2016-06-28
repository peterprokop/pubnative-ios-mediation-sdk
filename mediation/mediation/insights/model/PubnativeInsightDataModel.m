//
//  PubnativeInsightDataModel.m
//  mediation
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PubnativeInsightDataModel.h"

NSString * const kPubnativeInsightDataModelConnectionTypeWiFi = @"wifi";
NSString * const kPubnativeInsightDataModelConnectionTypeCellular = @"cellular";

@implementation PubnativeInsightDataModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.retry = @0;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    if (self) {
        self.network = [coder decodeObjectForKey:@"network"];
        self.attempted_networks = [coder decodeObjectForKey:@"attempted_networks"];
        self.unreachable_networks = [coder decodeObjectForKey:@"unreachable_networks"];
        self.delivery_segment_ids = [coder decodeObjectForKey:@"delivery_segment_ids"];
        self.networks = [coder decodeObjectForKey:@"networks"];
        self.placement_name = [coder decodeObjectForKey:@"placement_name"];
        self.pub_app_version = [coder decodeObjectForKey:@"pub_app_version"];
        self.pub_app_bundle_id = [coder decodeObjectForKey:@"pub_app_bundle_id"];
        self.os_version = [coder decodeObjectForKey:@"os_version"];
        self.sdk_version = [coder decodeObjectForKey:@"sdk_version"];
        self.user_uid = [coder decodeObjectForKey:@"user_uid"];
        self.connection_type = [coder decodeObjectForKey:@"connection_type"];
        self.device_name = [coder decodeObjectForKey:@"device_name"];
        self.ad_format_code = [coder decodeObjectForKey:@"ad_format_code"];
        self.creative_url = [coder decodeObjectForKey:@"creative_url"];
        self.video_start = [coder decodeObjectForKey:@"video_start"];
        self.video_complete = [coder decodeObjectForKey:@"video_complete"];
        self.retry = [coder decodeObjectForKey:@"retry"];
        self.age = [coder decodeObjectForKey:@"age"];
        self.education = [coder decodeObjectForKey:@"education"];
        self.interests = [coder decodeObjectForKey:@"interests"];
        self.gender = [coder decodeObjectForKey:@"gender"];
        self.keywords = [coder decodeObjectForKey:@"keywords"];
        self.iap = [coder decodeObjectForKey:@"iap"];
        self.iap_total = [coder decodeObjectForKey:@"iap_total"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    
    [coder encodeObject:self.network forKey:@"network"];
    [coder encodeObject:self.attempted_networks forKey:@"attempted_networks"];
    [coder encodeObject:self.unreachable_networks forKey:@"unreachable_networks"];
    [coder encodeObject:self.delivery_segment_ids forKey:@"delivery_segment_ids"];
    [coder encodeObject:self.networks forKey:@"networks"];
    [coder encodeObject:self.placement_name forKey:@"placement_name"];
    [coder encodeObject:self.pub_app_version forKey:@"pub_app_version"];
    [coder encodeObject:self.pub_app_bundle_id forKey:@"pub_app_bundle_id"];
    [coder encodeObject:self.os_version forKey:@"os_version"];
    [coder encodeObject:self.sdk_version forKey:@"sdk_version"];
    [coder encodeObject:self.user_uid forKey:@"user_uid"];
    [coder encodeObject:self.connection_type forKey:@"connection_type"];
    [coder encodeObject:self.device_name forKey:@"device_name"];
    [coder encodeObject:self.ad_format_code forKey:@"ad_format_code"];
    [coder encodeObject:self.creative_url forKey:@"creative_url"];
    [coder encodeObject:self.video_start forKey:@"video_start"];
    [coder encodeObject:self.video_complete forKey:@"video_complete"];
    [coder encodeObject:self.retry forKey:@"retry"];
    [coder encodeObject:self.age forKey:@"age"];
    [coder encodeObject:self.education forKey:@"education"];
    [coder encodeObject:self.interests forKey:@"interests"];
    [coder encodeObject:self.gender forKey:@"gender"];
    [coder encodeObject:self.keywords forKey:@"keywords"];
    [coder encodeObject:self.iap forKey:@"iap"];
    [coder encodeObject:self.iap_total forKey:@"iap_total"];
}

- (void)addAttemptedNetworkWithNetworkCode:(NSString *)networkCode
{
    if (networkCode && networkCode.length > 0) {
        if (self.attempted_networks) {
            self.attempted_networks = [[NSArray<NSString*> alloc] init];
        }
        NSMutableArray *stringArray = [self.attempted_networks mutableCopy];
        [stringArray addObject:networkCode];
        self.attempted_networks = stringArray;
    }
}

- (void)addUnreachableNetworkWithNetworkCode:(NSString *)networkCode
{
    if (networkCode && networkCode.length > 0) {
        if (self.unreachable_networks) {
            self.unreachable_networks = [[NSArray<NSString*> alloc] init];
        }
        NSMutableArray *stringArray = [self.unreachable_networks mutableCopy];
        [stringArray addObject:networkCode];
        self.unreachable_networks = stringArray;
    }
}

- (void)addNetworkWithPriorityRuleModel:(PubnativePriorityRulesModel *)priorityRuleModel responseTime:(NSNumber *)responseTime crashModel:(PubnativeInsightCrashModel *)crashModel
{
    if (priorityRuleModel) {
        if (!self.networks) {
            self.networks = [[NSArray<PubnativeInsightNetworkModel*> alloc] init];
        }
        PubnativeInsightNetworkModel *networkModel = [[PubnativeInsightNetworkModel alloc] init];
        networkModel.code = priorityRuleModel.network_code;
        networkModel.priority_rule_id = priorityRuleModel.identifier;
        networkModel.priority_segment_ids = priorityRuleModel.segment_ids;
        networkModel.response_time = responseTime;
        if (crashModel) {
            networkModel.crash_report = crashModel;
        }
        NSMutableArray *networksArray = [self.networks mutableCopy];
        [networksArray addObject:networkModel];
        self.networks = networksArray;
    }
}

@end