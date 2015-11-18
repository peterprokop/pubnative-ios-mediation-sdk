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
        
        before(^{
            delegateMock = OCMProtocolMock(@protocol(PubnativeNetworkAdapterDelegate));
            
            networkAdapterMock = OCMPartialMock([[PubnativeNetworkAdapter alloc] init]);
            OCMStub([networkAdapterMock delegate]).andReturn(delegateMock);
        });
        
        it(@"invokeDidStart callback delegate", ^{
            OCMExpect([delegateMock adapterRequestDidStart:[OCMArg isNotNil]]);
            [networkAdapterMock invokeDidStart];
            OCMVerifyAll(delegateMock);
        });

        it(@"invokeDidLoad callback delegate", ^{
            id modelMock = OCMClassMock([PubnativeAdModel class]);
            
            OCMExpect([delegateMock adapter:[OCMArg isNotNil] requestDidLoad:modelMock]);
            OCMExpect([networkAdapterMock setDelegate:[OCMArg isNil]]);
            [networkAdapterMock invokeDidLoad:modelMock];
            OCMVerifyAll(networkAdapterMock);
            OCMVerifyAll(delegateMock);
        });

        it(@"invokeDidFail callback delegate", ^{
            id errorMock = OCMClassMock([NSError class]);
            
            OCMExpect([delegateMock adapter:[OCMArg isNotNil] requestDidFail:errorMock]);
            OCMExpect([networkAdapterMock setDelegate:[OCMArg isNil]]);
            [networkAdapterMock invokeDidFail:errorMock];
            OCMVerifyAll(networkAdapterMock);
            OCMVerifyAll(delegateMock);
        });
    });

     context(@"without delegate", ^{
        
        __block id networkAdapterMock;
         
        before(^{
            networkAdapterMock = OCMPartialMock([[PubnativeNetworkAdapter alloc] init]);
        });
        
        it(@"invokeDidLoad, nullifies the delegate", ^{
            OCMExpect([networkAdapterMock setDelegate:[OCMArg isNil]]);
            [networkAdapterMock invokeDidLoad:OCMClassMock([PubnativeAdModel class])];
            OCMVerifyAll(networkAdapterMock);
        });
        
        it(@"invokeDidFail, nullifies the delegate", ^{
            OCMExpect([networkAdapterMock setDelegate:[OCMArg isNil]]);
            [networkAdapterMock invokeDidFail:OCMClassMock([NSError class])];
            OCMVerifyAll(networkAdapterMock);
        });
    });
});

describe(@"while doing request", ^{
    
    __block id networkAdapterMock;
    
    before(^{
        networkAdapterMock = OCMPartialMock([[PubnativeNetworkAdapter alloc] init]);
    });
    
    context(@"with delegate", ^{
        
        __block id delegateMock;
        __block int timeout;
        before(^{
            delegateMock = OCMProtocolMock(@protocol(PubnativeNetworkAdapterDelegate));
        });

        context(@"without timeout", ^{
            
            before(^{
                timeout = 0;
            });
            
            it(@"callbacks start and starts request", ^{
                [[networkAdapterMock reject] requestTimeout];
                
                OCMExpect([networkAdapterMock doRequest]);
                OCMExpect([networkAdapterMock invokeDidStart]);
                [networkAdapterMock requestWithTimeout:timeout delegate:delegateMock];
                
                //Verify after some time that no reject is called
                OCMVerifyAllWithDelay(networkAdapterMock, 500);
            });
        });
        
        context(@"with timeout", ^{
            
            before(^{
                timeout = 500; // Half a second
            });
            
            it(@"callbacks didStart and starts request and after some time it callbacks requestTimeout", ^{
                OCMExpect([networkAdapterMock requestTimeout]);
                OCMExpect([networkAdapterMock doRequest]);
                OCMExpect([networkAdapterMock invokeDidStart]);
                [networkAdapterMock requestWithTimeout:timeout delegate:delegateMock];
                OCMVerifyAll(networkAdapterMock);
            });
        });
    });
    
    context(@"without delegate", ^{
        
        it(@"drops call", ^{
            [[networkAdapterMock reject] doRequest];
            [networkAdapterMock requestWithTimeout:0 delegate:nil];
            OCMVerifyAll(networkAdapterMock);
        });
    });
});

SpecEnd
