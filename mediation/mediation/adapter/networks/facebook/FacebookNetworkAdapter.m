//
//  FacebookNetworkAdapter.m
//  mediation
//
//  Created by Mohit on 27/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "FacebookNetworkAdapter.h"
#import "NSString+PubnativeStringUtil.h"
#import "FacebookNativeAdModel.h"

NSString * const kPlacementIdKey = @"placement_id";

@interface PubnativeNetworkAdapter (Private)

@property (nonatomic, strong)   NSDictionary                                *paramsDictionary;

- (void) invokeLoadedWithAd:(PubnativeAdModel *)adModel;
- (void) invokeFailedWithError:(NSError *)error;

@end


@interface FacebookNetworkAdapter()

@property (strong, nonatomic) FBNativeAd * nativeAd;

@end


@implementation FacebookNetworkAdapter

- (void) makeRequest
{
    if (self.paramsDictionary) {
        
        NSString *placementId = [self.paramsDictionary valueForKey:kPlacementIdKey];
        
        if (placementId && [placementId isEmptyString]) {
            
            [self createRequestWithPlacementId:placementId];
            
        } else {
            
            NSError *error = [NSError errorWithDomain:@"FacebookNetworkAdapter - Invalid placement id provided" code:0 userInfo:nil];
            [super invokeFailedWithError:error];
        }
        
    } else {
        
        NSError *error = [NSError errorWithDomain:@"FacebookNetworkAdapter - No placement id provided" code:0 userInfo:nil];
        [super invokeFailedWithError:error];
    }
}

- (void) createRequestWithPlacementId:(NSString *)placementId
{
    if (placementId && [placementId isEmptyString]) {
        
        self.nativeAd = [[FBNativeAd alloc] initWithPlacementID:placementId];
        self.nativeAd.delegate = self;
        
        [self.nativeAd loadAd];
    }
}

#pragma mark - FBNativeAdDelegate implementation -

- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd
{
    if (self.nativeAd == nativeAd) {

        FacebookNativeAdModel *wrapModel = [[FacebookNativeAdModel alloc]initWithNativeAd:self.nativeAd];
        [super invokeLoadedWithAd:wrapModel];
    }
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error
{
    if (self.nativeAd == nativeAd) {
        
        if (!error) {
            
            error = [NSError errorWithDomain:@"Pubnative - Facebook adapter error: Unknown error"
                                        code:0
                                    userInfo:nil];

        }
        
        [super invokeFailedWithError:error];
    }
}

//- (void)nativeAdDidClick:(FBNativeAd *)nativeAd
//{
//    NSLog(@"Native ad was clicked.");
//}
//
//- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd
//{
//    NSLog(@"Native ad did finish click handling.");
//}
//
//- (void)nativeAdWillLogImpression:(FBNativeAd *)nativeAd
//{
//    NSLog(@"Native ad impression is being captured.");
//}

@end
