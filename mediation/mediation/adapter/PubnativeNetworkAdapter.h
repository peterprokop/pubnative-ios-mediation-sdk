//
//  PubnativeNetworkAdapter.h
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubnativeAdModel.h"
#import "PubnativeNetworkModel.h"

@class PubnativeNetworkAdapter;

@protocol PubnativeNetworkAdapterDelegate <NSObject>

- (void)adapterRequestDidStart:(PubnativeNetworkAdapter*)adapter;
- (void)adapter:(PubnativeNetworkAdapter*)adapter requestDidLoad:(PubnativeAdModel*)ad;
- (void)adapter:(PubnativeNetworkAdapter*)adapter requestDidFail:(NSError*)error;

@end

@interface PubnativeNetworkAdapter : NSObject

- (void)startWithData:(NSDictionary *)data
              timeout:(NSTimeInterval)timeout
               extras:(NSDictionary<NSString *,NSString *> *)extras
             delegate:(NSObject<PubnativeNetworkAdapterDelegate> *)delegate;

@end
