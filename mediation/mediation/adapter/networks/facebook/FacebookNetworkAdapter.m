//
//  FacebookNetworkAdapter.m
//  mediation
//
//  Created by Mohit on 27/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "FacebookNetworkAdapter.h"
#import "FacebookNativeAdModel.h"

NSString * const kPlacementIdKey = @"placement_id";

@interface PubnativeNetworkAdapter(Private)

@property (nonatomic, strong)   NSDictionary        *paramsDictionary;

- (void) invokeLoadedWithAd:(PubnativeAdModel *)adModel;
- (void) invokeFailedWithError:(NSError *)error;

@end


@interface FacebookNetworkAdapter()<FBNativeAdDelegate>

@property (strong, nonatomic) FBNativeAd * nativeAd;

@end


@implementation FacebookNetworkAdapter

- (void)doRequest
{
    if (self.paramsDictionary) {
        NSString *placementId = [self.paramsDictionary valueForKey:kPlacementIdKey];
        if (placementId && [placementId length] > 0) {
            [self createRequestWithPlacementId:placementId];
        } else {
            NSError *error = [NSError errorWithDomain:@"FacebookNetworkAdapter - Invalid placement id provided"
                                                 code:0
                                             userInfo:nil];
            [super invokeFailedWithError:error];
        }
    } else {
        NSError *error = [NSError errorWithDomain:@"FacebookNetworkAdapter - No placement id provided"
                                             code:0
                                         userInfo:nil];
        [super invokeFailedWithError:error];
    }
}

- (void)createRequestWithPlacementId:(NSString*)placementId
{
    if (placementId && [placementId length] > 0) {
        self.nativeAd = [[FBNativeAd alloc] initWithPlacementID:placementId];
        self.nativeAd.delegate = self;
        [self.nativeAd loadAd];
    }
}

#pragma mark - FBNativeAdDelegate implementation -

- (void)nativeAdDidLoad:(FBNativeAd*)nativeAd
{
    FacebookNativeAdModel *wrapModel = [[FacebookNativeAdModel alloc] initWithNativeAd:self.nativeAd];
    [self invokeLoadedWithAd:wrapModel];
}

- (void)nativeAd:(FBNativeAd*)nativeAd didFailWithError:(NSError*)error
{
    if (!error) {
        error = [NSError errorWithDomain:@"FacebookNetworkAdapter : Unknown error"
                                    code:0
                                userInfo:nil];
    }
    [self invokeFailedWithError:error];
}

@end
