//
//  PubnativeNetworkAdapterFactorySpec.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "Specta.h"
#import "Expecta.h"
#import "FacebookNetworkAdapter.h"
#import <OCMock/OCMock.h>

extern NSString * const kPlacementIdKey;

int        const kTimeOutDeactivated    = 0;
NSString * const kPlacementId           = @"test_placement_id";

@interface FacebookNetworkAdapter (Private)

- (void)doRequest;
- (void)createRequestWithPlacementId:(NSString*)placementId;
- (void)nativeAdDidLoad:(FBNativeAd*)nativeAd;
- (void)nativeAd:(FBNativeAd*)nativeAd didFailWithError:(NSError*)error;

@end

SpecBegin(FacebookNetworkAdapter)

describe(@"callback methods", ^{;
    
    context(@"invokation", ^{
        
        sharedExamples(@"invoked fail", ^(NSDictionary *data) {
            
            it(@"callback method", ^{
                FacebookNetworkAdapter *facebookAdapter = OCMPartialMock([[FacebookNetworkAdapter alloc] init]);
                id delegate = OCMProtocolMock(@protocol(PubnativeNetworkAdapterDelegate));
                OCMStub(facebookAdapter.delegate).andReturn(delegate);
                OCMStub(facebookAdapter.params).andReturn(data);
                OCMExpect([delegate adapterRequestDidStart:[OCMArg any]]);
                OCMExpect([delegate adapter:[OCMArg any] requestDidFail:[OCMArg any]]);
                [[delegate reject]adapter:[OCMArg any] requestDidLoad:[OCMArg any]];
                [facebookAdapter requestWithTimeout:kTimeOutDeactivated delegate:delegate];
                OCMVerifyAll(delegate);
            });
        });
        
        sharedExamples(@"invoked load", ^(NSDictionary *data) {
            
            it(@"callback method", ^{
                FacebookNetworkAdapter *facebookAdapter = OCMPartialMock([[FacebookNetworkAdapter alloc] init]);
                id delegate = OCMProtocolMock(@protocol(PubnativeNetworkAdapterDelegate));
                OCMStub(facebookAdapter.delegate).andReturn(delegate);
                OCMStub(facebookAdapter.params).andReturn(data);
                OCMStub([facebookAdapter createRequestWithPlacementId:data[kPlacementIdKey]]).andDo(^(NSInvocation *invocation){
                    [facebookAdapter nativeAdDidLoad:OCMClassMock([PubnativeAdModel class])];
                });
                OCMExpect([delegate adapterRequestDidStart:[OCMArg any]]);
                OCMExpect([delegate adapter:[OCMArg any] requestDidLoad:[OCMArg any]]);
                [[delegate reject]adapter:[OCMArg any] requestDidFail:[OCMArg any]];
                [facebookAdapter requestWithTimeout:kTimeOutDeactivated delegate:delegate];
                OCMVerifyAll(delegate);
            });
        });

        sharedExamples(@"with fb error invoked fail", ^(NSDictionary *data) {
            
            it(@"callback method", ^{
                FacebookNetworkAdapter *facebookAdapter = OCMPartialMock([[FacebookNetworkAdapter alloc] init]);
                id delegate = OCMProtocolMock(@protocol(PubnativeNetworkAdapterDelegate));
                OCMStub(facebookAdapter.delegate).andReturn(delegate);
                OCMStub(facebookAdapter.params).andReturn(data);
                OCMStub([facebookAdapter createRequestWithPlacementId:data[kPlacementIdKey]]).andDo(^(NSInvocation *invocation){
                    [facebookAdapter nativeAd:nil didFailWithError:[OCMArg any]];
                });
                OCMExpect([delegate adapterRequestDidStart:[OCMArg any]]);
                OCMExpect([delegate adapter:[OCMArg any] requestDidFail:[OCMArg any]]);
                [[delegate reject]adapter:[OCMArg any] requestDidLoad:[OCMArg any]];
                [facebookAdapter requestWithTimeout:kTimeOutDeactivated delegate:delegate];
                OCMVerifyAll(delegate);
            });
        });

        context(@"with delegate", ^{
            
            context(@"and params", ^{
                
                context(@"having nil placement id", ^{
                    itBehavesLike(@"invoked fail",@{});
                });
                
                context(@"with empty placement id", ^{
                    itBehavesLike(@"invoked fail",@{ kPlacementIdKey : @"" });
                });
                
                context(@"with valid placement id", ^{
                    itBehavesLike(@"invoked load",@{ kPlacementIdKey : kPlacementId});
                    itBehavesLike(@"with fb error invoked fail",@{ kPlacementIdKey : kPlacementId});
                });
            });
            
            context(@"without params", ^{
                itBehavesLike(@"invoked fail",nil);
            });
        });
        
        context(@"without delegate", ^{
            
            it(@"drops call", ^{
                id facebookAdapter = OCMPartialMock([[FacebookNetworkAdapter alloc] init]);
                [[facebookAdapter reject] doRequest];
                [facebookAdapter requestWithTimeout:0 delegate:nil];
                OCMVerifyAll(facebookAdapter);
            });
        });
    });
});

SpecEnd