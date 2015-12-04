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

@interface PubnativeNetworkAdapter (Private)

@property (nonatomic, weak)NSObject <PubnativeNetworkAdapterDelegate> *delegate;

- (void)doRequest;

@end

@interface PubnativeNetworkRequest (Private)

@property (nonatomic, weak)     NSObject <PubnativeNetworkRequestDelegate>  *delegate;
@property (nonatomic, strong)   NSString                                    *placementID;
@property (nonatomic, strong)   NSString                                    *appToken;
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

describe(@"objects from this class", ^{
    
    __block id requestMock;
    
    before(^{
        requestMock = OCMClassMock([PubnativeNetworkRequest class]);
    });
    
    it(@"conforms to protocol PubnativeConfigManagerDelegate", ^{
        expect([requestMock conformsToProtocol:@protocol(PubnativeConfigManagerDelegate)]).to.beTruthy();
    });
    
    it(@"contains the methods for protocol PubnativeConfigManagerDelegate", ^{
        expect([requestMock respondsToSelector:@selector(configDidFailWithError:)]).to.beTruthy();
        expect([requestMock respondsToSelector:@selector(configDidFinishWithModel:)]).to.beTruthy();
    });
    
    it(@"conforms to protocol PubnativeNetworkAdapterDelegate", ^{
        expect([requestMock conformsToProtocol:@protocol(PubnativeNetworkAdapterDelegate)]).to.beTruthy();
    });
    
    it(@"contains the methods for protocol PubnativeNetworkAdapterDelegate", ^{
        expect([requestMock respondsToSelector:@selector(adapterRequestDidStart:)]).to.beTruthy();
        expect([requestMock respondsToSelector:@selector(adapter:requestDidLoad:)]).to.beTruthy();
        expect([requestMock respondsToSelector:@selector(adapter:requestDidFail:)]).to.beTruthy();
    });
});

describe(@"while doing a request callback", ^{
    
    __block id requestMock;
    __block id delegateMock;
    
    before(^{
        requestMock = OCMPartialMock([[PubnativeNetworkRequest alloc] init]);
        delegateMock = OCMProtocolMock(@protocol(PubnativeNetworkRequestDelegate));
        OCMStub([requestMock delegate]).andReturn(delegateMock);
    });
    
    context(@"on fail", ^{
        
        __block id errorMock;
        
        before(^{
            errorMock = OCMClassMock([NSError class]);
        });
        
        it(@"callback and nullifies the delegate", ^{
            OCMExpect([requestMock setDelegate:nil]);
            OCMExpect([delegateMock pubnativeRequest:[OCMArg isNotNil] didFail:errorMock]);
            [requestMock invokeDidFail:errorMock];
            OCMVerifyAll(requestMock);
            OCMVerifyAll(delegateMock);
        });
    });

    context(@"on success", ^{
        
        __block id adMock;
        
        before(^{
            adMock = OCMClassMock([PubnativeAdModel class]);
        });
        
        it(@"callback and nullifies the delegate", ^{
            OCMExpect([requestMock setDelegate:nil]);
            OCMExpect([delegateMock pubnativeRequest:[OCMArg isNotNil] didLoad:adMock]);
            [requestMock invokeDidLoad:adMock];
            OCMVerifyAll(requestMock);
            OCMVerifyAll(delegateMock);
        });
    });
});

