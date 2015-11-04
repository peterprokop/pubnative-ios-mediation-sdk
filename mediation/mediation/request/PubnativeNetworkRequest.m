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
#import "NSString+PubnativeStringUtil.h"

@interface PubnativeNetworkRequest ()<PubnativeNetworkAdapterDelegate, PubnativeConfigManagerDelegate>

@property(strong,nonatomic)NSString             *placementKey;
@property(strong,nonatomic)PubnativeConfigModel *configModel;
@property int                                   currentNetworkIndex;

@end

@implementation PubnativeNetworkRequest

#pragma mark - Network Request -

- (void) startRequestWithAppToken:(NSString*)appToken andPlacement:(NSString*)placementKey
{
    NSError *error = nil;
    
    if (self.delegate) {
    
        [self invokeStart];
        
        if (appToken && ![appToken isEmptyString] && placementKey && ![placementKey isEmptyString]) {
            
            self.placementKey = placementKey;
            
            [PubnativeConfigManager configWithAppToken:appToken
                                              delegate:self];
        } else {
            
            error = [NSError errorWithDomain:NSLocalizedString(@"PubnativeNetworkRequest : Error while fetching appToken and placementKey", @"") code:0 userInfo:nil];
            
        }
        
    } else {
        
        error = [NSError errorWithDomain:NSLocalizedString(@"PubnativeNetworkRequest : Error no delegate specified, dropping the call", @"") code:0 userInfo:nil];

    }
    
    if (error) {
        
        [self invokeCompletionWithError:error];
        
    }
}

- (void) startRequest
{
    NSError *error = nil;
    
    if (self.configModel) {
        
        PubnativePlacementModel * placementModel = [self.configModel.placements objectForKey:self.placementKey];
        
        if (placementModel && placementModel.delivery_rule) {
            
            if (placementModel.delivery_rule.isActive) {
                
                // TODO: Need to handle the scenario
                [self startRequestWithPlacementModel:placementModel];
                
            } else {
                
                error = [NSError errorWithDomain:NSLocalizedString(@"PubnativeNetworkRequest : Error while making request : placement_id not active", @"") code:0 userInfo:nil];
                
            }
            
        } else {
            
            error = [NSError errorWithDomain:NSLocalizedString(@"PubnativeNetworkRequest : Error while making request invalid placementModel retrieved", @"") code:0 userInfo:nil];
            
        }
        
    } else {
        
        error = [NSError errorWithDomain:NSLocalizedString(@"PubnativeNetworkRequest : Error while making request invalid config retrieved", @"") code:0 userInfo:nil];
        
    }
    
    if (error) {
        
        [self invokeCompletionWithError:error];
        
    }
    
}

- (void) startRequestWithPlacementModel:(PubnativePlacementModel *)placementModel
{
    NSError *error = nil;
    
    if (placementModel && placementModel.delivery_rule) {
        
        // TODO: Need to handle the scenario
        // This is related to delivery manager
        // Do next network request
        [self doNextNetworkRequestWithPlacementModel:placementModel];
        
    } else {
        
        error = [NSError errorWithDomain:NSLocalizedString(@"PubnativeNetworkRequest : Error while making request invalid placement model retrieved", @"") code:0 userInfo:nil];
        
    }
    
    if (error) {
        
        [self invokeCompletionWithError:error];
        
    }
}

- (void) doNextNetworkRequestWithPlacementModel:(PubnativePlacementModel *)placementModel{
    
    NSError *error = nil;
    
    if (placementModel && placementModel.priority_rules && placementModel.priority_rules.count > self.currentNetworkIndex) {
        
        PubnativePriorityRulesModel * protityRuleModel = placementModel.priority_rules[self.currentNetworkIndex];
        NSString *currentNetworkId = protityRuleModel.network_code;
        self.currentNetworkIndex++;
        
        if (currentNetworkId && ![currentNetworkId isEmptyString]) {
            
            PubnativeNetworkModel *networkModel = [self getNetworkModelForNetworkId:currentNetworkId];
            PubnativeNetworkAdapter *adapter = [PubnativeNetworkAdapterFactory createApdaterWithNetworkModel:networkModel];
            
            if (adapter) {
                
                [adapter doRequestWithTimeout:networkModel.timeout delegate:self];
                
            } else {
                error = [NSError errorWithDomain:NSLocalizedString(@"PubnativeNetworkRequest : Error while making adapter for network model", @"") code:0 userInfo:nil];
            }
        } else {
            error = [NSError errorWithDomain:NSLocalizedString(@"PubnativeNetworkRequest : Error while making next request invalid network id retrieved", @"") code:0 userInfo:nil];
        }
    } else {
        error = [NSError errorWithDomain:NSLocalizedString(@"PubnativeNetworkRequest : Error while making next request invalid placement model retrieved", @"") code:0 userInfo:nil];
    }
    
    if (error) {
        [self invokeCompletionWithError:error];
    }
}

#pragma mark Network Model
- (PubnativeNetworkModel *) getNetworkModelForNetworkId:(NSString *)networkId
{
    PubnativeNetworkModel *networkModel = nil;
    
    if (networkId && ![networkId isEmptyString]) {
        
        if (self.configModel && self.configModel.networks) {
            networkModel = [self.configModel.networks objectForKey:networkId];
        }
    }
    
    return networkModel;
}


#pragma mark - Network Request Status -

- (void) invokeStart
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(initRequest:)]) {
        
        [self.delegate initRequest:self];
    }
}

- (void) invokeCompletionWithError:(NSError*)error
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(failedRequest:withError:)]){
        
        [self.delegate failedRequest:self withError:error];
    }
}

- (void) invokeCompletionWithAdModel:(PubnativeAdModel*)adModel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(loadRequest:withAd:)]) {
        
        [self.delegate loadRequest:self withAd:adModel];
    }
}

#pragma mark - CALLBACKS -

#pragma mark PubnativeConfigManagerDelegate

- (void)configDidFinishWithModel:(PubnativeConfigModel*)model
{
    self.configModel = model;
    [self startRequest];
}

- (void)configDidFailWithError:(NSError*)error
{
    // TODO: Handle config nil error by calling back the request delegate with fail
}

#pragma mark PubnativeNetworkAdapterDelegate

- (void) initAdapterRequest:(PubnativeNetworkAdapter *)adapter
{
    // TODO: Implementation pending
}

- (void) loadAdapterRequest:(PubnativeNetworkAdapter *)adapter withAd:(PubnativeAdModel *)ad
{
    // TODO: Implementation pending
}

- (void) failedAdapterRequest:(PubnativeNetworkAdapter *)adapter withError:(NSError *)error
{
    // TODO: Implementation pending
}

@end
