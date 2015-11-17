//
//  PubnativeNetworkRequestSpec.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "Specta.h"
#import "Expecta.h"
#import "PubnativeConfigManager.h"
#import "PubnativeConfigUtils.h"
#import "PubnativeNetworkAdapter.h"
#import "PubnativeNetworkAdapterFactory.h"
#import "PubnativeNetworkRequest.h"

#import <OCMock/OCMock.h>

NSString * const kPlacementKey      = @"placemeny_key";
NSString * const kAppTokenKey       = @"apptoken_key";
NSString * const kPlacementInvalid  = @"placement_invalid";
NSString * const kAppTokenInvalid   = @"app_token_invalid";

@interface PubnativeNetworkAdapter (Private)

@property (nonatomic, weak)NSObject<PubnativeNetworkAdapterDelegate> *delegate;

- (void)doRequest;

@end

@interface PubnativeNetworkRequest (Private)

@property (weak, nonatomic)id <PubnativeNetworkRequestDelegate>      delegate;

- (void)adapter:(PubnativeNetworkAdapter*)adapter requestDidLoad:(PubnativeAdModel*)ad;
- (void)fetchConfigWithAppToken:(NSString*)appToken;
- (void)invokeDidStart;
- (void)invokeDidFail:(NSError*)error;
- (void)invokeDidLoad:(PubnativeAdModel*)ad;
- (void)configDidFinishWithModel:(PubnativeConfigModel*)model;

@end

SpecBegin(PubnativeNetworkRequest)

describe(@"callback methods", ^{
    
    context(@"invokation", ^{
        
        sharedExamples(@"invoke fail", ^(NSDictionary *data) {
            
            it(@"callback method", ^{
                PubnativeNetworkRequest *request = OCMPartialMock([[PubnativeNetworkRequest alloc] init]);
                id delegate = OCMProtocolMock(@protocol(PubnativeNetworkRequestDelegate));
                [request startRequestWithAppToken:data[kAppTokenKey]
                                     placementKey:data[kPlacementKey]
                                         delegate:delegate];
                OCMVerify([delegate requestDidStart:[OCMArg any]]);
                OCMVerify([delegate request:[OCMArg any] didFail:[OCMArg any]]);
            });
        });
        
        sharedExamples(@"invoke load", ^(NSDictionary *data) {
            
            it(@"callback method", ^{
                PubnativeNetworkRequest *request = OCMPartialMock([[PubnativeNetworkRequest alloc] init]);
                id delegate = OCMProtocolMock(@protocol(PubnativeNetworkRequestDelegate));
                OCMStub([request fetchConfigWithAppToken:data[kAppTokenKey]]).andDo(^(NSInvocation *invocation) {
                    [request adapter:OCMClassMock([PubnativeNetworkAdapter class])
                      requestDidLoad:OCMClassMock([PubnativeAdModel class])];
                });
                
                [request startRequestWithAppToken:data[kAppTokenKey]
                                     placementKey:data[kPlacementKey]
                                         delegate:delegate];
                OCMVerify([delegate requestDidStart:[OCMArg any]]);
                OCMVerify([delegate request:[OCMArg any] didLoad:[OCMArg any]]);
            });
        });
        
        context(@"with delegate", ^{
            
            context(@"having nil apptoken and nil placementKey", ^{
                itBehavesLike(@"invoke fail", nil);
            });
            
            context(@"having nil apptoken and empty placementKey", ^{
                itBehavesLike(@"invoke fail", @{ kPlacementKey : @""});
            });
            
            context(@"having nil apptoken and invalid placementKey", ^{
                itBehavesLike(@"invoke fail", @{ kPlacementKey : kPlacementInvalid});
            });
            
            context(@"having empty apptoken and nil placementKey", ^{
                itBehavesLike(@"invoke fail", @{ kAppTokenKey : @""});
            });
            
            context(@"having empty apptoken and empty placementKey", ^{
                itBehavesLike(@"invoke fail", @{ kAppTokenKey : @"", kPlacementKey : @""});
            });
            
            context(@"having empty apptoken and invalid placementKey", ^{
                itBehavesLike(@"invoke fail", @{ kAppTokenKey : @"", kPlacementKey : kPlacementInvalid});
            });
            
            context(@"having invalid apptoken and nil placementKey", ^{
                itBehavesLike(@"invoke fail", @{ kAppTokenKey : kAppTokenInvalid});
            });
            
            context(@"having invalid apptoken and empty placementKey", ^{
                itBehavesLike(@"invoke fail", @{ kAppTokenKey : kAppTokenInvalid, kPlacementKey : @""});
            });
            
            context(@"having invalid apptoken and invalid placementKey", ^{
                itBehavesLike(@"invoke load", @{ kAppTokenKey : kAppTokenInvalid, kPlacementKey : kPlacementInvalid});
            });
        });
        
        context(@"without delegate", ^{
            
            it(@"drops call", ^{
                PubnativeNetworkRequest *request = OCMPartialMock([[PubnativeNetworkRequest alloc] init]);
                request.delegate = nil;
                [request invokeDidStart];
                [request invokeDidLoad:[OCMArg any]];
                [request invokeDidFail:[OCMArg any]];
            });
        });
    });
});


