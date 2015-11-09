//
//  PubnativeNetworkAdapter.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeNetworkAdapter.h"

@implementation PubnativeNetworkAdapter

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        self.params = dictionary;
    }
    return self;
}

#pragma mark - Request -
- (void)requestWithTimeout:(int)timeout delegate:(NSObject<PubnativeNetworkAdapterDelegate>*)adapterDelegate
{
    if (adapterDelegate) {
        self.delegate = adapterDelegate;
        [self invokeDidStart];
        if (timeout > 0) {
            //timeout is in milliseconds
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * timeout * 0.001);
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [self requestTimeout];
            });
        }
        [self doRequest];
    } else {
        NSLog(@"PubnativeNetworkAdapter.requestWithTimeout:delegate: - Error: network adapter delegate not specified");
    }
}

- (void)doRequest
{
    NSLog(@"PubnativeNetworkAdapter.doRequest - Error: override me");
}

#pragma mark - Request Timeout -
- (void)requestTimeout
{
    NSError *error = [NSError errorWithDomain:@"PubnativeNetworkAdapter - Error: request timeout"
                                         code:0
                                     userInfo:nil];
    
    [self invokeDidFail:error];
}

#pragma mark - Ads Invoke -
- (void)invokeDidStart
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adapterRequestDidStart:)]) {
        [self.delegate adapterRequestDidStart:self];
    }
}

- (void)invokeDidLoad:(PubnativeAdModel*)ad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adapter:requestDidLoad:)]) {
        [self.delegate adapter:self requestDidLoad:ad];
    }
    //To cancel the timeout callback
    self.delegate = nil;
}

- (void)invokeDidFail:(NSError*)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adapter:requestDidFail:)]) {
        [self.delegate adapter:self requestDidFail:error];
    }
    //To cancel the timeout callback
    self.delegate = nil;
}

@end
