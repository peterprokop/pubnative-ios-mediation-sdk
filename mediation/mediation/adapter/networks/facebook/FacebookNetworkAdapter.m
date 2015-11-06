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

@property (nonatomic, strong)   NSDictionary        *params;

- (void)invokeDidLoad:(PubnativeAdModel*)ad;
- (void)invokeDidFail:(NSError*)error;

@end


@interface FacebookNetworkAdapter () <FBNativeAdDelegate>

@property (strong, nonatomic) FBNativeAd * nativeAd;

@end


@implementation FacebookNetworkAdapter

- (void)doRequest
{
    if (self.params) {
        NSString *placementId = [self.params valueForKey:kPlacementIdKey];
        if (placementId && [placementId length] > 0) {
            [self createRequestWithPlacementId:placementId];
        } else {
            NSError *error = [NSError errorWithDomain:@"FacebookNetworkAdapter.doRequest - Invalid placement id provided"
                                                 code:0
                                             userInfo:nil];
            [super invokeDidFail:error];
        }
    } else {
        NSError *error = [NSError errorWithDomain:@"FacebookNetworkAdapter.doRequest - Placement id not avaliable"
                                             code:0
                                         userInfo:nil];
        [super invokeDidFail:error];
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
    
    [self invokeDidLoad:wrapModel];
}

- (void)nativeAd:(FBNativeAd*)nativeAd didFailWithError:(NSError*)error
{
    if (!error) {
        error = [NSError errorWithDomain:@"FacebookNetworkAdapter : Unknown error"
                                    code:0
                                userInfo:nil];
    }
    [self invokeDidFail:error];
}

@end