describe(@"when starting a request", ^{
    
    __block id requestMock;
    
    before(^{
        requestMock = OCMPartialMock([[PubnativeNetworkRequest alloc] init]);
    });
    
    context(@"with valid config", ^{
        
        __block id validConfigMock;
        
        before(^{
            validConfigMock = OCMClassMock([PubnativeConfigModel class]);
            OCMStub([validConfigMock isEmpty]).andReturn(NO);
        });
        
        context(@"and placement list", ^{
            
            __block id configPlacementsMock;
            
            before(^{
                configPlacementsMock = OCMClassMock([NSDictionary class]);
                OCMStub([validConfigMock placements]).andReturn(configPlacementsMock);
            });
            
            context(@"which have placement corresponding to placement Id", ^{
                
                __block id placementMock;
                
                before(^{
                    placementMock = OCMClassMock([PubnativePlacementModel class]);
                    OCMStub([configPlacementsMock objectForKey:[OCMArg any]]).andReturn(placementMock);
                });
                
                context(@"with nil delievery rules ", ^{
                    
                    before(^{
                        OCMStub([placementMock delivery_rule]).andReturn(nil);
                    });
                    
                    it(@"invoke fail", ^{
                        OCMExpect([requestMock invokeDidFail:[OCMArg isNotNil]]);
                        [requestMock startRequestWithConfig:validConfigMock];
                        OCMVerifyAll(requestMock);
                    });
                });
                
                context(@"with delievery rules", ^{
                    
                    __block id deliveryRulesMock;
                    
                    before(^{
                        deliveryRulesMock = OCMClassMock([PubnativeDeliveryRuleModel class]);;
                        OCMStub([placementMock delivery_rule]).andReturn(deliveryRulesMock);
                    });
                    
                    context(@"when active", ^{
                        
                        before(^{
                            OCMStub([deliveryRulesMock isActive]).andReturn(YES);
                        });
                        
                        it(@"do next request and continue", ^{
                            OCMExpect([requestMock doNextNetworkRequest]);
                            [requestMock startRequestWithConfig:validConfigMock];
                            OCMVerifyAll(requestMock);
                        });
                    });
                    
                    context(@"when inactive", ^{
                        
                        before(^{
                            OCMStub([deliveryRulesMock isActive]).andReturn(NO);
                        });
                        
                        it(@"invoke fail", ^{
                            OCMExpect([requestMock invokeDidFail:[OCMArg isNotNil]]);
                            [requestMock startRequestWithConfig:validConfigMock];
                            OCMVerifyAll(requestMock);
                        });
                    });
                });
            });
            
            context(@"which does not have placement corresponding to placement Id", ^{
                
                before(^{
                    OCMStub([configPlacementsMock objectForKey:[OCMArg isNotNil]]).andReturn(nil);
                });
                
                it(@"invoke fail", ^{
                    OCMExpect([requestMock invokeDidFail:[OCMArg isNotNil]]);
                    [requestMock startRequestWithConfig:validConfigMock];
                    OCMVerifyAll(requestMock);
                });
            });
        });
    });
    
    context(@"with empty config", ^{
        
        __block id emptyConfigMock;
        
        before(^{
            emptyConfigMock = OCMClassMock([PubnativeConfigModel class]);
            OCMStub([emptyConfigMock isEmpty]).andReturn(YES);
        });
        
        it(@"invoke fail", ^{
            OCMExpect([requestMock invokeDidFail:[OCMArg isNotNil]]);
            [requestMock startRequestWithConfig:emptyConfigMock];
            OCMVerifyAll(requestMock);
        });
    });
    
    context(@"with nil config", ^{
        
        it(@"invoke fail", ^{
            OCMExpect([requestMock invokeDidFail:[OCMArg isNotNil]]);
            [requestMock startRequestWithConfig:nil];
            OCMVerifyAll(requestMock);
        });
    });
});

