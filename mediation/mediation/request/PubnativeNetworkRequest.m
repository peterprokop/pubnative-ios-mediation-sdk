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

- (void)startRequest
{
    if (self.config) {
        PubnativePlacementModel * placement = [self.config.placements objectForKey:self.placementKey];
        if (placement && placement.delivery_rule) {
            if (placement.delivery_rule.isActive) {
                // TODO: Need to handle the scenario
                [self startRequestWithPlacement:placement];
            } else {
                NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.startRequest- Error: Inactive placement"
                                                     code:0
                                                 userInfo:nil];
                [self invokeDidFail:error];
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.startRequest- Error: Invalid placement"
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        }
    } else {
        NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.startRequest- Error: Invalid config"
                                             code:0
                                         userInfo:nil];
        [self invokeDidFail:error];
    }
}

- (void)startRequestWithPlacement:(PubnativePlacementModel*)placement
{
    if (placement && placement.delivery_rule) {
        
        // TODO: Need to handle the scenario
        // This is related to delivery manager
        // Do next network request
        [self doNextNetworkRequestWithPlacement:placement];
    } else {
        NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.startRequestWithPlacementModel:- Error: Invalid placement"
                                             code:0
                                         userInfo:nil];
        [self invokeDidFail:error];
    }
}

- (void)doNextNetworkRequestWithPlacement:(PubnativePlacementModel*)placement
{
    if (placement &&
        placement.priority_rules &&
        placement.priority_rules.count > self.currentNetworkIndex) {
        PubnativePriorityRulesModel * protityRule = placement.priority_rules[self.currentNetworkIndex];
        NSString *currentNetworkId = protityRule.network_code;
        self.currentNetworkIndex++;
        
        if (currentNetworkId && [currentNetworkId length] > 0) {
            PubnativeNetworkModel *network = [self getNetworkForNetworkId:currentNetworkId];
            PubnativeNetworkAdapter *adapter = [PubnativeNetworkAdapterFactory createApdaterWithNetwork:network];
            if (adapter) {
                [adapter requestWithTimeout:[network.timeout intValue] delegate:self];
            } else {
                NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.doNextNetworkRequestWithPlacementModel:- Error: Invalid adapter"
                                                     code:0
                                                 userInfo:nil];
                [self invokeDidFail:error];
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.doNextNetworkRequestWithPlacementModel:- Error: Invalid network code"
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        }
    } else {
        NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.doNextNetworkRequestWithPlacementModel:- Error: Invalid/No placement model"
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
    self.config = model;
    [self startRequest];
}

- (void)configDidFailWithError:(NSError*)error
{
    // TODO: Handle config nil error by calling back the request delegate with fail
}

#pragma mark PubnativeNetworkAdapterDelegate

- (void)adapterRequestDidStart:(PubnativeNetworkAdapter*)adapter
{
    // TODO: Implementation pending
}

- (void)adapter:(PubnativeNetworkAdapter*)adapter requestDidLoad:(PubnativeAdModel*)ad
{
    // TODO: Implementation pending
}

- (void)adapter:(PubnativeNetworkAdapter*)adapter requestDidFail:(NSError*)error
{
    // TODO: Implementation pending
}

@end
