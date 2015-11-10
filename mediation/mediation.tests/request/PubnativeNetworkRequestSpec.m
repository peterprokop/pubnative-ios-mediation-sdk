//
//  PubnativeNetworkRequestSpec.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "Specta.h"
#import "Expecta.h"
#import "PubnativeNetworkRequest.h"
#import "PubnativeConfigManager.h"
#import "PubnativeNetworkAdapter.h"
#import <OCMock/OCMock.h>

NSString * const kPlacementKey      = @"placemeny_key";
NSString * const kAppTokenKey       = @"apptoken_key";
NSString * const kPlacementInvalid  = @"placement_invalid";
NSString * const kAppTokenInvalid   = @"app_token_invalid";

@interface PubnativeNetworkRequest (Private)

- (void)adapter:(PubnativeNetworkAdapter*)adapter requestDidLoad:(PubnativeAdModel*)ad;
-(void)fetchConfigWithAppToken:(NSString*)appToken;

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
                OCMStub([request fetchConfigWithAppToken:data[kAppTokenKey]]).andDo(^(NSInvocation *invocation){
                    [request adapter:OCMClassMock([PubnativeNetworkAdapter class])
                      requestDidLoad:OCMClassMock([PubnativeAdModel class])];
                });
                
                [request startRequestWithAppToken:data[kAppTokenKey]
                                     placementKey:data[kPlacementKey]
                                         delegate:delegate];
                OCMVerify([delegate requestDidStart:[OCMArg any]]);
                OCMVerify([delegate request:[OCMArg any] didLoad:[OCMArg any]]);
                OCMVerifyAll(delegate);
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
            pending(@"write some tests");
        });
    });
});

SpecEnd