describe(@"when making next request", ^{
    
    __block id requestMock;
    
    before(^{
        requestMock = OCMPartialMock([[PubnativeNetworkRequest alloc] init]);
        OCMStub([requestMock currentNetworkIndex]).andReturn(0).andForwardToRealObject();
    });
    
    context(@"with placement having priority rules", ^{
        
        __block id priorityRuleMock;
        __block id priorityRulesArrayMock;

        before(^{
            priorityRuleMock = OCMClassMock([PubnativePriorityRulesModel class]);
            id placememtMock = OCMClassMock([PubnativePlacementModel class]);
            
            priorityRulesArrayMock = OCMClassMock([NSArray class]);
            OCMStub([priorityRulesArrayMock count]).andReturn(1);
            OCMStub(priorityRulesArrayMock[0]).andReturn(priorityRuleMock);
            
            OCMStub([placememtMock priority_rules]).andReturn(priorityRulesArrayMock);
            
            OCMStub([requestMock placement]).andReturn(placememtMock);
            OCMStub([requestMock invokeDidFail:[OCMArg any]]).andDo(nil);
        });
        
        context(@"with nil network code", ^{
            
            before(^{
                OCMStub([priorityRuleMock network_code]).andReturn(nil);
            });
            
            it(@"makes subsequent request", ^{
                [requestMock doNextNetworkRequest];
                expect([requestMock currentNetworkIndex]).to.equal([priorityRulesArrayMock count]);
            });
        });
        
        context(@"with empty network code", ^{
            
            before(^{
                OCMStub([priorityRuleMock network_code]).andReturn(@"");
            });
            
            it(@"makes subsequent request", ^{
                [requestMock doNextNetworkRequest];
                expect([requestMock currentNetworkIndex]).to.equal([priorityRulesArrayMock count]);
            });
        });
        
        context(@"with valid network code", ^{
            
            __block id networkCode;
            
            before(^{
                networkCode = @"test_valid_network_code";
                OCMStub([priorityRuleMock network_code]).andReturn(networkCode);
            });
            
            context(@"and with nil config", ^{
                
                before(^{
                    OCMStub([requestMock config]).andReturn(nil);
                });
                
                it(@"makes subsequent request", ^{
                    [requestMock doNextNetworkRequest];
                    expect([requestMock currentNetworkIndex]).to.equal([priorityRulesArrayMock count]);
                });
            });
            
            context(@"with config", ^{
                
                __block id configMock;
                
                before(^{
                    configMock = OCMClassMock([PubnativeConfigModel class]);
                    OCMStub([requestMock config]).andReturn(configMock);
                });
                
                context(@"with networks list", ^{
                    
                    __block id networksMock;
                    
                    before(^{
                        networksMock = OCMClassMock([NSDictionary class]);
                        OCMStub([configMock networks]).andReturn(networksMock);
                    });
                    
                    context(@"which have network corresponding to network code", ^{
                        
                        __block id networkMock;
                        
                        before(^{
                            networkMock = OCMClassMock([PubnativeNetworkModel class]);;
                            OCMStub([networksMock objectForKey:networkCode]).andReturn(networkMock);
                        });
                        
                        context(@"and have adapter corresponding to network", ^{
                            
                            __block id adapterFactoryMock;
                            __block id adapterMock;
                            
                            before(^{
                                adapterFactoryMock = OCMClassMock([PubnativeNetworkAdapterFactory class]);
                                adapterMock = OCMClassMock([PubnativeNetworkAdapter class]);
                                OCMStub([adapterFactoryMock createApdaterWithNetwork:networkMock]).andReturn(adapterMock);
                            });
                            
                            it(@"make request through adapter", ^{
                                [requestMock doNextNetworkRequest];
                                OCMVerify([adapterMock startWithDelegate:[OCMArg isNotNil]]);
                            });
                        });
                        
                        context(@"and does not have adapter corresponding to network", ^{
                            
                            __block id adapterFactoryMock;
                            
                            before(^{
                                adapterFactoryMock = OCMClassMock([PubnativeNetworkAdapterFactory class]);
                                OCMStub([adapterFactoryMock createApdaterWithNetwork:networkMock]).andReturn(nil);
                            });
                            
                            it(@"makes subsequent request", ^{
                                [requestMock doNextNetworkRequest];
                                expect([requestMock currentNetworkIndex]).to.equal([priorityRulesArrayMock count]);
                            });
                        });
                    });
                    
                    context(@"which does not have network corresponding to network code", ^{
                        
                        before(^{
                            OCMStub([networksMock objectForKey:networkCode]).andReturn(nil);
                        });
                        
                        it(@"makes subsequent request", ^{
                            [requestMock doNextNetworkRequest];
                            expect([requestMock currentNetworkIndex]).to.equal([priorityRulesArrayMock count]);
                        });
                    });
                });
                
                context(@"without networks list", ^{
                    
                    before(^{
                        OCMStub([configMock networks]).andReturn(nil);
                    });
                    
                    it(@"makes subsequent request", ^{
                        [requestMock doNextNetworkRequest];
                        expect([requestMock currentNetworkIndex]).to.equal([priorityRulesArrayMock count]);
                    });
                });
            });
        });
    });
    
    context(@"with placement without priority rules", ^{
        
        before(^{
            id placememtMock = OCMClassMock([PubnativePlacementModel class]);
            OCMStub([placememtMock priority_rules]).andReturn(nil);
            OCMStub([requestMock placement]).andReturn(placememtMock);
        });
        
        it(@"invoke fail", ^{
            OCMExpect([requestMock invokeDidFail:[OCMArg any]]);
            [requestMock doNextNetworkRequest];
            OCMVerifyAll(requestMock);
        });
    });
});

