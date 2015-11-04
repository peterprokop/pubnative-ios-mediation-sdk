//
//  PubnativeAdModel.h
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class PubnativeAdModel;

@protocol PubnativeAdModelDelegate <NSObject>

- (void) impressionConfirmedForAd:(PubnativeAdModel *)adModel;
- (void) clickedForAd:(PubnativeAdModel *)adModel;

@end

@interface PubnativeAdModel : NSObject

@property (nonatomic, weak) id <PubnativeAdModelDelegate>   delegate;
@property (nonatomic, readonly) NSString                    *title;
@property (nonatomic, readonly) NSString                    *description;
@property (nonatomic, readonly) NSString                    *iconURL;
@property (nonatomic, readonly) NSString                    *bannerURL;
@property (nonatomic, readonly) NSString                    *callToAction;
@property (nonatomic, readonly) float                       starRating;

- (void) startTrackingWithView:(UIView *)adView viewController:(UIViewController *)adViewController;
- (void) stopTrackingWithView:(UIView *)adView;


@end
