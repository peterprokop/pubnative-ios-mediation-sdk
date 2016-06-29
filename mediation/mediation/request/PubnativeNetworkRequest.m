//
//  PubnativeNetworkRequest.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeNetworkRequest.h"
#import "PubnativeConfigManager.h"
#import "PubnativeNetworkAdapterFactory.h"
#import "PubnativeDeliveryRuleModel.h"
#import "PubnativeDeliveryManager.h"
#import "PubnativeAdModel.h"
#import "PubnativeInsightModel.h"
#import "AdSupport/ASIdentifierManager.h"


NSString * const PNTrackingAppTokenKey  = @"app_token";
NSString * const PNTrackingRequestIDKey = @"reqid";
NSString * const kPubnativeNetworkRequestStoredConfigKey = @"net.pubnative.mediation.PubnativeConfigManager.configJSON";

@interface PubnativeNetworkRequest () <PubnativeNetworkAdapterDelegate, PubnativeConfigManagerDelegate>

@property (nonatomic, strong)NSString                                   *placementName;
@property (nonatomic, strong)NSString                                   *appToken;
@property (nonatomic, strong)NSString                                   *requestID;
@property (nonatomic, strong)PubnativeConfigModel                       *config;
@property (nonatomic, strong)PubnativeAdModel                           *ad;
@property (nonatomic, strong)NSObject <PubnativeNetworkRequestDelegate> *delegate;
@property (nonatomic, strong)NSMutableDictionary<NSString*, NSString*>  *requestParameters;
@property (nonatomic, assign)NSInteger                                  currentNetworkIndex;
@property (nonatomic, assign)BOOL                                       isRunning;
@property (nonatomic, strong)PubnativeInsightModel                      *insight;


@end

@implementation PubnativeNetworkRequest

#pragma mark - PubnativeNetworkRequest -

#pragma mark Public

- (void)startWithAppToken:(NSString*)appToken
            placementName:(NSString*)placementName
                 delegate:(NSObject<PubnativeNetworkRequestDelegate>*)delegate
{
    if (delegate) {
        
        self.delegate = delegate;
        
        if(self.isRunning) {
            
            NSLog(@"Request already running, dropping the call");
        
        } else {
        
            self.isRunning = YES;
            [self invokeDidStart];
        
            if (appToken && [appToken length] > 0 &&
                placementName && [placementName length] > 0) {
            
                //set the data
                self.appToken = appToken;
                self.placementName = placementName;
                self.currentNetworkIndex = 0;
                self.requestID = [[NSUUID UUID] UUIDString];
            
                [PubnativeConfigManager configWithAppToken:appToken
                                                  delegate:self];
            
            } else {
                NSError *error = [NSError errorWithDomain:@"Error: Invalid AppToken/PlacementID"
                                                     code:0
                                                 userInfo:nil];
                [self invokeDidFail:error];
            }
        }
    } else {
        NSLog(@"Delegate not specified, droping this call");
    }
}

- (void)setParameterWithKey:(NSString*)key value:(NSString*)value {
    
    if(self.requestParameters == nil){
        self.requestParameters = [NSMutableDictionary dictionary];
    }
    [self.requestParameters setObject:value forKey:key];
}

#pragma mark Private

- (void)startRequestWithConfig:(PubnativeConfigModel*)config
{
    //Check placements are available
    self.config = config;
    
    if ([self.config isEmpty]) {
        
        NSError *error = [NSError errorWithDomain:@"Error: Empty config retrieved by the server"
                                             code:0
                                         userInfo:nil];
        [self invokeDidFail:error];
        
    } else {
        
        PubnativePlacementModel *placement = [self.config placementWithName:self.placementName];
        if (placement == nil) {
            
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Error: placement with name %@ not found in config", self.placementName]
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
            
        } else if (placement.delivery_rule == nil || placement.priority_rules == nil) {
            
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Error: config contains null elements for placement %@ ", self.placementName]
                                                          code:0
                                                      userInfo:nil];
            [self invokeDidFail:error];
            
        } else if ([placement.delivery_rule isDisabled]) {
            
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Error: placement %@ is disabled", self.placementName]
                                                          code:0
                                                      userInfo:nil];
            [self invokeDidFail:error];
            
        } else if (placement.priority_rules.count == 0) {
            
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Error: no networks configured for placement %@", self.placementName]
                                                          code:0
                                                      userInfo:nil];
            [self invokeDidFail:error];
            
        } else {
            
            [self startTracking];
        }
    }
}


