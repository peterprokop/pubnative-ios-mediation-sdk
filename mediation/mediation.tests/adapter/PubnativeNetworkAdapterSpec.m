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

@interface PubnativeNetworkAdapter (Private)

@property (nonatomic, weak) NSObject<PubnativeNetworkAdapterDelegate> *delegate;

- (void)invokeDidStart;
- (void)invokeDidLoad:(PubnativeAdModel*)ad;
- (void)invokeDidFail:(NSError*)error;
- (void)requestTimeout;
- (void)doRequest;

@end

SpecBegin(PubnativeNetworkAdapter)

describe(@"callback methods", ^{

    context(@"with delegate", ^{
        
        __block id networkAdapterMock;
        __block id delegateMock;
        
        beforeEach(^{
            networkAdapterMock = OCMPartialMock([[PubnativeNetworkAdapter alloc] init]);
            delegateMock = OCMProtocolMock(@protocol(PubnativeNetworkAdapterDelegate));
            OCMStub([networkAdapterMock delegate]).andReturn(delegateMock);
        });
        
        it(@"invokeDidStart callback delegate", ^{
            OCMExpect([delegateMock adapterRequestDidStart:[OCMArg any]]);
            [networkAdapterMock invokeDidStart];
            OCMVerifyAll(delegateMock);
        });

        it(@"invokeDidLoad callback delegate", ^{
            id adMock = OCMClassMock([PubnativeAdModel class]);
            OCMExpect([delegateMock adapter:[OCMArg any] requestDidLoad:adMock]);
            [networkAdapterMock invokeDidLoad:adMock];
            OCMVerify([networkAdapterMock setDelegate:nil]);
            OCMVerifyAll(delegateMock);
        });

        it(@"invokeDidFail callback delegate", ^{
            id errorMock = OCMClassMock([NSError class]);
            OCMExpect([delegateMock adapter:[OCMArg any] requestDidFail:errorMock]);
            [networkAdapterMock invokeDidFail:errorMock];
            OCMVerify([networkAdapterMock setDelegate:nil]);
            OCMVerifyAll(delegateMock);
        });
    });

     context(@"without delegate", ^{
        
        __block id networkAdapterMock;
         
        beforeEach(^{
            networkAdapterMock = OCMPartialMock([[PubnativeNetworkAdapter alloc] init]);
        });
        
        it(@"invokeDidLoad, nullifies the delegate", ^{
            [networkAdapterMock invokeDidLoad:OCMClassMock([PubnativeAdModel class])];
            OCMVerify([networkAdapterMock setDelegate:nil]);
        });
        
        it(@"invokeDidFail, nullifies the delegate", ^{
            [networkAdapterMock invokeDidFail:OCMClassMock([NSError class])];
            OCMVerify([networkAdapterMock setDelegate:nil]);
        });
    });
});

describe(@"while doing request", ^{
    
    context(@"with delegate", ^{
        
        __block id networkAdapterMock;
        __block id delegateMock;
        
        beforeAll(^{
            networkAdapterMock = OCMPartialMock([[PubnativeNetworkAdapter alloc] init]);
            delegateMock = OCMProtocolMock(@protocol(PubnativeNetworkAdapterDelegate));
            OCMStub([networkAdapterMock invokeDidStart]).andDo(nil);
            OCMStub([networkAdapterMock doRequest]).andDo(nil);
        });

        it(@"and timeout, requestTimeout called", ^{
            OCMStub([networkAdapterMock invokeDidFail:[OCMArg any]]).andDo(nil);
            OCMExpect([networkAdapterMock requestTimeout]);
            [networkAdapterMock requestWithTimeout:kTimeOutHalfSecond delegate:delegateMock];
            OCMVerifyAllWithDelay(networkAdapterMock, kTimeOutHalfSecond);
        });

        it(@"and without timeout, requestTimeout not called", ^{
            [[networkAdapterMock reject] requestTimeout];
            [networkAdapterMock requestWithTimeout:0 delegate:delegateMock];
        });
        
        it(@"starts request", ^{
            [networkAdapterMock requestWithTimeout:kTimeOutHalfSecond delegate:delegateMock];
            OCMVerify([networkAdapterMock invokeDidStart]);
        });
        
        it(@"makes request", ^{
            [networkAdapterMock requestWithTimeout:kTimeOutHalfSecond delegate:delegateMock];
            OCMVerify([networkAdapterMock doRequest]);
        });
    });
    
    context(@"without delegate", ^{
        
        it(@"drops call", ^{
            id networkAdapterMock = OCMPartialMock([[PubnativeNetworkAdapter alloc] init]);
            [[networkAdapterMock reject] doRequest];
            [networkAdapterMock requestWithTimeout:0 delegate:nil];
            OCMVerifyAll(networkAdapterMock);
        });
    });
});

SpecEnd
