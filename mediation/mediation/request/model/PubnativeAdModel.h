//
//  PubnativeAdModel.h
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface PubnativeAdModel : NSObject

@property (nonatomic, readonly) NSString                    *title;
@property (nonatomic, readonly) NSString                    *description;
@property (nonatomic, readonly) NSString                    *iconURL;
@property (nonatomic, readonly) NSString                    *bannerURL;
@property (nonatomic, readonly) NSString                    *callToAction;
@property (nonatomic, readonly) float                       starRating;

@end
