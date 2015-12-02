//
//  PubnativeNetworkAdapter.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeNetworkAdapter.h"

@interface PubnativeNetworkAdapter ()

@property (nonatomic, assign) int timeOut;

@end

@implementation PubnativeNetworkAdapter

- (instancetype)initWithNetwork:(PubnativeNetworkModel *)network
{
    self = [super init];
    if (self) {
        self.params = network.params;
        self.timeOut = [network.timeout intValue];
    }
    return self;
}

#pragma mark - Request -
- (void)startRequestWithDelegate:(NSObject<PubnativeNetworkAdapterDelegate>*)delegate;
{
    if (delegate) {
        self.delegate = delegate;
        [self invokeDidStart];
        if (self.timeOut > 0) {
            //timeout is in milliseconds
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * self.timeOut * 0.001);
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [self requestTimeout];
            });
        }
        [self doRequest];
    } else {
        NSLog(@"PubnativeNetworkAdapter.startRequestWithDelegate: - Error: network adapter delegate not specified");
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
