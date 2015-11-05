//
//  PubnativeNetworkAdapter.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeNetworkAdapter.h"

@interface PubnativeNetworkAdapter()

@property (nonatomic, strong)   NSDictionary                                *params;
@property (nonatomic, weak)     NSObject<PubnativeNetworkAdapterDelegate>   *delegate;

@end

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
- (void)doRequestWithTimeout:(int)timeout delegate:(NSObject<PubnativeNetworkAdapterDelegate>*)delegate;
{
    if (delegate) {
        self.delegate = delegate;
        [self invokeStart];
        if (timeout > 0) {
            //timeout is in milliseconds
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * timeout * 0.001);
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [self requestTimeout];
            });
        }
        [self doRequest];
    } else {
        NSLog(@"PubnativeNetworkAdapter.doRequest - network adapter delegate not specified");
    }
}

- (void)doRequest
{
    NSLog(@"Pubnative Mediation : Error : override me");
}

#pragma mark - Request Timeout -
- (void)requestTimeout
{
    NSLog(@"PubnativeNetworkAdapter.doRequest - request timeout");
    NSError *error = [NSError errorWithDomain:@"PubnativeNetworkAdapter.doRequest - request timeout"
                                         code:0
                                     userInfo:nil];
    
    [self invokeDidFail:error];
}

-(void)cancelTimeout
{
    //To cancel the timeout callback
    self.delegate = nil;
}

#pragma mark - Ads Invoke -
- (void)invokeStart
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
    [self cancelTimeout];
}

- (void)invokeDidFail:(NSError*)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(adapter:requestDidFail:)]) {
        [self.delegate adapter:self requestDidFail:error];
    }
    [self cancelTimeout];
}

@end
