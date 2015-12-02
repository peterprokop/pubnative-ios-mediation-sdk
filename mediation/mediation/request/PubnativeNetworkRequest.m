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

@property (nonatomic, strong)NSString                                   *placementID;
@property (nonatomic, strong)NSString                                   *appToken;
@property (nonatomic, strong)PubnativeConfigModel                       *config;
@property (nonatomic, strong)PubnativePlacementModel                    *placement;
@property (nonatomic, strong)NSObject <PubnativeNetworkRequestDelegate> *delegate;
@property (nonatomic, assign)int                                        currentNetworkIndex;

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
            if (self.placement.delivery_rule && [self.placement.delivery_rule isActive]) {
                [self doNextNetworkRequest];
            } else {
                NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.startRequestWithConfig:- Error: Invalid/Inactive placement delivery rule"
                                                     code:0
                                                 userInfo:nil];
                [self invokeDidFail:error];
            }
        } else {
            NSString *errorMessage = [NSString stringWithFormat:
                                      @"PubnativeNetworkRequest.startRequestWithConfig:- Error: placementID: %@ not valid",
                                      self.placementID];
            NSError *error = [NSError errorWithDomain:errorMessage
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
                [adapter startRequestWithDelegate:self];
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(pubnativeRequestDidStart:)]) {
        [self.delegate pubnativeRequestDidStart:self];
    }
}

- (void)invokeDidFail:(NSError*)error
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(pubnativeRequest:didFail:)]){
        [self.delegate pubnativeRequest:self didFail:error];
    }
    self.delegate = nil;
}

- (void)invokeDidLoad:(PubnativeAdModel*)ad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pubnativeRequest:didLoad:)]) {
        [self.delegate pubnativeRequest:self didLoad:ad];
    }
    self.delegate = nil;    
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
