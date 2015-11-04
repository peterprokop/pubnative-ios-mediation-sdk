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
    //Override this method in child classes
    NSLog(@"Pubnative : Error : You must override title in sub class of PubnativeAdModel");
    return nil;
}

- (NSString*)description
{
    //Override this method in child classes
    NSLog(@"Pubnative : Error : You must override description in sub class of PubnativeAdModel");
    return nil;
}

- (NSString*)iconURL
{
    //Override this method in child classes
    NSLog(@"Pubnative : Error : You must override iconUrl in sub class of PubnativeAdModel");
    return nil;
}

- (NSString*)bannerURL
{
    //Override this method in child classes
    NSLog(@"Pubnative : Error : You must override bannerUrl in sub class of PubnativeAdModel");
    return nil;
}

- (NSString*)callToAction
{
    //Override this method in child classes
    NSLog(@"Pubnative : Error : You must override callToAction in sub class of PubnativeAdModel");
    return nil;
}

- (float)starRating
{
    //Override this method in child classes
    NSLog(@"Pubnative : Error : You must override starRating in sub class of PubnativeAdModel");
    return 0.0;
}

- (void) startTrackingWithView:(UIView *)adView viewController:(UIViewController *)adViewController
{
    //Override this method in child classes
    NSLog(@"Pubnative : Error : You must override startTrackingWithView in sub class of PubnativeAdModel");
}

- (void) stopTrackingWithView:(UIView *)adView
{
    //Override this method in child classes
    NSLog(@"Pubnative : Error : You must override stopTrackingWithView in sub class of PubnativeAdModel");
}

- (void) invokeAdImpressionConfirmed
{
    // TODO: Implementation Pending
}

- (void) invokeAdClicked
{
    // TODO: Implementation Pending
}

@end
