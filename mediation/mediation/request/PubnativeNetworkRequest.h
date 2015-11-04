//
//  PubnativeNetworkRequest.h
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubnativeAdModel.h"

@class PubnativeNetworkRequest;

@protocol PubnativeNetworkRequestDelegate <NSObject>

- (void) initRequest:(PubnativeNetworkRequest *)request;
- (void) loadRequest:(PubnativeNetworkRequest *)request withAd:(PubnativeAdModel *)ad;
- (void) failedRequest:(PubnativeNetworkRequest *)request withError:(NSError *)error;

@end

@interface PubnativeNetworkRequest : NSObject

@property (nonatomic, weak) id <PubnativeNetworkRequestDelegate> delegate;

- (void) startRequestWithAppToken:(NSString*)appToken andPlacement:(NSString*)placementKey;

@end
