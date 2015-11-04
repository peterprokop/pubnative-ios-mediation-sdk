//
//  FacebookNativeAdModel.h
//  mediation
//
//  Created by Mohit on 28/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeAdModel.h"

@import FBAudienceNetwork;

@interface FacebookNativeAdModel : PubnativeAdModel<FBNativeAdDelegate>

@property(nonatomic,strong)FBNativeAd *nativeAd;

- (instancetype) initWithNativeAd:(FBNativeAd *)nativeAd;

@end
