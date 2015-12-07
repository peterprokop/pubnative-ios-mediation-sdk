//
//  PubnativeLibraryAdModel.m
//  mediation
//
//  Created by Mohit on 17/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeLibraryAdModel.h"

@interface PubnativeAdModel (Private)

- (void)invokeDidConfirmedImpression:(PubnativeAdModel*)ad;
- (void)invokeDidClicked:(PubnativeAdModel*)ad;

@end

@interface PubnativeLibraryAdModel ()

@property(nonatomic,strong)PNNativeAdModel *model;

@end

@implementation PubnativeLibraryAdModel

- (instancetype)initWithNativeAd:(PNNativeAdModel*)model {
    self = [super init];
    if (self) {
        self.model = model;
    }
    return self;
}

- (NSString*)title
{
    NSString *result = nil;
    if (self.model) {
        result = self.model.title;
    }
    return result;
}

- (NSString*)description
{
    NSString *result = nil;
    if (self.model) {
        result = self.model.Description;
    }
    return result;
}

- (NSString*)iconURL
{
    NSString *result = nil;
    if (self.model) {
        result = self.model.icon_url;
    }
    return result;
}

- (NSString*)bannerURL
{
    NSString *result = nil;
    if (self.model) {
        result = self.model.banner_url;
    }
    return result;
}

- (NSString*)callToAction
{
    NSString *result = nil;
    if (self.model) {
        result = self.model.cta_text;
    }
    return result;
}

- (float)starRating
{
    float starRating = 0;
    if (self.model &&
        self.model.app_details &&
        self.model.app_details.store_rating) {
        starRating = [self.model.app_details.store_rating floatValue];
    }
    return starRating;
}

- (void)startTrackingView:(UIView*)adView
       withViewController:(UIViewController*)viewController
{
    if (self.model && adView) {
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(adViewTapped)];
        [adView addGestureRecognizer:singleTapRecognizer];
    }
}

- (void)stopTrackingView:(UIView*)adView
{
    // Do nothing
}

/**
 *  Invoke when ad View associated with the PNNativeAdModel tapped
 */
- (void)adViewTapped {
    
    [self invokeDidClicked:self];
    if (self.model && self.model.click_url) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.model.click_url]];
    }
}

@end
