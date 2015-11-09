//
//  PubnativeAdModel.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeAdModel.h"

@interface PubnativeAdModel()

@property (nonatomic, weak) NSObject<PubnativeAdModelDelegate> *delegate;

@end

@implementation PubnativeAdModel

- (NSString*)title
{
    NSLog(@"PubnativeAdModel - Error: override me");
    return nil;
}

- (NSString*)description
{
    NSLog(@"PubnativeAdModel - Error: override me");
    return nil;
}

- (NSString*)iconURL
{
    NSLog(@"PubnativeAdModel - Error: override me");
    return nil;
}

- (NSString*)bannerURL
{
    NSLog(@"PubnativeAdModel - Error: override me");
    return nil;
}

- (NSString*)callToAction
{
    NSLog(@"PubnativeAdModel - Error: override me");
    return nil;
}

- (float)starRating
{
    NSLog(@"PubnativeAdModel - Error: override me");
    return 0.0;
}

- (void)pubantiveAdDidStartTrackingView:(UIView*)adView withViewController:(UIViewController*)adViewController
{
    NSLog(@"PubnativeAdModel - Error: override me");
}

- (void)pubantiveAdDidStopTrackingView:(UIView*)adView
{
    NSLog(@"PubnativeAdModel - Error: override me");
}

- (void)invokeDidConfirmedImpression:(PubnativeAdModel*)ad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pubantiveAdDidConfirmedImpression:)]) {
        [self.delegate pubantiveAdDidConfirmedImpression:ad];
    }
}

- (void)invokeDidClicked:(PubnativeAdModel*)ad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pubnativeAdDidClicked:)]) {
        [self.delegate pubnativeAdDidClicked:ad];
    }
}

@end
