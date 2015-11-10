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

-(void)requestDidStart:(PubnativeNetworkRequest *)request;
-(void)request:(PubnativeNetworkRequest *)request didLoad:(PubnativeAdModel*)ad;
-(void)request:(PubnativeNetworkRequest *)request didFail:(NSError*)error;

@end

@interface PubnativeNetworkRequest : NSObject

- (void)startRequestWithAppToken:(NSString*)appToken
                    placementKey:(NSString*)placementKey
                        delegate:(id<PubnativeNetworkRequestDelegate>)delegate;

@end
