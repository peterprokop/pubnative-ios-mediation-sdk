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

#pragma mark - PubnativeNetworkRequest -

#pragma mark Public

- (void)startWithAppToken:(NSString*)appToken
              placementID:(NSString*)placementID
                 delegate:(NSObject<PubnativeNetworkRequestDelegate>*)delegate
{
    if (delegate) {
        
        self.delegate = delegate;
        [self invokeDidStart];
        
        if (appToken && [appToken length] > 0 &&
            placementID && [placementID length] > 0) {
            
            //set the data
            self.appToken = appToken;
            self.placementID = placementID;
            self.currentNetworkIndex = 0;
            
            [PubnativeConfigManager configWithAppToken:appToken
                                              delegate:self];
            
        } else {
            NSError *error = [NSError errorWithDomain:@"PubnativeNetworkRequest.startWithAppToken:placementID:delegate:- Error: Invalid AppToken/PlacementID"
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        }
    } else {
        NSLog(@"PubnativeNetworkRequest.startWithAppToken:placementID:delegate:- Error: Delegate not specified");
    }
}

#pragma mark Private

- (void)startRequestWithConfig:(PubnativeConfigModel*)config
{
    //Check placements are available
    if (config && ![config isEmpty]) {
        self.config = config;
        
        PubnativePlacementModel *placement = [self.config.placements objectForKey:self.placementID];
        if (placement) {
            self.placement = placement;
            
            if (self.placement.delivery_rule && ![self.placement.delivery_rule isDisabled]) {
                //make request
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
    //Check if priority rules avaliable
    if (self.currentNetworkIndex < self.placement.priority_rules.count) {
        
        PubnativePriorityRulesModel * priorityRule = self.placement.priority_rules[self.currentNetworkIndex];
        self.currentNetworkIndex++;
        
        // Get the network code
        NSString *currentNetworkId = priorityRule.network_code;
        
        PubnativeNetworkModel *network = nil;
        
        if (currentNetworkId && [currentNetworkId length] > 0 &&
            self.config && self.config.networks) {
            
            //Associate network correponding to network code
            network = [self.config.networks objectForKey:currentNetworkId];
        }
        
        if (network) {
            // Create corresponding adapter for network
            PubnativeNetworkAdapter *adapter = [PubnativeNetworkAdapterFactory createApdaterWithNetwork:network];
            
            if (adapter) {
                //make request
                [adapter startWithDelegate:self];
                
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

#pragma mark Callback helpers

- (void)invokeDidStart
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pubnativeRequestDidStart:)]) {
        //Update request has been started
        [self.delegate pubnativeRequestDidStart:self];
    }
}

- (void)invokeDidFail:(NSError*)error
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(pubnativeRequest:didFail:)]){
        //Update request had failed
        [self.delegate pubnativeRequest:self didFail:error];
    }
    
    self.delegate = nil;
}

- (void)invokeDidLoad:(PubnativeAdModel*)ad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pubnativeRequest:didLoad:)]) {
        //Update request had succeed
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
    [self invokeDidLoad:ad];
}

- (void)adapter:(PubnativeNetworkAdapter*)adapter requestDidFail:(NSError*)error
{
    NSLog(@"PubnativeNetworkRequest.adapter:requestDidFail:- Error %@",[error domain]);
    [self doNextNetworkRequest];
}

@end
