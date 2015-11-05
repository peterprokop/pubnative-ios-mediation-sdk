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

- (void)invokeStart;
- (void)invokeDidLoad:(PubnativeAdModel*)ad;
- (void)invokeDidFail:(NSError*)error;
- (void)cancelTimeout;
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
        
        beforeAll(^{
            networkAdapter = OCMPartialMock([PubnativeNetworkAdapter new]);
            delegate = OCMProtocolMock(@protocol(PubnativeNetworkAdapterDelegate));
            [OCMStub(networkAdapter.delegate)andReturn:delegate];
        });
        
        it(@"invokeStart, call adapterRequestDidStart:", ^{
            OCMExpect([delegate adapterRequestDidStart:[OCMArg any]]);
            [networkAdapter invokeStart];
            OCMVerifyAll(delegate);
        });
        
        it(@"invokeDidLoad, call adapter:requestDidLoad:", ^{
            OCMExpect([delegate adapter:[OCMArg any] requestDidLoad:[OCMArg any]]);
            [networkAdapter invokeDidLoad:[OCMArg any]];
            OCMVerifyAll(delegate);
        });
        
        it(@"invokeDidFail, call adapter:requestDidFail:", ^{
            OCMExpect([delegate adapter:[OCMArg any] requestDidFail:[OCMArg any]]);
            [networkAdapter invokeDidFail:[OCMArg any]];
            OCMVerifyAll(delegate);
        });
    });
    
    context(@"without delegate", ^{
        __block id networkAdapter;
        
        beforeAll(^{
            networkAdapter = OCMPartialMock([PubnativeNetworkAdapter new]);
        });
        
        it(@"invokeStart, do not call cancelRequestCallbacks", ^{
            id networkModel = OCMPartialMock([PubnativeNetworkAdapter new]);
            [[networkModel reject]cancelTimeout];
            [networkModel invokeStart];
        });
        
        it(@"invokeDidLoad, call cancelRequestCallbacks", ^{
            OCMExpect([networkAdapter cancelTimeout]);
            [networkAdapter invokeDidLoad:[OCMArg any]];
            OCMVerifyAll(networkAdapter);
        });
        
        it(@"invokeDidFail, call cancelRequestCallbacks", ^{
            OCMExpect([networkAdapter cancelTimeout]);
            [networkAdapter invokeDidFail:[OCMArg any]];
            OCMVerifyAll(networkAdapter);
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
        
        it(@"with timeout", ^{
            OCMExpect([networkAdapter invokeStart]);
            OCMExpect([networkAdapter doRequest]);
            OCMExpect([networkAdapter requestTimeout]);
            [networkAdapter doRequestWithTimeout:kTimeOutHalfSecond delegate:delegateMock];
            OCMVerifyAllWithDelay((id)networkAdapter, kTimeOutHalfSecond);
        });
        
        it(@"without timeout", ^{
            [[(id)networkAdapter reject] requestTimeout];
            OCMExpect([networkAdapter invokeStart]);
            OCMExpect([networkAdapter doRequest]);
            [networkAdapter doRequestWithTimeout:kTimeOutZeroSecond delegate:delegateMock];
            OCMVerifyAll((id)networkAdapter);
        });
    });
    
    context(@"without delegate", ^{
        __block id networkAdapter;
        
        beforeAll(^{
            networkAdapter = OCMPartialMock([PubnativeNetworkAdapter new]);
        });
        
        it(@"drops call", ^{
            [[networkAdapter reject] doRequest];
            [networkAdapter doRequestWithTimeout:0 delegate:nil];
            OCMVerifyAll(networkAdapter);
        });
    });
    
    context(@"timeout", ^{
        __block PubnativeNetworkAdapter *networkAdapter;
        __block id delegate;
        
        beforeAll(^{
            networkAdapter = OCMPartialMock([PubnativeNetworkAdapter new]);
            delegate = OCMProtocolMock(@protocol(PubnativeNetworkAdapterDelegate));
            [OCMStub(networkAdapter.delegate)andReturn:delegate];
        });
        
        it(@"request timeout, cancel request", ^{
            OCMExpect([networkAdapter requestTimeout]);
            [networkAdapter doRequestWithTimeout:kTimeOutHalfSecond delegate:delegate];
            OCMVerifyAllWithDelay((id)networkAdapter, kTimeOutHalfSecond * 0.001);
        });
        
        it(@"response success, do not cancel request", ^{
            OCMExpect([networkAdapter cancelTimeout]);
            [networkAdapter invokeDidLoad:[OCMArg any]];
            OCMVerifyAll((id)networkAdapter);
        });
        
        it(@"response failed, do not cancel request", ^{
            OCMExpect([networkAdapter cancelTimeout]);
            [networkAdapter invokeDidFail:[OCMArg any]];
            OCMVerifyAll((id)networkAdapter);
        });
        
    });
    
    context(@"cancel callback", ^{
        __block PubnativeNetworkAdapter                     *networkAdapter;
        __block NSObject<PubnativeNetworkAdapterDelegate>   *delegate;
        
        beforeAll(^{
            networkAdapter = [PubnativeNetworkAdapter new];
            delegate = OCMProtocolMock(@protocol(PubnativeNetworkAdapterDelegate));
            networkAdapter.delegate = delegate;
        });
        
        it(@"set delegate to nil", ^{
            [networkAdapter cancelTimeout];
            expect(networkAdapter.delegate).to.beNil();
        });
    });
});

SpecEnd