describe(@"when starting a request through public inteface", ^{
    
    __block id requestMock;
    
    before(^{
        requestMock = OCMPartialMock([[PubnativeNetworkRequest alloc] init]);
    });
    
    context(@"with delegate", ^{
        
        __block id delegateMock;
        
        before(^{
            delegateMock = OCMProtocolMock(@protocol(PubnativeNetworkRequestDelegate));
        });
        
        context(@"with nil app token", ^{
           
            __block id appToken;
            
            before(^{
                appToken = nil;
            });
            
            context(@"and nil placement id", ^{
                
                __block id placementId;
                
                before(^{
                    placementId = nil;
                });
                
                it(@"invoke fail", ^{
                    [requestMock startRequestWithAppToken:appToken
                                              placementID:placementId
                                                 delegate:delegateMock];
                    OCMVerify([delegateMock pubnativeRequestDidStart:[OCMArg isNotNil]]);
                    OCMVerify([delegateMock pubnativeRequest:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
                });
            });
            
            context(@"and empty placement id", ^{
                
                __block id placementId;
                
                before(^{
                    placementId = @"";
                });
                
                it(@"invoke fail", ^{
                    [requestMock startRequestWithAppToken:appToken
                                              placementID:placementId
                                                 delegate:delegateMock];
                    OCMVerify([delegateMock pubnativeRequestDidStart:[OCMArg isNotNil]]);
                    OCMVerify([delegateMock pubnativeRequest:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
                });
            });
            
            context(@"and valid placement id", ^{
                
                __block id placementId;
                
                before(^{
                    placementId = @"test_valid_placement_id";
                });
                
                it(@"invoke fail", ^{
                    [requestMock startRequestWithAppToken:appToken
                                              placementID:placementId
                                                 delegate:delegateMock];
                    OCMVerify([delegateMock pubnativeRequestDidStart:[OCMArg isNotNil]]);
                    OCMVerify([delegateMock pubnativeRequest:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
                });
            });
        });
        
        context(@"with empty app token", ^{
            
            __block id appToken;
            
            before(^{
                appToken = @"";
            });
            
            context(@"and nil placement id", ^{
                
                __block id placementId;
                
                before(^{
                    placementId = nil;
                });
                
                it(@"invoke fail", ^{
                    [requestMock startRequestWithAppToken:appToken
                                              placementID:placementId
                                                 delegate:delegateMock];
                    OCMVerify([delegateMock pubnativeRequestDidStart:[OCMArg isNotNil]]);
                    OCMVerify([delegateMock pubnativeRequest:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
                });
            });
            
            context(@"and empty placement id", ^{
                
                __block id placementId;
                
                before(^{
                    placementId = @"";
                });
                
                it(@"invoke fail", ^{
                    [requestMock startRequestWithAppToken:appToken
                                              placementID:placementId
                                                 delegate:delegateMock];
                    OCMVerify([delegateMock pubnativeRequestDidStart:[OCMArg isNotNil]]);
                    OCMVerify([delegateMock pubnativeRequest:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
                });
            });
            
            context(@"and valid placement id", ^{
                
                __block id placementId;
                
                before(^{
                    placementId = @"test_valid_placement_id";
                });
                
                it(@"invoke fail", ^{
                    [requestMock startRequestWithAppToken:appToken
                                              placementID:placementId
                                                 delegate:delegateMock];
                    OCMVerify([delegateMock pubnativeRequestDidStart:[OCMArg isNotNil]]);
                    OCMVerify([delegateMock pubnativeRequest:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
                });
            });
        });
        
        context(@"with valid app token", ^{
            
            __block id appToken;
            
            before(^{
                appToken = @"test_valid_app_token";
            });
            
            context(@"and nil placement id", ^{
                
                __block id placementId;
                
                before(^{
                    placementId = nil;
                });
                
                it(@"invoke fail", ^{
                    [requestMock startRequestWithAppToken:appToken
                                              placementID:placementId
                                                 delegate:delegateMock];
                    OCMVerify([delegateMock pubnativeRequestDidStart:[OCMArg isNotNil]]);
                    OCMVerify([delegateMock pubnativeRequest:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
                });
            });
            
            context(@"and empty placement id", ^{
                
                __block id placementId;
                
                before(^{
                    placementId = @"";
                });
                
                it(@"invoke fail", ^{
                    [requestMock startRequestWithAppToken:appToken
                                              placementID:placementId
                                                 delegate:delegateMock];
                    OCMVerify([delegateMock pubnativeRequestDidStart:[OCMArg isNotNil]]);
                    OCMVerify([delegateMock pubnativeRequest:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
                });
            });
            
            context(@"and valid placement id", ^{
                
                __block id placementId;
                __block id configManagerMock;
                
                before(^{
                    placementId = @"test_valid_placement_id";
                    configManagerMock = OCMClassMock([PubnativeConfigManager class]);
                });
                
                it(@"make config fetch request", ^{
                    OCMExpect([configManagerMock configWithAppToken:appToken delegate:[OCMArg isNotNil]]);
                    [requestMock startRequestWithAppToken:appToken
                                              placementID:placementId
                                                 delegate:delegateMock];
                    OCMVerify([delegateMock pubnativeRequestDidStart:[OCMArg isNotNil]]);
                    OCMVerifyAll(configManagerMock);
                });
                
                it(@"save appToken, placementId, currentNetworkIndex", ^{
                    OCMExpect([configManagerMock configWithAppToken:appToken delegate:[OCMArg isNotNil]]);
                    OCMExpect([requestMock setAppToken:appToken]);
                    OCMExpect([requestMock setPlacementID:placementId]);
                    OCMExpect([requestMock setCurrentNetworkIndex:0]);
                    [requestMock startRequestWithAppToken:appToken
                                              placementID:placementId
                                                 delegate:delegateMock];
                    OCMVerifyAll(requestMock);
                });
                
                after(^{
                    [configManagerMock stopMocking];
                });
            });
        });
    });
});

SpecEnd