- (void)startTracking
{
    PubnativeConfigModel *storedModel = [PubnativeNetworkRequest getStoredConfig];
    PubnativePlacementModel *placementModel = [self.config placementWithName:self.placementName];
    PubnativeDeliveryRuleModel *deliveryRuleModel = placementModel.delivery_rule;
    NSString *impressionUrl = (NSString*)[storedModel.globals objectForKey:CONFIG_GLOBAL_KEY_IMPRESSION_BEACON];
    NSString *requestUrl = (NSString*)[storedModel.globals objectForKey:CONFIG_GLOBAL_KEY_REQUEST_BEACON];
    NSString *clickUrl = (NSString*)[storedModel.globals objectForKey:CONFIG_GLOBAL_KEY_CLICK_BEACON];
    self.insight = [[PubnativeInsightModel alloc] init];
    [self.insight setImpressionInsightUrl:impressionUrl];
    [self.insight setRequestInsightUrl:requestUrl];
    [self.insight setClickInsightUrl:clickUrl];
    [self.insight.data setPlacement_name:self.placementName];
    [self.insight.data setDelivery_segment_ids:deliveryRuleModel.segment_ids];
    [self.insight.data setAd_format_code:placementModel.ad_format_code];
    [self.insight setParams:@{@"app_token":self.appToken, @"reqid":self.requestID}];
    [self.insight.data setUser_uid:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    // TODO: Add request_params
    [self startRequest];
}

- (void)startRequest {
    
    PubnativeDeliveryRuleModel *deliveryRuleModel = [self.config placementWithName:self.placementName].delivery_rule;

        
        BOOL needsNewAd = YES;
        
        NSDate *pacingDate = [PubnativeDeliveryManager pacingDateForPlacementName:self.placementName];
        NSDate *currentdate = [NSDate date];
        NSTimeInterval intervalInSeconds = [currentdate timeIntervalSinceDate:pacingDate];
        NSTimeInterval elapsedMinutes = (intervalInSeconds/60);
        NSTimeInterval elapsedHours = (intervalInSeconds/3600);
        
        // If there is a pacing cap set and the elapsed time still didn't time for that pacing cap, we don't refresh
        if (([deliveryRuleModel.pacing_cap_minute doubleValue] > 0 && [deliveryRuleModel.pacing_cap_minute doubleValue] < elapsedMinutes)
            || ([deliveryRuleModel.pacing_cap_hour doubleValue] > 0 && [deliveryRuleModel.pacing_cap_hour doubleValue] < elapsedHours)){
            
            needsNewAd = NO;
        }
        
        if(needsNewAd) {
            
            [self doNextNetworkRequest];
            
        } else if(self.ad) {
            
            [self invokeDidLoad:self.ad];
            
        } else {
            
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Error: (pacing_cap) too many ads for placement %@", self.placementName]
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        }
    
}

- (void)doNextNetworkRequest
{
    //Check if priority rules avaliable
    PubnativePriorityRuleModel *priorityRule = [self.config priorityRuleWithPlacementName:self.placementName
                                                                                 andIndex:self.currentNetworkIndex];
    if (priorityRule) {
        
        self.currentNetworkIndex++;
        PubnativeNetworkModel *network = [self.config networkWithID:priorityRule.network_code];
        if (network) {
            PubnativeNetworkAdapter *adapter = [PubnativeNetworkAdapterFactory createApdaterWithAdapterName:network.adapter];
            if (adapter) {
                
                NSMutableDictionary<NSString*, NSString*> *extras = [NSMutableDictionary dictionary];
                [extras setObject:self.requestID forKey:PNTrackingRequestIDKey];
                if(self.requestParameters){
                    [extras setDictionary:self.requestParameters];
                }
                [adapter startWithData:network.params
                               timeout:[network.timeout doubleValue]
                                extras:extras
                              delegate:self];
                
            } else {
                
                NSLog(@"PubnativeNetworkRequest.doNextNetworkRequest- Error: Invalid adapter");
                // TODO: Add exception
                [self.insight trackUnreachableNetworkWithPriorityRuleModel:priorityRule responseTime:0 exception:nil];
                [self doNextNetworkRequest];
            }
        } else {
            
            NSLog(@"PubnativeNetworkRequest.doNextNetworkRequest- Error: Invalid network code");
            [self doNextNetworkRequest];
        }
        
    } else {
        
        NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.doNextNetworkRequest- Error: No fill"
                                             code:0
                                         userInfo:nil];
        [self.insight sendRequestInsight];
        [self invokeDidFail:error];
    }
}

