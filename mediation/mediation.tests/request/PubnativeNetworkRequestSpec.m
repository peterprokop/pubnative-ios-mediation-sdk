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
    
    __block id requestMock;
    __block id delegateMock;
    
    context(@"startRequestWithAppToken:placementID:delegate:", ^{
        
        NSString *appToken = @"apptoken_invalid";
        
        before(^{
            requestMock = OCMPartialMock([[PubnativeNetworkRequest alloc] init]);
            delegateMock = OCMProtocolMock(@protocol(PubnativeNetworkRequestDelegate));
        });
        
        context(@"with valid parameters, when config fetch", ^{
            
            __block id configManagerMock;
            
            NSString *placementId = @"facebook_only";
            
            before(^{
                configManagerMock = OCMClassMock([PubnativeConfigManager class]);
            });
            
            context(@"succeed", ^{
                
                it(@"set app token, placementID, currentNetworkIndex and invoke load", ^{
                    
                    id adMock = OCMClassMock([PubnativeAdModel class]);
                    id adapterMock = OCMPartialMock([[PubnativeNetworkAdapter alloc] init]);
                    
                    // Given
                    // Stub Adapter doRequest to callback directly
                    OCMStub([adapterMock doRequest]).andDo(^(NSInvocation *invocation){
                        [[adapterMock delegate] adapterRequestDidStart:adapterMock];
                        [[adapterMock delegate] adapter:adapterMock requestDidLoad:adMock];
                    });
                    
                    // Given
                    // Stub Factory create to return a mock adapter
                    id adapterFactoryMock = OCMClassMock([PubnativeNetworkAdapterFactory class]);
                    OCMStub([adapterFactoryMock createApdaterWithNetwork:[OCMArg any]]).andReturn(adapterMock);
                    
                    // Given
                    // Stub Manager to return a mock ad directly
                    OCMStub([configManagerMock configWithAppToken:appToken delegate:[OCMArg isNotNil]]).andDo(^(NSInvocation *invocation) {
                        [requestMock configDidFinishWithModel:[PubnativeConfigUtils getModelFromJSONFile:@"config_valid"]];
                    });
                    // When
                    [requestMock startRequestWithAppToken:appToken
                                              placementID:placementId
                                                 delegate:delegateMock];
                    
                    // Verify
                    OCMVerify([delegateMock requestDidStart:[OCMArg isNotNil]]);
                    OCMVerify([delegateMock request:[OCMArg isNotNil] didLoad:adMock]);
                    OCMVerify([configManagerMock configWithAppToken:appToken delegate:[OCMArg isNotNil]]);
                    OCMVerify([requestMock setAppToken:appToken]);
                    OCMVerify([requestMock setPlacementID:placementId]);
                    OCMVerify([requestMock setCurrentNetworkIndex:0]);
                });
            });
            
            context(@"failed ", ^{
                
                it(@"set app token, placementID, currentNetworkIndex and invoke fail", ^{
                    
                    id errorMock = OCMClassMock([NSError class]);
                    // Given
                    // Stub Manager to return a mock ad directly
                    OCMStub([configManagerMock configWithAppToken:appToken delegate:[OCMArg isNotNil]]).andDo(^(NSInvocation *invocation) {
                        [requestMock configDidFailWithError:errorMock];
                    });
                    // When
                    [requestMock startRequestWithAppToken:appToken
                                              placementID:placementId
                                                 delegate:delegateMock];
                    
                    // Verify
                    OCMVerify([delegateMock requestDidStart:[OCMArg isNotNil]]);
                    OCMVerify([delegateMock request:[OCMArg isNotNil] didFail:errorMock]);
                    OCMVerify([configManagerMock configWithAppToken:appToken delegate:[OCMArg isNotNil]]);
                    OCMVerify([requestMock setAppToken:appToken]);
                    OCMVerify([requestMock setPlacementID:placementId]);
                    OCMVerify([requestMock setCurrentNetworkIndex:0]);
                });
            });
        });
        
        context(@"with invalid parameters", ^{
            
            NSString *emptyString = @"";
            NSString *placementId = @"placement_invalid";
            
            it(@"nil app token and nil placement id, invoke fail", ^{
                [requestMock startRequestWithAppToken:nil
                                          placementID:nil
                                             delegate:delegateMock];
                OCMVerify([delegateMock requestDidStart:[OCMArg isNotNil]]);
                OCMVerify([delegateMock request:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
            });
            
            it(@"nil app token and empty placement id, invoke fail", ^{
                [requestMock startRequestWithAppToken:nil
                                          placementID:emptyString
                                             delegate:delegateMock];
                OCMVerify([delegateMock requestDidStart:[OCMArg isNotNil]]);
                OCMVerify([delegateMock request:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
            });
            
            it(@"nil app token and valid placement id, invoke fail", ^{
                [requestMock startRequestWithAppToken:nil
                                          placementID:placementId
                                             delegate:delegateMock];
                OCMVerify([delegateMock requestDidStart:[OCMArg isNotNil]]);
                OCMVerify([delegateMock request:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
            });
            
            it(@"empty app token and nil placement id, invoke fail", ^{
                [requestMock startRequestWithAppToken:emptyString
                                          placementID:nil
                                             delegate:delegateMock];
                OCMVerify([delegateMock requestDidStart:[OCMArg isNotNil]]);
                OCMVerify([delegateMock request:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
            });
            
            it(@"empty app token and empty placement id, invoke fail", ^{
                [requestMock startRequestWithAppToken:emptyString
                                          placementID:emptyString
                                             delegate:delegateMock];
                OCMVerify([delegateMock requestDidStart:[OCMArg isNotNil]]);
                OCMVerify([delegateMock request:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
            });
            
            it(@"empty app token and valid placement id, invoke fail", ^{
                [requestMock startRequestWithAppToken:emptyString
                                          placementID:placementId
                                             delegate:delegateMock];
                OCMVerify([delegateMock requestDidStart:[OCMArg isNotNil]]);
                OCMVerify([delegateMock request:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
            });
            
            it(@"valid app token and nil placement id, invoke fail", ^{
                [requestMock startRequestWithAppToken:appToken
                                          placementID:nil
                                             delegate:delegateMock];
                OCMVerify([delegateMock requestDidStart:[OCMArg isNotNil]]);
                OCMVerify([delegateMock request:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
            });
            
            it(@"valid app token and empty placement id, invoke fail", ^{
                [requestMock startRequestWithAppToken:appToken
                                          placementID:emptyString
                                             delegate:delegateMock];
                OCMVerify([delegateMock requestDidStart:[OCMArg isNotNil]]);
                OCMVerify([delegateMock request:[OCMArg isNotNil] didFail:[OCMArg isNotNil]]);
            });
        });
    });
    
    context(@"startRequestWithConfig:", ^{
        
        NSString *validPlacementID  = @"facebook_only";
        NSString *emptyConfigFile   = @"config_empty";
        NSString *validConfigFile   = @"config_valid";
        
        before(^{
            requestMock = OCMPartialMock([[PubnativeNetworkRequest alloc] init]);
        });
        
        context(@"with valid config", ^{
            
            it(@"and nil placement list, invoke fail", ^{
                [requestMock startRequestWithConfig:[PubnativeConfigUtils getModelFromJSONFile:emptyConfigFile]];
                OCMVerify([requestMock invokeDidFail:[OCMArg isNotNil]]);
            });
            
            context(@"valid placement list", ^{
                
                it(@"and invalid placementID, invoke fail", ^{
                    OCMStub([requestMock placementID]).andReturn(@"invalid_placementID");
                    [requestMock startRequestWithConfig:[PubnativeConfigUtils getModelFromJSONFile:validConfigFile]];
                    OCMVerify([requestMock invokeDidFail:[OCMArg isNotNil]]);
                });
                
                context(@"valid placementID", ^{
                    
                    before(^{
                        OCMStub([requestMock placementID]).andReturn(validPlacementID);
                    });
                    
                    it(@"and nil delievery rules, invoke fail", ^{
                        id placementMock = OCMClassMock([PubnativePlacementModel class]);
                        // Given
                        OCMStub([placementMock delivery_rules]).andReturn(nil);
                        OCMStub([requestMock placement]).andReturn(placementMock);
                        [requestMock startRequestWithConfig:[PubnativeConfigUtils getModelFromJSONFile:validConfigFile]];
                        OCMVerify([requestMock invokeDidFail:[OCMArg isNotNil]]);
                    });
                    
                    context(@"valid deleivery rules", ^{
                        
                        it(@"and inactive delivery rules, invoke fail", ^{
                            id placementMock = OCMClassMock([PubnativePlacementModel class]);
                            id delivery_rules = OCMPartialMock([[PubnativeDeliveryRuleModel alloc] init]);
                            // Given
                            OCMStub([delivery_rules isActive]).andReturn(NO);
                            OCMStub([placementMock delivery_rules]).andReturn(delivery_rules);
                            OCMStub([requestMock placement]).andReturn(placementMock);
                            [requestMock startRequestWithConfig:[PubnativeConfigUtils getModelFromJSONFile:validConfigFile]];
                            OCMVerify([requestMock invokeDidFail:[OCMArg isNotNil]]);
                        });
                        
                        it(@"and active delivery rules, invoke doNextNetworkRequest", ^{
                            [requestMock startRequestWithConfig:[PubnativeConfigUtils getModelFromJSONFile:validConfigFile]];
                            OCMVerify([requestMock doNextNetworkRequest]);
                        });
                    });
                });
            });
        });
        
        it(@"with invalid config, invoke fail", ^{
            OCMStub([requestMock placementID]).andReturn(validPlacementID);
            [requestMock startRequestWithConfig:[PubnativeConfigUtils getModelFromJSONFile:emptyConfigFile]];
            OCMVerify([requestMock invokeDidFail:[OCMArg isNotNil]]);
        });
        
        it(@"with nil config, invoke fail", ^{
            OCMStub([requestMock placementID]).andReturn(validPlacementID);
            [requestMock startRequestWithConfig:nil];
            OCMVerify([requestMock invokeDidFail:[OCMArg isNotNil]]);
        });
        
        it(@"with config having invalid placementID, invoke fail", ^{
            OCMStub([requestMock placementID]).andReturn(@"invalid_placement_ID");
            [requestMock startRequestWithConfig:[PubnativeConfigUtils getModelFromJSONFile:validConfigFile]];
            OCMVerify([requestMock invokeDidFail:[OCMArg isNotNil]]);
        });
    });
    
    context(@"doNextNetworkRequest", ^{
        
        before(^{
            requestMock = OCMPartialMock([[PubnativeNetworkRequest alloc] init]);
            OCMStub([requestMock currentNetworkIndex]).andReturn(0).andForwardToRealObject();
        });
        
        NSString *emptyConfigFile   = @"config_empty";
        NSString *validConfigFile   = @"config_valid";
        NSString *emptyString       = @"";
        NSString *validNetworkCode  = @"facebook";
        
        context(@"with nil network code, nil config", ^{
            
            it(@"makes next request", ^{
                id priorityRuleMock = OCMPartialMock([[PubnativePriorityRulesModel alloc] init]);
                OCMStub([priorityRuleMock network_code]).andReturn(nil);
                id placementMock = OCMPartialMock([[PubnativePlacementModel alloc] init]);
                NSArray *placement = [[NSArray alloc] initWithObjects:priorityRuleMock, nil];
                OCMStub([placementMock priority_rules]).andReturn(placement);
                OCMStub([requestMock placement]).andReturn(placementMock);
                OCMStub([requestMock config]).andReturn(nil);
                [requestMock doNextNetworkRequest];
                OCMVerify([requestMock doNextNetworkRequest]);
                expect([requestMock currentNetworkIndex]).to.equal([placement count]);
            });
        });
        
        context(@"with nil network code, empty config", ^{
            
            it(@"makes next request", ^{
                id priorityRuleMock = OCMPartialMock([[PubnativePriorityRulesModel alloc] init]);
                OCMStub([priorityRuleMock network_code]).andReturn(nil);
                id placementMock = OCMPartialMock([[PubnativePlacementModel alloc] init]);
                NSArray *placement = [[NSArray alloc] initWithObjects:priorityRuleMock, nil];
                OCMStub([placementMock priority_rules]).andReturn(placement);
                OCMStub([requestMock placement]).andReturn(placementMock);
                OCMStub([requestMock config]).andReturn([PubnativeConfigUtils getModelFromJSONFile:emptyConfigFile]);
                [requestMock doNextNetworkRequest];
                OCMVerify([requestMock doNextNetworkRequest]);
                expect([requestMock currentNetworkIndex]).to.equal([placement count]);
            });
        });
        
        context(@"with nil network code, valid config", ^{
            
            it(@"makes next request", ^{
                id priorityRuleMock = OCMPartialMock([[PubnativePriorityRulesModel alloc] init]);
                OCMStub([priorityRuleMock network_code]).andReturn(nil);
                id placementMock = OCMPartialMock([[PubnativePlacementModel alloc] init]);
                NSArray *placement = [[NSArray alloc] initWithObjects:priorityRuleMock, nil];
                OCMStub([placementMock priority_rules]).andReturn(placement);
                OCMStub([requestMock placement]).andReturn(placementMock);
                OCMStub([requestMock config]).andReturn([PubnativeConfigUtils getModelFromJSONFile:validConfigFile]);
                [requestMock doNextNetworkRequest];
                OCMVerify([requestMock doNextNetworkRequest]);
                expect([requestMock currentNetworkIndex]).to.equal([placement count]);
            });
        });
        
        context(@"with empty network code, nil config", ^{
            
            it(@"makes next request", ^{
                id priorityRuleMock = OCMPartialMock([[PubnativePriorityRulesModel alloc] init]);
                OCMStub([priorityRuleMock network_code]).andReturn(emptyString);
                id placementMock = OCMPartialMock([[PubnativePlacementModel alloc] init]);
                NSArray *placement = [[NSArray alloc] initWithObjects:priorityRuleMock, nil];
                OCMStub([placementMock priority_rules]).andReturn(placement);
                OCMStub([requestMock placement]).andReturn(placementMock);
                OCMStub([requestMock config]).andReturn(nil);
                [requestMock doNextNetworkRequest];
                OCMVerify([requestMock doNextNetworkRequest]);
                expect([requestMock currentNetworkIndex]).to.equal([placement count]);
            });
        });
        
        context(@"with empty network code, empty config", ^{
            
            it(@"makes next request", ^{
                id priorityRuleMock = OCMPartialMock([[PubnativePriorityRulesModel alloc] init]);
                OCMStub([priorityRuleMock network_code]).andReturn(emptyString);
                id placementMock = OCMPartialMock([[PubnativePlacementModel alloc] init]);
                NSArray *placement = [[NSArray alloc] initWithObjects:priorityRuleMock, nil];
                OCMStub([placementMock priority_rules]).andReturn(placement);
                OCMStub([requestMock placement]).andReturn(placementMock);
                OCMStub([requestMock config]).andReturn([PubnativeConfigUtils getModelFromJSONFile:emptyConfigFile]);
                [requestMock doNextNetworkRequest];
                OCMVerify([requestMock doNextNetworkRequest]);
                expect([requestMock currentNetworkIndex]).to.equal([placement count]);
            });
        });
        
        context(@"with empty network code, valid config", ^{
            
            it(@"makes next request", ^{
                id priorityRuleMock = OCMPartialMock([[PubnativePriorityRulesModel alloc] init]);
                OCMStub([priorityRuleMock network_code]).andReturn(emptyString);
                id placementMock = OCMPartialMock([[PubnativePlacementModel alloc] init]);
                NSArray *placement = [[NSArray alloc] initWithObjects:priorityRuleMock, nil];
                OCMStub([placementMock priority_rules]).andReturn(placement);
                OCMStub([requestMock placement]).andReturn(placementMock);
                OCMStub([requestMock config]).andReturn([PubnativeConfigUtils getModelFromJSONFile:validConfigFile]);
                [requestMock doNextNetworkRequest];
                OCMVerify([requestMock doNextNetworkRequest]);
                expect([requestMock currentNetworkIndex]).to.equal([placement count]);
            });
        });
        
        context(@"with valid network code, nil config", ^{
            
            it(@"makes next request", ^{
                id priorityRuleMock = OCMPartialMock([[PubnativePriorityRulesModel alloc] init]);
                OCMStub([priorityRuleMock network_code]).andReturn(validNetworkCode);
                id placementMock = OCMPartialMock([[PubnativePlacementModel alloc] init]);
                NSArray *placement = [[NSArray alloc] initWithObjects:priorityRuleMock, nil];
                OCMStub([placementMock priority_rules]).andReturn(placement);
                OCMStub([requestMock placement]).andReturn(placementMock);
                OCMStub([requestMock config]).andReturn(nil);
                [requestMock doNextNetworkRequest];
                OCMVerify([requestMock doNextNetworkRequest]);
                expect([requestMock currentNetworkIndex]).to.equal([placement count]);
            });
        });
        
        context(@"with valid network code, empty config", ^{
            
            it(@"makes next request", ^{
                id priorityRuleMock = OCMPartialMock([[PubnativePriorityRulesModel alloc] init]);
                OCMStub([priorityRuleMock network_code]).andReturn(validNetworkCode);
                id placementMock = OCMPartialMock([[PubnativePlacementModel alloc] init]);
                NSArray *placement = [[NSArray alloc] initWithObjects:priorityRuleMock, nil];
                OCMStub([placementMock priority_rules]).andReturn(placement);
                OCMStub([requestMock placement]).andReturn(placementMock);
                OCMStub([requestMock config]).andReturn([PubnativeConfigUtils getModelFromJSONFile:emptyConfigFile]);
                [requestMock doNextNetworkRequest];
                OCMVerify([requestMock doNextNetworkRequest]);
                expect([requestMock currentNetworkIndex]).to.equal([placement count]);
            });
        });
        
        context(@"with valid network code, valid config", ^{
            
            context(@"adapter created", ^{
                
                it(@"make request", ^{
                    id priorityRuleMock = OCMPartialMock([[PubnativePriorityRulesModel alloc] init]);
                    OCMStub([priorityRuleMock network_code]).andReturn(validNetworkCode);
                    id placementMock = OCMPartialMock([[PubnativePlacementModel alloc] init]);
                    NSArray *placement = [[NSArray alloc] initWithObjects:priorityRuleMock, nil];
                    OCMStub([placementMock priority_rules]).andReturn(placement);
                    OCMStub([requestMock placement]).andReturn(placementMock);
                    OCMStub([requestMock config]).andReturn([PubnativeConfigUtils getModelFromJSONFile:validConfigFile]);
                    
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
                    OCMStub([priorityRuleMock network_code]).andReturn(validNetworkCode);
                    id placementMock = OCMPartialMock([[PubnativePlacementModel alloc] init]);
                    NSArray *placement = [[NSArray alloc] initWithObjects:priorityRuleMock, nil];
                    OCMStub([placementMock priority_rules]).andReturn(placement);
                    OCMStub([requestMock placement]).andReturn(placementMock);
                    OCMStub([requestMock config]).andReturn([PubnativeConfigUtils getModelFromJSONFile:validConfigFile]);
                    
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