describe(@"start request", ^{
    
    context(@"with delegate", ^{
        
        it(@"and valid config", ^{
            
            PubnativeAdModel *ad = OCMClassMock([PubnativeAdModel class]);
            PubnativeNetworkAdapter *adapter = OCMPartialMock([[PubnativeNetworkAdapter alloc] init]);
            // Stub Adapter doRequest to callback directly
            OCMStub([adapter doRequest]).andDo(^(NSInvocation *invocation){
                [adapter.delegate adapterRequestDidStart:adapter];
                [adapter.delegate adapter:adapter requestDidLoad:ad];
            });
            
            // Stub Factory create to return a mock adapter
            id adapterFactory = OCMClassMock([PubnativeNetworkAdapterFactory class]);
            OCMStub([adapterFactory createApdaterWithNetwork:[OCMArg any]]).andReturn(adapter);
            
            PubnativeNetworkRequest *request = OCMPartialMock([[PubnativeNetworkRequest alloc] init]);
            id delegate = OCMProtocolMock(@protocol(PubnativeNetworkRequestDelegate));
            OCMStub([request fetchConfigWithAppToken:kAppTokenInvalid]).andDo(^(NSInvocation *invocation) {
                [request configDidFinishWithModel:[PubnativeConfigUtils getModelFromJSONFile:@"config_valid"]];
            });
            
            [[delegate reject]request:[OCMArg any] didFail:[OCMArg any]];
            [request startRequestWithAppToken:kAppTokenInvalid
                                 placementKey:@"facebook_only"
                                     delegate:delegate];
            OCMVerify([delegate requestDidStart:[OCMArg any]]);
            OCMVerify([delegate request:[OCMArg any] didLoad:[OCMArg any]]);
            [adapterFactory stopMocking];
        });
        
        it(@"and empty config", ^{
            
            PubnativeNetworkRequest *request = OCMPartialMock([[PubnativeNetworkRequest alloc] init]);
            id delegate = OCMProtocolMock(@protocol(PubnativeNetworkRequestDelegate));
            OCMStub([request fetchConfigWithAppToken:kAppTokenInvalid]).andDo(^(NSInvocation *invocation) {
                [request configDidFinishWithModel:[PubnativeConfigUtils getModelFromJSONFile:@"config_empty"]];
            });
            
            [[delegate reject]request:[OCMArg any] didLoad:[OCMArg any]];
            [request startRequestWithAppToken:kAppTokenInvalid
                                 placementKey:kPlacementInvalid
                                     delegate:delegate];
            OCMVerify([delegate requestDidStart:[OCMArg any]]);
            OCMVerify([delegate request:[OCMArg any] didFail:[OCMArg any]]);
        });
    });
    
    context(@"without delegate", ^{
        
        it(@"drops call", ^{
            //This should not crash
            PubnativeNetworkRequest *request = OCMPartialMock([[PubnativeNetworkRequest alloc] init]);
            [request startRequestWithAppToken:kAppTokenInvalid
                                 placementKey:kPlacementInvalid
                                     delegate:nil];
        });
    });
});

SpecEnd
