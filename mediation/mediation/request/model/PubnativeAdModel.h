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

- (void)pubantiveAdDidConfirmedImpression:(PubnativeAdModel *)ad;
- (void)pubnativeAdDidClicked:(PubnativeAdModel *)ad;

@end

@interface PubnativeAdModel : NSObject

@property (nonatomic, readonly) NSString                    *title;
@property (nonatomic, readonly) NSString                    *description;
@property (nonatomic, readonly) NSString                    *iconURL;
@property (nonatomic, readonly) NSString                    *bannerURL;
@property (nonatomic, readonly) NSString                    *callToAction;
@property (nonatomic, readonly) float                       starRating;

/**
 * Start tracking Ad View
 * @param adView View used to show the ad
 * @param viewController ViewController which contains the adView
 */
- (void)startTrackingView:(UIView*)adView
       withViewController:(UIViewController*)viewController;
/**
 * Stop tracking Ad View
 * @param adView View used to show the ad
 */
- (void)stopTrackingView:(UIView*)adView;

- (void)setDelegate:(NSObject<PubnativeAdModelDelegate>*)delegate;

@end
