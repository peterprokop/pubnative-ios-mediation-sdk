//
//  PubnativeNetworkAdapterSpec.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "Specta.h"
#import "Expecta.h"
#import "PubnativeNetworkAdapter.h"
#import <OCMock/OCMock.h>

int const kTimeOutHalfSecond = 500; //miliseconds
int const kTimeOutZeroSecond = 0;   //miliseconds

@interface PubnativeNetworkAdapter (Private)

@property (nonatomic, weak)     NSObject<PubnativeNetworkAdapterDelegate>   *delegate;

- (void)invokeDidStart;
- (void)invokeDidLoad:(PubnativeAdModel*)ad;
- (void)invokeDidFail:(NSError*)error;
- (void)requestTimeout;
- (void)doRequest;
- (id)performBlock:(void (^)(void))block afterDelay:(int)timeout;
- (void)cancelBlock:(id)block;

@end

SpecBegin(PubnativeNetworkAdapter)

describe(@"callback methods", ^{
    
    context(@"with delegate", ^{
        __block PubnativeNetworkAdapter *networkAdapter;
        __block id                      delegate;
        
        beforeEach(^{
            networkAdapter = [PubnativeNetworkAdapter new];
            delegate = OCMProtocolMock(@protocol(PubnativeNetworkAdapterDelegate));
            networkAdapter.delegate = delegate;
        });
        
        it(@"invokeDidStart, call adapterRequestDidStart:", ^{
            OCMExpect([delegate adapterRequestDidStart:[OCMArg any]]);
            [networkAdapter invokeDidStart];
            OCMVerifyAll(delegate);
        });
        
        it(@"invokeDidLoad, call adapter:requestDidLoad:", ^{
            OCMExpect([delegate adapter:[OCMArg any] requestDidLoad:[OCMArg any]]);
            [networkAdapter invokeDidLoad:[OCMArg any]];
            OCMVerifyAll(delegate);
            expect(networkAdapter.delegate).to.beNil();
        });
        
        it(@"invokeDidFail, call adapter:requestDidFail:", ^{
            OCMExpect([delegate adapter:[OCMArg any] requestDidFail:[OCMArg any]]);
            [networkAdapter invokeDidFail:[OCMArg any]];            
            OCMVerifyAll(delegate);
            expect(networkAdapter.delegate).to.beNil();
        });
    });
    
    context(@"without delegate", ^{
        __block PubnativeNetworkAdapter *networkAdapter;
        
        beforeEach(^{
            networkAdapter = [PubnativeNetworkAdapter new];
        });
        
        it(@"invokeDidLoad, keeps delegate to nil", ^{
            [networkAdapter invokeDidLoad:[OCMArg any]];
            expect(networkAdapter.delegate).to.beNil();
        });
        
        it(@"invokeDidFail, keeps delegate to nil", ^{
            [networkAdapter invokeDidFail:[OCMArg any]];
            expect(networkAdapter.delegate).to.beNil();
        });
    });
});


describe(@"while doing request", ^{
    
    context(@"with delegate", ^{
        __block PubnativeNetworkAdapter                     *networkAdapter;
        __block NSObject<PubnativeNetworkAdapterDelegate>   *delegateMock;
        
        beforeAll(^{
            networkAdapter = OCMPartialMock([PubnativeNetworkAdapter new]);
            delegateMock = OCMProtocolMock(@protocol(PubnativeNetworkAdapterDelegate));
        });
        
        it(@"and timeout, requestTimeout called", ^{
            OCMExpect([networkAdapter invokeDidStart]);
            OCMExpect([networkAdapter doRequest]);
            OCMExpect([networkAdapter requestTimeout]);
            [networkAdapter requestWithTimeout:kTimeOutHalfSecond delegate:delegateMock];
            OCMVerifyAllWithDelay((id)networkAdapter, kTimeOutHalfSecond);
        });
        
        it(@"and without timeout, does not call requestTimeout", ^{
            [[(id)networkAdapter reject] requestTimeout];
            OCMExpect([networkAdapter invokeDidStart]);
            OCMExpect([networkAdapter doRequest]);
            [networkAdapter requestWithTimeout:kTimeOutZeroSecond delegate:delegateMock];
            OCMVerifyAll((id)networkAdapter);
        });
    });
    
    context(@"without delegate", ^{
        
        it(@"drops call", ^{
            id networkAdapter = OCMPartialMock([PubnativeNetworkAdapter new]);
            [[networkAdapter reject] doRequest];
            [networkAdapter requestWithTimeout:0 delegate:nil];
            OCMVerifyAll(networkAdapter);
        });
    });
});

SpecEnd