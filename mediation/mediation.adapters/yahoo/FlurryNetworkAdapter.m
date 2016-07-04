//
//  FlurryNetworkAdapter.m
//  mediation
//
//  Created by Alvarlega on 04/07/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "FlurryNetworkAdapter.h"
#import "FlurryNativeAdModel.h"

@interface PubnativeNetworkAdapter (Private)

- (void)invokeDidFail:(NSError*)error;
- (void)invokeDidLoad:(PubnativeAdModel*)ad;

@end

@interface FlurryNetworkAdapter () <FlurryAdNativeDelegate>

@property (nonatomic, retain) FlurryAdNative* nativeAd;

@end

@implementation FlurryNetworkAdapter

- (void)doRequestWithData:(NSDictionary *)data
                   extras:(NSDictionary<NSString *,NSString *> *)extras
{
    if (data == nil) {
        NSString *placementId = data[@"placement_id"];
        if (placementId && placementId.length > 0) {
            [self createRequestWithPlacementId:placementId];
        }
    }
}

- (void)createRequestWithPlacementId:(NSString*)placementId
{
    self.nativeAd = [[FlurryAdNative alloc] initWithSpace:placementId];
    self.nativeAd.adDelegate = self;
    [self.nativeAd fetchAd];
}

#pragma mark - FlurryAdNativeDelegate delegates
//The Flurry SDK receives the ad’s assets and calls back ``adNativeDidFetchAd`` with the FlurryAdNative object reference.
- (void) adNativeDidFetchAd:(FlurryAdNative *)nativeAd
{
    NSLog(@"Native Ad for Space [%@] Received Ad with [%lu] assets", nativeAd.space, (unsigned long)nativeAd.assetList.count);
    FlurryNativeAdModel *wrapModel = [[FlurryNativeAdModel alloc] initWithNativeAd:nativeAd];
    [self invokeDidLoad:wrapModel];
}

//or in case of no ads returned the SDK calls adNAtive:adError:errorDescription
- (void) adNative:(FlurryAdNative*)nativeAd
          adError:(FlurryAdError)adError
 errorDescription:(NSError*) errorDescription
{
    //FLURRY_AD_ERROR_DID_FAIL_TO_RENDER   = 0,
    //FLURRY_AD_ERROR_DID_FAIL_TO_FETCH_AD = 1,
    //FLURRY_AD_ERROR_CLICK_ACTION_FAILED  = 2,
    NSLog(@" Native Ad for Space [%@] Received Error # [%d], with description: [%@]  ================ ", nativeAd.space, adError, errorDescription );
    [self invokeDidFail:errorDescription];
}

@end
