//
//  PubnativeNetworkAdapter.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeNetworkAdapter.h"

@interface PubnativeNetworkAdapter()

@property (nonatomic, strong)   id                                          requestTimeOut;
@property (nonatomic, strong)   NSDictionary                                *paramsDictionary;
@property (nonatomic, weak)     NSObject<PubnativeNetworkAdapterDelegate>   *delegate;

@end

@implementation PubnativeNetworkAdapter

- (instancetype) initWithParams:(NSDictionary*)paramsDictionary
{
    self = [super init];
    if (self) {
        self.paramsDictionary = paramsDictionary;
    }
    return self;
}

#pragma mark - Request -
- (void) doRequestWithTimeout:(NSNumber*)timeout  delegate:(NSObject<PubnativeNetworkAdapterDelegate>*)delegate;
{
    if (delegate) {
    
        self.delegate = delegate;
        [self invokeStart];

        if (timeout) {

            self.requestTimeOut = [self performBlock:^{
                
                [self requestTimeout];
                
            } afterDelay:timeout];
        }
        [self makeRequest];
        
    } else {
        
        NSLog(@"PubnativeNetworkAdapter.doRequest - error network adapter delegate not specified");
    }
}

- (void) makeRequest
{
    //Override this method in child classes
    NSLog(@"Pubnative Mediation : Error : You must override makeRequest in sub class of PubnativeNetworkAdapter");
}

#pragma mark - Request Timeout -
- (void) requestTimeout
{
    NSError *error = [NSError errorWithDomain:@"PubnativeNetworkAdapter.doRequest - request timeout"
                                         code:0
                                     userInfo:nil];
    
    [self invokeFailedWithError:error];
    self.delegate = nil;
    
    NSLog(@"PubnativeNetworkAdapter.doRequest - request timeout");
}

- (void) cancelRequestCallbacks
{
    [self cancelBlock:self.requestTimeOut];
}

- (id)performBlock:(void (^)(void))block afterDelay:(NSNumber *)timeout
{
    if (!block)
    {
        return nil;
    }
    
    __block BOOL cancelled = NO;
    
    void (^wrappingBlock)(BOOL) = ^(BOOL cancel) {
        
        if (cancel) {
            cancelled = YES;
            return;
        }
        
        if (!cancelled) {
            block();
        }
        
    };
    
    //timeout is in milliseconds
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * [timeout doubleValue] * 0.001);
    
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        wrappingBlock(NO);
    });
    
    return wrappingBlock;
}

- (void) cancelBlock:(id)block
{
    if (!block) {
        return;
    }
    
    void (^aWrappingBlock)(BOOL) = (void(^)(BOOL))block;
    aWrappingBlock(YES);
}

#pragma mark - Ads Invoke -
- (void) invokeStart
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(initAdapterRequest:)]) {
        [self.delegate initAdapterRequest:self];
    }
}

- (void) invokeLoadedWithAd:(PubnativeAdModel *)adModel
{
    [self cancelRequestCallbacks];
    if (self.delegate && [self.delegate respondsToSelector:@selector(loadAdapterRequest:withAd:)]) {
        [self.delegate loadAdapterRequest:self withAd:adModel];
    }
}

- (void) invokeFailedWithError:(NSError *)error
{
    [self cancelRequestCallbacks];
    if (self.delegate && [self.delegate respondsToSelector:@selector(failedAdapterRequest:withError:)]) {
        [self.delegate failedAdapterRequest:self withError:error];
    }
}

@end
