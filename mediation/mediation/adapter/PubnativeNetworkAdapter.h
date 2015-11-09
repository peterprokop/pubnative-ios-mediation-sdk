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

- (void)adapterRequestDidStart:(PubnativeNetworkAdapter*)adapter;
- (void)adapter:(PubnativeNetworkAdapter*)adapter requestDidLoad:(PubnativeAdModel*)ad;
- (void)adapter:(PubnativeNetworkAdapter*)adapter requestDidFail:(NSError *)error;

@end

@interface PubnativeNetworkAdapter : NSObject

@property (nonatomic, strong)   NSDictionary                                *params;
@property (nonatomic, weak)     NSObject<PubnativeNetworkAdapterDelegate>   *delegate;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
- (void)requestWithTimeout:(int)timeout delegate:(NSObject<PubnativeNetworkAdapterDelegate>*)delegate;
- (void)invokeDidFail:(NSError*)error;
- (void)invokeDidLoad:(PubnativeAdModel*)ad;

@end
