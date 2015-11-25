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

NSString * const kPlacementInvalid  = @"placement_invalid";
NSString * const kAppTokenInvalid   = @"apptoken_invalid";
NSString * const kPlacementIdValid  = @"facebook_only";
NSString * const kConfigValid       = @"config_valid";
NSString * const kConfigEmpty       = @"config_empty";

@interface PubnativeNetworkAdapter (Private)

@property (nonatomic, weak)NSObject <PubnativeNetworkAdapterDelegate> *delegate;

- (void)doRequest;

@end

@interface PubnativeNetworkRequest (Private)

@property (nonatomic, weak)     NSObject <PubnativeNetworkRequestDelegate>  *delegate;
@property (nonatomic, strong)   NSString                                    *placementID;
@property (nonatomic, strong)   PubnativePlacementModel                     *placement;
@property (nonatomic, strong)   PubnativeConfigModel                        *config;
@property (nonatomic, assign)   int                                         currentNetworkIndex;

- (void)adapter:(PubnativeNetworkAdapter*)adapter requestDidLoad:(PubnativeAdModel*)ad;
- (void)invokeDidStart;
- (void)invokeDidFail:(NSError*)error;
- (void)invokeDidLoad:(PubnativeAdModel*)ad;
- (void)configDidFinishWithModel:(PubnativeConfigModel*)model;
- (void)startRequestWithConfig:(PubnativeConfigModel*)config;
- (void)doNextNetworkRequest;

@end

SpecBegin(PubnativeNetworkRequest)

describe(@"callback methods", ^{
    
    NSString * const kPlacementKey  = @"placement_key";
    NSString * const kAppTokenKey   = @"apptoken_key";
    
    context(@"invokation", ^{
        
        __block id requestMock;
        __block id delegateMock;
        
        before(^{
            requestMock = OCMPartialMock([[PubnativeNetworkRequest alloc] init]);
            delegateMock = OCMProtocolMock(@protocol(PubnativeNetworkRequestDelegate));
        });
        
        sharedExamples(@"invoke fail", ^(NSDictionary *data) {
            
            it(@"callback method", ^{
                [requestMock startRequestWithAppToken:data[kAppTokenKey]
                                          placementID:data[kPlacementKey]
                                             delegate:delegateMock];
                OCMVerify([delegateMock requestDidStart:[OCMArg any]]);
                OCMVerify([delegateMock request:[OCMArg any] didFail:[OCMArg any]]);
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
                
                it(@"invoke load callback method", ^{
                    id configManager = OCMClassMock([PubnativeConfigManager class]);
                    
                    // Given
                    // Stub Manager to return a mock ad directly
                    OCMStub([configManager configWithAppToken:[OCMArg any] delegate:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
                        [requestMock adapter:OCMClassMock([PubnativeNetworkAdapter class])
                              requestDidLoad:OCMClassMock([PubnativeAdModel class])];
                    });
                    
                    // When
                    [requestMock startRequestWithAppToken:kAppTokenInvalid
                                              placementID:kPlacementInvalid
                                                 delegate:delegateMock];
                    
                    // Verify
                    OCMVerify([delegateMock requestDidStart:[OCMArg any]]);
                    OCMVerify([delegateMock request:[OCMArg any] didLoad:[OCMArg any]]);
                });
            });
        });
    });
});

