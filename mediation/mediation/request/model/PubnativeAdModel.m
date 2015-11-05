//
//  PubnativeAdModel.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeAdModel.h"

@interface PubnativeAdModel()

@property (nonatomic, weak) NSObject<PubnativeAdModelDelegate>   *delegate;

@end

@implementation PubnativeAdModel

- (NSString*)title
{
    NSLog(@"Pubnative : Error : override me");
    return nil;
}

- (NSString*)description
{
    NSLog(@"Pubnative : Error : override me");
    return nil;
}

- (NSString*)iconURL
{
    NSLog(@"Pubnative : Error : override me");
    return nil;
}

- (NSString*)bannerURL
{
    NSLog(@"Pubnative : Error : override me");
    return nil;
}

- (NSString*)callToAction
{
    NSLog(@"Pubnative : Error : override me");
    return nil;
}

- (float)starRating
{
    NSLog(@"Pubnative : Error : override me");
    return 0.0;
}

@end
