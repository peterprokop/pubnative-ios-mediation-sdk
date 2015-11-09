//
//  PubnativeAdModel.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeAdModel.h"

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

- (void)adDidStartTrackingView:(UIView*)adView withViewController:(UIViewController*)adViewController
{
    NSLog(@"PubnativeAdModel - Error: override me");
}

- (void)adDidStopTrackingView:(UIView*)adView
{
    NSLog(@"PubnativeAdModel - Error: override me");
}

- (void)adDidConfirmedImpression:(PubnativeAdModel*)ad
{
    //TODO: Implementation For Confirmed Impression
}

- (void)adDidClicked:(PubnativeAdModel*)ad
{
    //TODO: Implementation For Clicked
}

@end
