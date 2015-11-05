//
//  FacebookNativeAdModel.m
//  mediation
//
//  Created by Mohit on 28/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "FacebookNativeAdModel.h"

@interface PubnativeAdModel(Private)

- (void) invokeAdImpressionConfirmed;
- (void) invokeAdClicked;

@end

@interface FacebookNativeAdModel()<FBNativeAdDelegate>

@end

@implementation FacebookNativeAdModel

- (instancetype)initWithNativeAd:(FBNativeAd*)nativeAd
{
    self = [super init];
    if (self) {
        self.nativeAd = nativeAd;
    }
    return self;
}

- (NSString*)title
{
    NSString *result = nil;
    if (self.nativeAd) {
        result = self.nativeAd.title;
    }
    return result;
}

- (NSString*)description
{
    NSString *result = nil;
    if (self.nativeAd) {
        result = self.nativeAd.body;
    }
    return result;
}

- (NSString*)iconUrl
{
    NSString *result = nil;
    if (self.nativeAd &&
        self.nativeAd.icon && self.nativeAd.icon.url) {
        result = [self.nativeAd.icon.url absoluteString];
    }
    return result;
}

- (NSString*)bannerUrl
{
    NSString *result = nil;
    if (self.nativeAd &&
        self.nativeAd.coverImage && self.nativeAd.coverImage.url) {
        result = [self.nativeAd.coverImage.url absoluteString];
    }
    return result;
}

- (NSString*)callToAction
{
    NSString *result = nil;
    if (self.nativeAd) {
        result = self.nativeAd.callToAction;
    }
    return result;
}

- (float)starRating
{
    float starRating = 0;
    if (self.nativeAd) {
        struct FBAdStarRating rating = self.nativeAd.starRating;
        if (rating.scale && rating.value) {
            float ratingScale = rating.scale;
            float ratingValue = rating.value;
            starRating = ((ratingValue / ratingScale) * 5.0);
        }
    }
    return starRating;
}

- (void)startTrackingWithView:(UIView*)adView viewController:(UIViewController*)adViewController
{
    if (self.nativeAd && adView) {
        self.nativeAd.delegate = self;
        [self.nativeAd registerViewForInteraction:adView withViewController:adViewController];
    }
}

- (void)stopTrackingWithView:(UIView*)adView
{
    if (self.nativeAd) {
        [self.nativeAd unregisterView];
    }
}


#pragma mark - FBNativeAdDelegate implementation

- (void)nativeAdDidClick:(FBNativeAd*)nativeAd
{
    [super invokeAdClicked];
}

- (void)nativeAdWillLogImpression:(FBNativeAd*)nativeAd
{
    [super invokeAdImpressionConfirmed];
}

@end
