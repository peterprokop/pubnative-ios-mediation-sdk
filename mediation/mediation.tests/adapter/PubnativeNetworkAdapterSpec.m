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

int const kTimeOutHalfSecond = 500;//miliseconds

@interface PubnativeNetworkAdapter (Private)

- (void) invokeStart;
- (void) invokeLoadedWithAd:(PubnativeAdModel *)adModel;
- (void) invokeFailedWithError:(NSError *)error;
- (void) cancelRequestCallbacks;
- (void) requestTimeout;
- (void) makeRequest;
- (id)performBlock:(void (^)(void))block afterDelay:(NSNumber *)timeout;
- (void) cancelBlock:(id)block;

@end

SpecBegin(PubnativeNetworkAdapter)

describe(@"PubnativeNetworkAdapterDelegate callback methods", ^{
    
    context(@"with delegate", ^{

        __block PubnativeNetworkAdapter *networkAdapter;
        __block id delegate;
        
        beforeAll(^{

            networkAdapter = OCMPartialMock([PubnativeNetworkAdapter new]);
            delegate = OCMProtocolMock(@protocol(PubnativeNetworkAdapterDelegate));
            [OCMStub(networkAdapter.delegate)andReturn:delegate];
            
        });

        it(@"invokeStart, initAdapterRequest called", ^{
            
            OCMExpect([delegate initAdapterRequest:[OCMArg any]]);
            [networkAdapter invokeStart];
            OCMVerifyAll(delegate);
            
        });
        
        it(@"invokeLoadedWithAd, loadAdapterRequest called", ^{

            OCMExpect([delegate loadAdapterRequest:[OCMArg any] withAd:[OCMArg any]]);
            [networkAdapter invokeLoadedWithAd:[OCMArg any]];
            OCMVerifyAll(delegate);

        });
        
        it(@"invokeFailedWithError, failedAdapterRequest called", ^{
            
            OCMExpect([delegate failedAdapterRequest:[OCMArg any] withError:[OCMArg any]]);
            [networkAdapter invokeFailedWithError:[OCMArg any]];
            OCMVerifyAll(delegate);
            
        });
        
    });
    
    context(@"without delegate", ^{
        
        __block id networkAdapter;
        
        beforeAll(^{

            networkAdapter = OCMPartialMock([PubnativeNetworkAdapter new]);
            
        });

        it(@"invokeStart, cancelRequestCallbacks not called", ^{

            id networkModel = OCMPartialMock([PubnativeNetworkAdapter new]);
            [[networkModel reject]cancelRequestCallbacks];
            [networkModel invokeStart];
            
        });
        
        it(@"invokeLoadedWithAd, cancelRequestCallbacks called", ^{
            
            OCMExpect([networkAdapter cancelRequestCallbacks]);
            [networkAdapter invokeLoadedWithAd:[OCMArg any]];
            OCMVerifyAll(networkAdapter);
            
        });
        
        it(@"invokeFailedWithError, cancelRequestCallbacks called", ^{
            
            OCMExpect([networkAdapter cancelRequestCallbacks]);
            [networkAdapter invokeFailedWithError:[OCMArg any]];
            OCMVerifyAll(networkAdapter);
            
        });
        
    });
    
});

describe(@"PubnativeNetworkAdapter request", ^{
    
    context(@"with delegate", ^{
        
        __block PubnativeNetworkAdapter *networkAdapter;
        __block id delegate;
        
        beforeAll(^{
            
            networkAdapter = OCMPartialMock([PubnativeNetworkAdapter new]);
            delegate = OCMProtocolMock(@protocol(PubnativeNetworkAdapterDelegate));
            [OCMStub(networkAdapter.delegate)andReturn:delegate];
            
        });
        
        it(@"with timeout", ^{
            
            OCMExpect([networkAdapter invokeStart]);
            OCMExpect([networkAdapter performBlock:[OCMArg any] afterDelay:[OCMArg any]]);
            OCMExpect([networkAdapter makeRequest]);
            [networkAdapter doRequestWithTimeout:[NSNumber numberWithInt:kTimeOutHalfSecond]];
            OCMVerifyAll((id)networkAdapter);
            
        });
        
        it(@"without timeout", ^{
            
            [[(id)networkAdapter reject]performBlock:[OCMArg any] afterDelay:[OCMArg any]];
            OCMExpect([networkAdapter invokeStart]);
            OCMExpect([networkAdapter makeRequest]);
            [networkAdapter doRequestWithTimeout:nil];
            OCMVerifyAll((id)networkAdapter);

        });
        
    });
    
    context(@"without delegate", ^{
        
        __block id networkAdapter;

        beforeAll(^{
            
            networkAdapter = OCMPartialMock([PubnativeNetworkAdapter new]);
            [[networkAdapter reject]invokeStart];
            [[networkAdapter reject]makeRequest];
            [[networkAdapter reject]performBlock:[OCMArg any] afterDelay:[OCMArg any]];

        });
        
        it(@"invokeFailedWithError called", ^{

            OCMExpect([networkAdapter invokeFailedWithError:[OCMArg any]]);
            [networkAdapter doRequestWithTimeout:nil];
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
            [networkAdapter doRequestWithTimeout:[NSNumber numberWithInt:kTimeOutHalfSecond]];
            OCMVerifyAllWithDelay((id)networkAdapter, kTimeOutHalfSecond * 0.001);
            
        });
        
        it(@"response success, do not cancel request", ^{
            
            [[(id)networkAdapter reject]requestTimeout];
            [networkAdapter doRequestWithTimeout:[NSNumber numberWithInt:kTimeOutHalfSecond]];
            
            //This is to ensure that ad is loaded and now request timeout should not be called
            [networkAdapter invokeLoadedWithAd:[OCMArg any]];
            OCMVerifyAllWithDelay((id)networkAdapter, kTimeOutHalfSecond * 0.001);
        });
        
    });
    
});



SpecEnd