describe(@"start request", ^{
    
    __block id requestMock;
    
    before(^{
        requestMock = OCMPartialMock([[PubnativeNetworkRequest alloc] init]);
    });
    
    context(@"with delegate", ^{
        
        __block id delegateMock;
        __block id configManagerMock;
        
        before(^{
            delegateMock = OCMProtocolMock(@protocol(PubnativeNetworkRequestDelegate));
            configManagerMock = OCMClassMock([PubnativeConfigManager class]);
        });
        
        context(@"and config", ^{
            
            __block id adMock;
            __block id adapterMock;
            __block id adapterFactoryMock;
            
            before(^{
                adMock = OCMClassMock([PubnativeAdModel class]);
                adapterMock = OCMPartialMock([[PubnativeNetworkAdapter alloc] init]);
                
                // Given
                // Stub Adapter doRequest to callback directly
                OCMStub([adapterMock doRequest]).andDo(^(NSInvocation *invocation){
                    [[adapterMock delegate] adapterRequestDidStart:adapterMock];
                    [[adapterMock delegate] adapter:adapterMock requestDidLoad:adMock];
                });
                
                // Given
                // Stub Factory create to return a mock adapter
                adapterFactoryMock = OCMClassMock([PubnativeNetworkAdapterFactory class]);
                OCMStub([adapterFactoryMock createApdaterWithNetwork:[OCMArg any]]).andReturn(adapterMock);
            });
            
            it(@"having valid parameters, invoke request:didLoad:", ^{
                // Given
                // Stub Manager to return a mock config directly
                OCMStub([configManagerMock configWithAppToken:[OCMArg any] delegate:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
                    [requestMock configDidFinishWithModel:[PubnativeConfigUtils getModelFromJSONFile:kConfigValid]];
                });
                
                // Reject
                [[delegateMock reject] request:[OCMArg any] didFail:[OCMArg any]];
                
                // When
                [requestMock startRequestWithAppToken:kAppTokenInvalid
                                          placementID:kPlacementIdValid
                                             delegate:delegateMock];
                
                // Veify
                OCMVerify([delegateMock requestDidStart:[OCMArg isNotNil]]);
                OCMVerify([delegateMock request:[OCMArg isNotNil] didLoad:[OCMArg isNotNil]]);
            });
            
            it(@"having invalid placementID, invoke request:didFail:", ^{
                // Given
                // Stub Manager to return a mock config directly
                OCMStub([configManagerMock configWithAppToken:[OCMArg any] delegate:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
                    [requestMock configDidFinishWithModel:[PubnativeConfigUtils getModelFromJSONFile:kConfigValid]];
                });
                
                // When
                [requestMock startRequestWithAppToken:kAppTokenInvalid
                                          placementID:@"invalid_placement_ID"
                                             delegate:delegateMock];
                
                // Veify
                OCMVerify([delegateMock requestDidStart:[OCMArg isNotNil]]);
                OCMVerify([delegateMock request:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
            });
            
            it(@"having invalid delivery_rule, invoke request:didFail:", ^{
                PubnativePlacementModel *placementMock = OCMClassMock([PubnativePlacementModel class]);
                // Given
                OCMStub([placementMock delivery_rules]).andReturn(nil);
                OCMStub([requestMock placement]).andReturn(placementMock);
                
                // Given
                // Stub Manager to return a mock config directly
                OCMStub([configManagerMock configWithAppToken:[OCMArg any] delegate:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
                    [requestMock configDidFinishWithModel:[PubnativeConfigUtils getModelFromJSONFile:kConfigValid]];
                });
                
                // When
                [requestMock startRequestWithAppToken:kAppTokenInvalid
                                          placementID:kPlacementIdValid
                                             delegate:delegateMock];
                
                // Veify
                OCMVerify([delegateMock requestDidStart:[OCMArg isNotNil]]);
                OCMVerify([delegateMock request:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
            });
            
            it(@"having inactive delivery_rule, invoke request:didFail:", ^{
                PubnativePlacementModel *placementMock = OCMClassMock([PubnativePlacementModel class]);
                PubnativeDeliveryRuleModel *delivery_rules = OCMPartialMock([[PubnativeDeliveryRuleModel alloc] init]);
                // Given
                OCMStub([delivery_rules isActive]).andReturn(NO);
                OCMStub([placementMock delivery_rules]).andReturn(delivery_rules);
                OCMStub([requestMock placement]).andReturn(placementMock);
                
                // Given
                // Stub Manager to return a mock config directly
                OCMStub([configManagerMock configWithAppToken:[OCMArg any] delegate:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
                    [requestMock configDidFinishWithModel:[PubnativeConfigUtils getModelFromJSONFile:kConfigValid]];
                });
                
                // When
                [requestMock startRequestWithAppToken:kAppTokenInvalid
                                          placementID:kPlacementIdValid
                                             delegate:delegateMock];
                
                // Veify
                OCMVerify([delegateMock requestDidStart:[OCMArg isNotNil]]);
                OCMVerify([delegateMock request:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
            });
            
            after(^{
                [adapterFactoryMock stopMocking];
            });
            
        });
        
        it(@"and empty config", ^{
            // Given
            // Stub Manager to return a mock config directly
            OCMStub([configManagerMock configWithAppToken:[OCMArg any] delegate:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
                [requestMock configDidFinishWithModel:[PubnativeConfigUtils getModelFromJSONFile:kConfigEmpty]];
            });
            
            // Reject
            [[delegateMock reject] request:[OCMArg any] didLoad:[OCMArg any]];
            
            // When
            [requestMock startRequestWithAppToken:kAppTokenInvalid
                                      placementID:kPlacementInvalid
                                         delegate:delegateMock];
            
            // Verify
            OCMVerify([delegateMock requestDidStart:[OCMArg any]]);
            OCMVerify([delegateMock request:[OCMArg any] didFail:[OCMArg any]]);
        });
    });
    
    context(@"without delegate", ^{
        
        it(@"drops call", ^{
            //This should not crash
            [requestMock startRequestWithAppToken:kAppTokenInvalid
                                      placementID:kPlacementInvalid
                                         delegate:nil];
        });
    });
});

describe(@"network request", ^{
    
    context(@"conforms and implements", ^{
        
        __block id requestMock;
        
        before(^{
            requestMock = OCMPartialMock([[PubnativeNetworkRequest alloc] init]);
        });
        
        it(@"PubnativeConfigManagerDelegate", ^{
            expect([requestMock conformsToProtocol:@protocol(PubnativeConfigManagerDelegate)]).to.beTruthy();
            expect([requestMock respondsToSelector:@selector(configDidFailWithError:)]).to.beTruthy();
            expect([requestMock respondsToSelector:@selector(configDidFinishWithModel:)]).to.beTruthy();
        });
        
        it(@"PubnativeNetworkAdapterDelegate", ^{
            expect([requestMock conformsToProtocol:@protocol(PubnativeNetworkAdapterDelegate)]).to.beTruthy();
            expect([requestMock respondsToSelector:@selector(adapterRequestDidStart:)]).to.beTruthy();
            expect([requestMock respondsToSelector:@selector(adapter:requestDidLoad:)]).to.beTruthy();
            expect([requestMock respondsToSelector:@selector(adapter:requestDidFail:)]).to.beTruthy();
        });
    });
});

describe(@"private method", ^{
    
    context(@"startRequestWithConfig:", ^{
        
        __block id requestMock;
        
        before(^{
            requestMock = OCMPartialMock([[PubnativeNetworkRequest alloc] init]);
        });
        
        it(@"valid config, invoke doNextNetworkRequest", ^{
            OCMStub([requestMock placementID]).andReturn(kPlacementIdValid);
            [requestMock startRequestWithConfig:[PubnativeConfigUtils getModelFromJSONFile:kConfigValid]];
            OCMVerify([requestMock doNextNetworkRequest]);
        });
        
        it(@"invalid config, invoke fail", ^{
            OCMStub([requestMock placementID]).andReturn(kPlacementIdValid);
            [requestMock startRequestWithConfig:[PubnativeConfigUtils getModelFromJSONFile:kConfigEmpty]];
            OCMVerify([requestMock invokeDidFail:[OCMArg isNotNil]]);
        });
        
        it(@"nil config, invoke fail", ^{
            OCMStub([requestMock placementID]).andReturn(kPlacementIdValid);
            [requestMock startRequestWithConfig:nil];
            OCMVerify([requestMock invokeDidFail:[OCMArg isNotNil]]);
        });
 
        it(@"config with invalid placementID, invoke fail", ^{
            OCMStub([requestMock placementID]).andReturn(@"invalid_placement_ID");
            [requestMock startRequestWithConfig:[PubnativeConfigUtils getModelFromJSONFile:kConfigValid]];
            OCMVerify([requestMock invokeDidFail:[OCMArg isNotNil]]);
        });
    });
    
    context(@"doNextNetworkRequest", ^{
        
        __block id requestMock;
        
        before(^{
            requestMock = OCMPartialMock([[PubnativeNetworkRequest alloc] init]);
            OCMStub([requestMock currentNetworkIndex]).andReturn(0).andForwardToRealObject();
        });
        
        NSString *networkCodeKey    = @"network_code_key";
        NSString *configKey         = @"config_key";
        
        NSString *sharedExampleName = @"makes";
        sharedExamples(sharedExampleName, ^(NSDictionary *data) {
            
            it(@"next request", ^{
                id priorityRuleMock = OCMPartialMock([[PubnativePriorityRulesModel alloc] init]);
                OCMStub([priorityRuleMock network_code]).andReturn(data[networkCodeKey]);
                id placementMock = OCMPartialMock([[PubnativePlacementModel alloc] init]);
                NSArray *placement = [[NSArray alloc] initWithObjects:priorityRuleMock, nil];
                OCMStub([placementMock priority_rules]).andReturn(placement);
                OCMStub([requestMock placement]).andReturn(placementMock);
                OCMStub([requestMock config]).andReturn([PubnativeConfigUtils getModelFromJSONFile:data[configKey]]);
                [requestMock doNextNetworkRequest];
                OCMVerify([requestMock doNextNetworkRequest]);
                expect([requestMock currentNetworkIndex]).to.equal([placement count]);
            });
        });
        
        context(@"with nil network code, nil config", ^{
            itBehavesLike(sharedExampleName, nil);
        });
        
        context(@"with nil network code, empty config", ^{
            itBehavesLike(sharedExampleName, @{ configKey : kConfigEmpty });
        });
        
        context(@"with nil network code, valid config", ^{
            itBehavesLike(sharedExampleName, @{ configKey : kConfigValid });
        });
        
        context(@"with empty network code, nil config", ^{
            itBehavesLike(sharedExampleName, @{ networkCodeKey : @""});
        });
        
        context(@"with empty network code, empty config", ^{
            itBehavesLike(sharedExampleName, @{ networkCodeKey : @"", configKey : kConfigEmpty });
        });
        
        context(@"with empty network code, valid config", ^{
            itBehavesLike(sharedExampleName, @{ networkCodeKey : @"", configKey : kConfigValid });
        });
        
        context(@"with valid network code, nil config", ^{
            itBehavesLike(sharedExampleName, @{ networkCodeKey : @"facebook"});
        });
        
        context(@"with valid network code, empty config", ^{
            itBehavesLike(sharedExampleName, @{ networkCodeKey : @"facebook", configKey : kConfigEmpty });
        });
        
        context(@"with valid network code, valid config", ^{
            
            context(@"adapter created", ^{
                
                it(@"make request", ^{
                    id priorityRuleMock = OCMPartialMock([[PubnativePriorityRulesModel alloc] init]);
                    OCMStub([priorityRuleMock network_code]).andReturn(@"facebook");
                    id placementMock = OCMPartialMock([[PubnativePlacementModel alloc] init]);
                    NSArray *placement = [[NSArray alloc] initWithObjects:priorityRuleMock, nil];
                    OCMStub([placementMock priority_rules]).andReturn(placement);
                    OCMStub([requestMock placement]).andReturn(placementMock);
                    OCMStub([requestMock config]).andReturn([PubnativeConfigUtils getModelFromJSONFile:kConfigValid]);
                    
                    // Given
                    // Stub Factory create to return a mock adapter
                    id adapterMock = OCMPartialMock([[PubnativeNetworkAdapter alloc] init]);
                    id adapterFactoryMock = OCMClassMock([PubnativeNetworkAdapterFactory class]);
                    OCMStub([adapterFactoryMock createApdaterWithNetwork:[OCMArg any]]).andReturn(adapterMock);
                    [requestMock doNextNetworkRequest];
                    OCMVerify([[adapterMock ignoringNonObjectArgs] requestWithTimeout:0 delegate:[OCMArg isNotNil]]);
                });
            });
            
            context(@"adapter not created", ^{
                
                it(@"makes next request", ^{
                    id priorityRuleMock = OCMPartialMock([[PubnativePriorityRulesModel alloc] init]);
                    OCMStub([priorityRuleMock network_code]).andReturn(@"facebook");
                    id placementMock = OCMPartialMock([[PubnativePlacementModel alloc] init]);
                    NSArray *placement = [[NSArray alloc] initWithObjects:priorityRuleMock, nil];
                    OCMStub([placementMock priority_rules]).andReturn(placement);
                    OCMStub([requestMock placement]).andReturn(placementMock);
                    OCMStub([requestMock config]).andReturn([PubnativeConfigUtils getModelFromJSONFile:kConfigValid]);
                    
                    id adapterFactoryMock = OCMClassMock([PubnativeNetworkAdapterFactory class]);
                    OCMStub([adapterFactoryMock createApdaterWithNetwork:[OCMArg any]]).andReturn(nil);
                    [requestMock doNextNetworkRequest];
                    OCMVerify([requestMock doNextNetworkRequest]);
                    expect([requestMock currentNetworkIndex]).to.equal([placement count]);
                });
            });
        });
    });
});

SpecEnd
