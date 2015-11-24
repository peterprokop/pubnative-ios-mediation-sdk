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

- (void)pubantiveAdDidStartTrackingView:(UIView*)adView
                     withViewController:(UIViewController*)viewController;
- (void)pubantiveAdDidStopTrackingView:(UIView*)adView;
- (void)setPubnativeAdModelDelegate:(NSObject<PubnativeAdModelDelegate>*)delegate;

@end