#pragma mark Callback helpers

- (void)invokeDidStart
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pubnativeRequestDidStart:)]) {
        [self.delegate pubnativeRequestDidStart:self];
    }
}

- (void)invokeDidFail:(NSError*)error
{
    self.isRunning = false;
    if(self.delegate && [self.delegate respondsToSelector:@selector(pubnativeRequest:didFail:)]){
        [self.delegate pubnativeRequest:self didFail:error];
    }
    self.delegate = nil;
}

- (void)invokeDidLoad:(PubnativeAdModel*)ad
{
    self.isRunning = false;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pubnativeRequest:didLoad:)]) {
        [self.delegate pubnativeRequest:self didLoad:ad];
    }
    self.delegate = nil;    
}

#pragma mark - CALLBACKS -

#pragma mark PubnativeConfigManagerDelegate

- (void)configDidFinishWithModel:(PubnativeConfigModel*)model
{
    if(model) {
        [self startRequestWithConfig:model];
    } else {
        NSError *configError = [NSError errorWithDomain:@"PubnativeNetworkRequest - config error" code:0 userInfo:nil];
        [self invokeDidFail:configError];
    }
}

#pragma mark PubnativeNetworkAdapterDelegate

- (void)adapterRequestDidStart:(PubnativeNetworkAdapter*)adapter
{
    //Do nothing
}

- (void)adapter:(PubnativeNetworkAdapter*)adapter requestDidLoad:(PubnativeAdModel*)ad
{
    [PubnativeDeliveryManager updatePacingDateForPlacementName:self.placementName];
    // TODO: Set insight data before invoke loading
    // TODO: remove setting the app token since it should be inside the insight data
    if (!ad) {
        [self doNextNetworkRequest];
    } else {
        // Track succeded network
        [self.insight sendRequestInsight];
        // Default tracking data
        ad.appToken = self.appToken;
        [ad setInsightModel:self.insight];
        [self invokeDidLoad:ad];
    }
}

- (void)adapter:(PubnativeNetworkAdapter*)adapter requestDidFail:(NSError*)error
{
    NSLog(@"PubnativeNetworkRequest.adapter:requestDidFail:- Error %@",[error domain]);
    [self doNextNetworkRequest];
}

+ (PubnativeConfigModel*)getStoredConfig
{
    PubnativeConfigModel *result;
    
    NSData *jsonData = [[NSUserDefaults standardUserDefaults] objectForKey:kPubnativeNetworkRequestStoredConfigKey];
    
    if(jsonData){
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                       options:NSJSONReadingMutableContainers
                                                                         error:nil];
        result = [PubnativeConfigModel modelWithDictionary:jsonDictionary];
    }
    return result;
}

@end
