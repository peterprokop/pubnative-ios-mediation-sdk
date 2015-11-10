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

@property (strong, nonatomic) NSString                              *placementKey;
@property (strong, nonatomic) PubnativeConfigModel                  *config;
@property (strong, nonatomic) PubnativePlacementModel               *placement;
@property (weak, nonatomic)   id <PubnativeNetworkRequestDelegate>  delegate;
@property                     int                                   currentNetworkIndex;

@end

@implementation PubnativeNetworkRequest

#pragma mark - Network Request -

- (void)startRequestWithAppToken:(NSString*)appToken
                    placementKey:(NSString*)placementKey
                        delegate:(id<PubnativeNetworkRequestDelegate>)delegate
{
    if (delegate) {
        self.delegate = delegate;
        [self invokeDidStart];
        if (appToken && [appToken length] > 0 &&
            placementKey && [placementKey length] > 0) {
            self.placementKey = placementKey;
            [PubnativeConfigManager configWithAppToken:appToken
                                              delegate:self];
        } else {
            NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.startRequestWithAppToken:placementKey:delegate:- Error: Invalid AppToken/PlacementKey"
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        }
    } else {
        NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.startRequestWithAppToken:placementKey:delegate:- Error: Delegate not specified"
                                             code:0
                                         userInfo:nil];
        [self invokeDidFail:error];
    }
}

- (void)startRequestWithConfig:(PubnativeConfigModel*)model
{
    self.config = model;
    if (self.config) {
        self.placement = [self.config.placements objectForKey:self.placementKey];
        if (self.placement && self.placement.delivery_rule) {
            if (self.placement.delivery_rule.isActive) {
                [self startRequest];
            } else {
                NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.startRequestWithConfig:- Error: Inactive placement"
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

- (void)startRequest
{
    if (self.placement && self.placement.delivery_rule) {
        // TODO: Need to handle the scenario
        // This is related to delivery manager
        // Do next network request
        [self doNextNetworkRequest];
    } else {
        NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.startRequest- Error: Invalid placement"
                                             code:0
                                         userInfo:nil];
        [self invokeDidFail:error];
    }
}

- (void)doNextNetworkRequest
{
    if (self.placement &&
        self.placement.priority_rules &&
        self.placement.priority_rules.count > self.currentNetworkIndex) {
        PubnativePriorityRulesModel * protityRule = self.placement.priority_rules[self.currentNetworkIndex];
        NSString *currentNetworkId = protityRule.network_code;
        self.currentNetworkIndex++;
        
        if (currentNetworkId && [currentNetworkId length] > 0) {
            PubnativeNetworkModel *network = [self getNetworkForNetworkId:currentNetworkId];
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
        NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.doNextNetworkRequest- Error: Invalid/No placement model"
                                             code:0
                                         userInfo:nil];
        [self invokeDidFail:error];
    }
}

#pragma mark - Network Model
- (PubnativeNetworkModel*)getNetworkForNetworkId:(NSString*)networkId
{
    PubnativeNetworkModel *network = nil;
    if (networkId && [networkId length] > 0) {
        if (self.config && self.config.networks) {
            network = [self.config.networks objectForKey:networkId];
        }
    }
    return network;
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
