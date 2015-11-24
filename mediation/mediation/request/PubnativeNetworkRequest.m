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

@interface PubnativeNetworkRequest () <PubnativeNetworkAdapterDelegate, PubnativeConfigManagerDelegate>

@property (nonatomic, strong)NSString                              *placementID;
@property (nonatomic, strong)NSString                              *appToken;
@property (nonatomic, strong)PubnativeConfigModel                  *config;
@property (nonatomic, strong)PubnativePlacementModel               *placement;
@property (nonatomic, weak)  id <PubnativeNetworkRequestDelegate>  delegate;
@property (nonatomic, assign)int                                   currentNetworkIndex;

@end

@implementation PubnativeNetworkRequest

#pragma mark - Network Request -

- (void)startRequestWithAppToken:(NSString*)appToken
                     placementID:(NSString*)placementID
                        delegate:(NSObject<PubnativeNetworkRequestDelegate>*)delegate
{
    if (delegate) {
        self.delegate = delegate;
        [self invokeDidStart];
        if (appToken && [appToken length] > 0 &&
            placementID && [placementID length] > 0) {
            self.appToken = appToken;
            self.placementID = placementID;
            self.currentNetworkIndex = 0;
            [PubnativeConfigManager configWithAppToken:appToken
                                              delegate:self];
        } else {
            NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.startRequestWithAppToken:placementID:delegate:- Error: Invalid AppToken/PlacementID"
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        }
    } else {
        NSLog(@"PubnativeNetworkRequest.startRequestWithAppToken:placementID:delegate:- Error: Delegate not specified");
    }
}

- (void)startRequestWithConfig:(PubnativeConfigModel*)config
{
    if (config && ![config isEmpty]) {
        self.config = config;
        PubnativePlacementModel *placement = [self.config.placements objectForKey:self.placementID];
        if (placement) {
            self.placement = placement;
            if (self.placement.delivery_rules && [self.placement.delivery_rules isActive]) {
                [self doNextNetworkRequest];
            } else {
                NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.startRequestWithConfig:- Error: Invalid/Inactive delivery_rules"
                                                     code:0
                                                 userInfo:nil];
                [self invokeDidFail:error];
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.startRequestWithConfig:- Error: Invalid placement"
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        }
    } else {
        NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.startRequestWithConfig:- Error: Invalid config"
                                             code:0
                                         userInfo:nil];
        [self invokeDidFail:error];
    }
}

- (void)doNextNetworkRequest
{
    if (self.currentNetworkIndex < self.placement.priority_rules.count) {
        PubnativePriorityRulesModel * priorityRule = self.placement.priority_rules[self.currentNetworkIndex];
        self.currentNetworkIndex++;
        NSString *currentNetworkId = priorityRule.network_code;
        PubnativeNetworkModel *network = nil;
        if (currentNetworkId && [currentNetworkId length] > 0 &&
            self.config && self.config.networks) {
            network = [self.config.networks objectForKey:currentNetworkId];
        }
        if (network) {
            PubnativeNetworkAdapter *adapter = [PubnativeNetworkAdapterFactory createApdaterWithNetwork:network];
            if (adapter) {
                [adapter requestWithTimeout:[network.timeout intValue] delegate:self];
            } else {
                NSLog(@"PubnativeNetworkRequest.doNextNetworkRequest- Error: Invalid adapter");
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
        [self invokeDidFail:error];
    }
}

#pragma mark - Network Request Status -

- (void)invokeDidStart
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidStart:)]) {
        [self.delegate requestDidStart:self];
    }
}

- (void)invokeDidFail:(NSError*)error
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(request:didFail:)]){
        [self.delegate request:self didFail:error];
    }
}

- (void)invokeDidLoad:(PubnativeAdModel*)ad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(request:didLoad:)]) {
        [self.delegate request:self didLoad:ad];
    }
}

#pragma mark - CALLBACKS -

#pragma mark PubnativeConfigManagerDelegate

- (void)configDidFinishWithModel:(PubnativeConfigModel*)model
{
    [self startRequestWithConfig:model];
}

- (void)configDidFailWithError:(NSError*)error
{
    [self invokeDidFail:error];
}

#pragma mark PubnativeNetworkAdapterDelegate

- (void)adapterRequestDidStart:(PubnativeNetworkAdapter*)adapter
{
    //Do nothing
}

- (void)adapter:(PubnativeNetworkAdapter*)adapter requestDidLoad:(PubnativeAdModel*)ad
{
    [self invokeDidLoad:ad];
}

- (void)adapter:(PubnativeNetworkAdapter*)adapter requestDidFail:(NSError*)error
{
    NSLog(@"PubnativeNetworkRequest.adapter:requestDidFail:- Error %@",[error domain]);
    [self doNextNetworkRequest];
}

@end
