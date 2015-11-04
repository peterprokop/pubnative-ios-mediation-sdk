//
//  PubnativeNetworkAdapter.h
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubnativeAdModel.h"

@class PubnativeNetworkAdapter;

@protocol PubnativeNetworkAdapterDelegate <NSObject>

- (void) initAdapterRequest:(PubnativeNetworkAdapter *)adapter;
- (void) loadAdapterRequest:(PubnativeNetworkAdapter *)adapter withAd:(PubnativeAdModel *)ad;
- (void) failedAdapterRequest:(PubnativeNetworkAdapter *)adapter withError:(NSError *)error;

@end

@interface PubnativeNetworkAdapter : NSObject

- (instancetype)initWithParams:(NSDictionary*)paramsDictionary;
- (void)doRequestWithTimeout:(NSNumber *)timeout delegate:(NSObject<PubnativeNetworkAdapterDelegate>*)delegate;

@end
