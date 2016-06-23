//
//  PubnativeAdModel.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeAdModel.h"

@interface PubnativeAdModel ()

@property (nonatomic, strong) NSString  *impressionURL;
@property (nonatomic, strong) NSString  *clickURL;
@property (nonatomic, assign) BOOL      isImpressionTracked;
@property (nonatomic, assign) BOOL      isClickTracked;

// TODO: Add insight data model

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

- (NSNumber*)starRating
{
    NSLog(@"PubnativeAdModel - Error: override me");
    return @0;
}

- (void)startTrackingView:(UIView*)adView
       withViewController:(UIViewController*)viewController
{
    NSLog(@"PubnativeAdModel - Error: override me");
}

- (void)stopTracking
{
    NSLog(@"PubnativeAdModel - Error: override me");
}

- (void)invokeDidConfirmImpression
{
    if(!self.isImpressionTracked) {
        
        self.isImpressionTracked = YES;
        
        // TODO: Log impression against delivery manager
        // TODO: Track impression
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(pubantiveAdDidConfirmImpression:)]){
            [self.delegate pubantiveAdDidConfirmImpression:self];
        }
    }
}

- (void)invokeDidClick
{
    if(!self.isClickTracked){
        
        self.isClickTracked = YES;
        
        // TODO: track click
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(pubnativeAdDidClick:)]){
            [self.delegate pubnativeAdDidClick:self];
        }
    }
}

@end
