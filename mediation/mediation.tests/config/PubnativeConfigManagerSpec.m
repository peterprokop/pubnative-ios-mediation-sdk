//
//  PubnativeConfigManagerSpec.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "Specta.h"
#import "Expecta.h"
#import "PubnativeConfigManager.h"
#import "PubnativeConfigUtils.h"
#import "PubnativeConfigRequestModel.h"
#import "PubnativeConfigAPIResponseModel.h"

#import <OCMock/OCMock.h>

extern NSString * const kUserDefaultsStoredConfigKey;
extern NSString * const kUserDefaultsStoredAppTokenKey;
extern NSString * const kUserDefaultsStoredTimestampKey;

@interface PubnativeConfigManager (Private)

@property (nonatomic, strong)NSMutableArray *requestQueue;
@property (nonatomic, assign)BOOL           idle;

+ (instancetype)sharedInstance;
+ (void)setSharedInstance:(PubnativeConfigManager*)instance;
+ (void)doNextRequest;
+ (void)getNextConfigWithModel:(PubnativeConfigRequestModel*)requestModel;
+ (void)serveStoredConfigWithRequest:(PubnativeConfigRequestModel*)requestModel;
+ (void)enqueueRequestModel:(PubnativeConfigRequestModel*)request;
+ (PubnativeConfigRequestModel*)dequeueRequestDelegate;
+ (void)updateStoredConfig:(PubnativeConfigModel*)model
              withAppToken:(NSString*)appToken;
+ (void)invokeDidFinishWithModel:(PubnativeConfigModel*)model
                        delegate:(NSObject<PubnativeConfigManagerDelegate>*)delegate;
+ (void)invokeDidFailWithError:(NSError*)error
                      delegate:(NSObject<PubnativeConfigManagerDelegate>*)delegate;
+ (void)setStoredTimestamp:(NSTimeInterval)timestamp;
+ (NSTimeInterval)getStoredTimestamp;
+ (void)setStoredAppToken:(NSString*)appToken;
+ (NSString*)getStoredAppToken;
+ (void)setStoredConfig:(PubnativeConfigModel*)model;
+ (PubnativeConfigModel*)getStoredConfig;
+ (void)configWithAppToken:(NSString*)appToken
                  delegate:(NSObject<PubnativeConfigManagerDelegate>*)delegate;

@end

SpecBegin(PubnativeConfigManager)


describe(@"singleton", ^{
    
    it(@"should have a shared instance", ^{
        expect([PubnativeConfigManager sharedInstance]).notTo.beNil();
    });
    
    it(@"should return same instance", ^{
        PubnativeConfigManager *firstInstance = [PubnativeConfigManager sharedInstance];
        PubnativeConfigManager *secondInstance = [PubnativeConfigManager sharedInstance];
        expect(firstInstance).to.equal(secondInstance);
    });
    
    it(@"should return different instance than manual alloc", ^{
        PubnativeConfigManager *sharedInstance = [PubnativeConfigManager sharedInstance];
        PubnativeConfigManager *uniqueInstance = [[PubnativeConfigManager alloc] init];
        expect(sharedInstance).notTo.equal(uniqueInstance);
    });
});

describe(@"storage methods", ^{
    
    NSString * const appTokenDefault   = @"app_token_default";
    NSString * const appTokenValid     = @"app_token_valid";
    
    context(@"app token", ^{
        
        NSString *appTokenKey = @"appToken";
        
        NSString *sharedExampleWhenSetting = @"when setting";
        sharedExamplesFor(sharedExampleWhenSetting, ^(NSDictionary *data) {
            
            __block NSString *oldValue;
            
            beforeAll(^{
                oldValue = data[appTokenKey];
            });
            
            before(^{
                [PubnativeConfigManager setStoredAppToken:oldValue];
            });
            
            it(@"nil, it clears value", ^{
                [PubnativeConfigManager setStoredAppToken:nil];
                NSString *newValue = [PubnativeConfigManager getStoredAppToken];
                expect(newValue).to.beNil;
            });
            
            it(@"empty, it clears value", ^{
                [PubnativeConfigManager setStoredAppToken:@""];
                NSString *newValue = [PubnativeConfigManager getStoredAppToken];
                expect(newValue).to.beNil;
            });
            
            it(@"valid, it sets value", ^{
                [PubnativeConfigManager setStoredAppToken:appTokenValid];
                NSString *newValue = [PubnativeConfigManager getStoredAppToken];
                expect(newValue).to.equal(appTokenValid);
            });
        });
        
        context(@"with previous nil value", ^{
            itBehavesLike(sharedExampleWhenSetting, nil);
        });
        
        context(@"with previous different value", ^{
            itBehavesLike(sharedExampleWhenSetting, @{appTokenKey : appTokenDefault});
        });
        
        context(@"with previous valid value", ^{
            itBehavesLike(sharedExampleWhenSetting, @{appTokenKey : appTokenValid});
        });
    });
    
    context(@"timestamp", ^{
        
        NSString *timestampKey = @"timestamp";
        
        NSString *sharedExampleWhenSetting = @"when setting";
        sharedExamplesFor(sharedExampleWhenSetting, ^(NSDictionary *data) {
            
            __block NSNumber *oldValue;
            
            beforeAll(^{
                oldValue = data[timestampKey];
            });
            
            before(^{
                [PubnativeConfigManager setStoredTimestamp:[oldValue doubleValue]];
            });
            
            it(@"negative, it clears value", ^{
                [PubnativeConfigManager setStoredTimestamp:-1];
                double newValue = [PubnativeConfigManager getStoredTimestamp];
                expect(newValue).to.equal(0);
            });
            
            it(@"zero, it clears value", ^{
                [PubnativeConfigManager setStoredTimestamp:0];
                double newValue = [PubnativeConfigManager getStoredTimestamp];
                expect(newValue).to.equal(0);
            });
            
            it(@"positive, it sets value", ^{
                [PubnativeConfigManager setStoredTimestamp:1];
                double newValue = [PubnativeConfigManager getStoredTimestamp];
                expect(newValue).to.equal(1);
            });
        });
        
        context(@"with previous negative value", ^{
            itBehavesLike(sharedExampleWhenSetting, @{timestampKey : @-1});
        });
        
        context(@"with previous zero value", ^{
            itBehavesLike(sharedExampleWhenSetting, @{timestampKey : @0});
        });
        
        context(@"with previous positive value", ^{
            itBehavesLike(sharedExampleWhenSetting, @{timestampKey : @1});
        });
    });
    
    context(@"config", ^{
        
        NSString *configFileValid   = @"config_valid";
        NSString *configFileInvalid = @"invalid";
        NSString *configFileEmpty   = @"config_empty";
        
        NSString *configKey         = @"config";
        
        NSString *sharedExampleWhenSetting = @"when setting";
        sharedExamplesFor(sharedExampleWhenSetting, ^(NSDictionary *data) {
            
            __block PubnativeConfigModel *oldValue;
            
            beforeAll(^{
                NSString *oldValueFile = data[configKey];
                if(oldValueFile){
                    oldValue = [PubnativeConfigUtils getModelFromJSONFile:oldValueFile];
                }
            });
            
            beforeEach(^{
                [PubnativeConfigManager setStoredConfig:oldValue];
            });
            
            it(@"nil, it clears value", ^{
                [PubnativeConfigManager setStoredConfig:nil];
                PubnativeConfigModel *newValue = [PubnativeConfigManager getStoredConfig];
                expect(newValue).to.beNil;
            });
            
            it(@"empty, it clears value", ^{
                PubnativeConfigModel *config = [PubnativeConfigUtils getModelFromJSONFile:configFileEmpty];
                [PubnativeConfigManager setStoredConfig:config];
                PubnativeConfigModel *newValue = [PubnativeConfigManager getStoredConfig];
                expect(newValue).to.beNil;
            });
            
            it(@"valid, it sets value", ^{
                PubnativeConfigModel *config = [PubnativeConfigUtils getModelFromJSONFile:configFileValid];
                [PubnativeConfigManager setStoredConfig:config];
                PubnativeConfigModel *newValue = [PubnativeConfigManager getStoredConfig];
                expect(newValue).toNot.beNil;
            });
            
            it(@"invalid, it clears value", ^{
                PubnativeConfigModel *config = [PubnativeConfigUtils getModelFromJSONFile:configFileInvalid];
                [PubnativeConfigManager setStoredConfig:config];
                PubnativeConfigModel *newValue = [PubnativeConfigManager getStoredConfig];
                expect(newValue).toNot.beNil;
            });
            
        });
        
        context(@"with previous nil value", ^{
            itBehavesLike(sharedExampleWhenSetting, nil);
        });
        
        context(@"with previous empty value", ^{
            itBehavesLike(sharedExampleWhenSetting, @{configKey : configFileEmpty});
        });
        
        context(@"with previous valid value", ^{
            itBehavesLike(sharedExampleWhenSetting, @{configKey : configFileValid});
        });
        
    });
});

describe(@"callback methods", ^{
    
    context(@"on error", ^{
        
        NSString *errorKey = @"error";
        NSString *delegateKey = @"delegate";
        
        NSString *sharedExmapleContinues = @"continues";
        sharedExamples(sharedExmapleContinues, ^(NSDictionary *data) {
            
            __block id managerMock;
            __block id error;
            __block id delegate;
            
            before(^{
                managerMock = OCMClassMock([PubnativeConfigManager class]);
                error = data[errorKey];
                delegate = data[delegateKey];
            });
            
            it(@"sets manager idle", ^{
                // Given
                OCMStub([managerMock doNextRequest]).andDo(nil);
                // When
                [PubnativeConfigManager invokeDidFailWithError:error
                                                      delegate:delegate];
                // Verify
                expect([PubnativeConfigManager sharedInstance].idle).to.equal(YES);
            });
            
            it(@"calls doNextRequest", ^{
                // Given
                OCMExpect([managerMock doNextRequest]);
                // When
                [PubnativeConfigManager invokeDidFailWithError:error
                                                      delegate:delegate];
                // Verify
                OCMVerifyAll(managerMock);
            });
            
            after(^{
                [managerMock stopMocking];
            });
        });
        
        NSString *sharedExmapleCallbacks = @"callbacks";
        sharedExamples(sharedExmapleCallbacks, ^(NSDictionary *data) {
            
            it(@"delegate", ^{
                
                id managerMock = OCMClassMock([PubnativeConfigManager class]);
                id error = data[errorKey];
                id delegate = data[delegateKey];
                
                OCMStub([managerMock doNextRequest]).andDo(nil);
                OCMExpect([delegate configDidFailWithError:error]);
                
                [PubnativeConfigManager invokeDidFailWithError:error
                                                      delegate:delegate];
                OCMVerifyAll(managerMock);
                
                [managerMock stopMocking];
            });
        });
        
        context(@"with nil delegate", ^{
        
            itBehavesLike(sharedExmapleContinues, nil);
            itBehavesLike(sharedExmapleContinues, @{ errorKey : OCMClassMock([NSError class]) });
        });
        
        context(@"with valid delegate", ^{
            
            itBehavesLike(sharedExmapleContinues, @{ delegateKey : OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate)) });
            itBehavesLike(sharedExmapleContinues, @{ errorKey       : OCMClassMock([NSError class]),
                                                     delegateKey    : OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate)) });
            
            itBehavesLike(sharedExmapleCallbacks, @{ delegateKey : OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate)) });
            itBehavesLike(sharedExmapleCallbacks, @{ errorKey       : OCMClassMock([NSError class]),
                                                     delegateKey    : OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate)) });
        });
    });
    
    context(@"on success", ^{
        
        NSString *modelKey = @"model";
        NSString *delegateKey = @"delegate";
        
        NSString *sharedExampleContinues = @"contines";
        sharedExamples(sharedExampleContinues, ^(NSDictionary *data) {
            
            __block id managerMock;
            __block id model;
            __block id delegate;
            
            before(^{
                managerMock = OCMClassMock([PubnativeConfigManager class]);
                model = data[modelKey];
                delegate = data[delegateKey];
            });
            
            it(@"sets manager idle", ^{
                // Given
                OCMStub([managerMock doNextRequest]).andDo(nil);
                // When
                [PubnativeConfigManager invokeDidFinishWithModel:model
                                                        delegate:delegate];
                // Verify
                expect([PubnativeConfigManager sharedInstance].idle).to.equal(YES);
            });
            
            it(@"calls doNextRequest", ^{
                // Given
                OCMExpect([managerMock doNextRequest]);
                // When
                [PubnativeConfigManager invokeDidFinishWithModel:model
                                                        delegate:delegate];
                // Verify
                OCMVerifyAll(managerMock);
            });
            
            after(^{
                [managerMock stopMocking];
            });
        });
        
        NSString *sharedExampleCallback = @"callback";
        sharedExamples(sharedExampleCallback, ^(NSDictionary *data) {
            
            it(@"delegate", ^{
                // Given
                id model = data[modelKey];
                id delegate = data[delegateKey];
                OCMExpect([delegate configDidFinishWithModel:model]);
                
                id managerMock = OCMClassMock([PubnativeConfigManager class]);
                OCMStub([managerMock doNextRequest]).andDo(nil);
                
                // When
                [PubnativeConfigManager invokeDidFinishWithModel:model
                                                      delegate:delegate];
                
                // Verify
                OCMVerifyAll(managerMock);
                [managerMock stopMocking];
            });
        });
        
        context(@"with nil delegate", ^{
            
            itBehavesLike(sharedExampleContinues, nil);
            itBehavesLike(sharedExampleContinues, @{ modelKey : OCMClassMock([PubnativeConfigModel class]) });
        });
        
        context(@"with valid delegate", ^{
            
            itBehavesLike(sharedExampleContinues, @{ delegateKey : OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate)) });
            itBehavesLike(sharedExampleContinues, @{ modelKey : OCMClassMock([PubnativeConfigModel class]),
                                                     delegateKey : OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate)) });
            
            itBehavesLike(sharedExampleCallback, @{ delegateKey : OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate)) });
            itBehavesLike(sharedExampleCallback, @{ modelKey : OCMClassMock([PubnativeConfigModel class]),
                                                    delegateKey : OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate)) });
        });
    });
});

describe(@"updating a config", ^{
    
    NSString *configFileValid   = @"config_valid";
    NSString *configFileEmpty   = @"config_empty";
    
    NSString *appTokenValid   = @"appToken";
    
    NSString *configFileKey = @"configfile";
    NSString *appTokenKey = @"appToken";
    
    NSString *sharedTestUpdate = @"updates internal values";
    sharedExamples(sharedTestUpdate, ^(NSDictionary *data) {
        
        __block NSString                *configFile;
        __block NSString                *appToken;
        __block PubnativeConfigModel    *model;
        
        before(^{
            configFile = data[configFileKey];
            appToken = data[appTokenKey];
            
            if(configFile){
                model = [PubnativeConfigUtils getModelFromJSONFile:configFile];
            }
        });
        
        it(@"inner storage values", ^{
            id managerMock = OCMClassMock([PubnativeConfigManager class]);
            OCMExpect([managerMock setStoredAppToken:appToken]);
            OCMExpect([managerMock setStoredConfig:model]);
            OCMExpect([[managerMock ignoringNonObjectArgs] setStoredTimestamp:0]);
            
            [PubnativeConfigManager updateStoredConfig:model withAppToken:appToken];
            
            OCMVerifyAll(managerMock);
            [managerMock stopMocking];
        });
    });
    
    NSString *sharedTestDontUpdate = @"dont update";
    sharedExamples(sharedTestDontUpdate, ^(NSDictionary *data) {
        
        __block NSString                *configFile;
        __block NSString                *appToken;
        __block PubnativeConfigModel    *model;
        
        before(^{
            configFile = data[configFileKey];
            appToken = data[appTokenKey];
            if(configFile){
                model = [PubnativeConfigUtils getModelFromJSONFile:configFile];
            }
        });
        
        it(@"inner storage values", ^{
            id managerMock = OCMClassMock([PubnativeConfigManager class]);
            
            [[managerMock reject] setStoredAppToken:[OCMArg any]];
            [[managerMock reject] setStoredConfig:[OCMArg any]];
            [[managerMock reject] setStoredTimestamp:0];
            
            [PubnativeConfigManager updateStoredConfig:model withAppToken:appToken];
            
            [managerMock stopMocking];
        });
    });
    
    context(@"without previous data", ^{
        
        beforeEach(^{
            // clean context
            [PubnativeConfigManager setStoredAppToken:nil];
            [PubnativeConfigManager setStoredTimestamp:0];
            [PubnativeConfigManager setStoredConfig:nil];
        });
        
        itBehavesLike(sharedTestDontUpdate, @{});
    
        itBehavesLike(sharedTestDontUpdate, @{appTokenKey   : @""});
        
        itBehavesLike(sharedTestDontUpdate, @{appTokenKey   : appTokenValid});
        
        itBehavesLike(sharedTestDontUpdate, @{configFileKey : configFileEmpty});
        
        itBehavesLike(sharedTestDontUpdate, @{configFileKey : configFileEmpty,
                                              appTokenKey   : @""});
        
        itBehavesLike(sharedTestDontUpdate, @{configFileKey : configFileEmpty,
                                              appTokenKey   : appTokenValid});
        
        itBehavesLike(sharedTestDontUpdate, @{configFileKey : configFileValid});
        
        itBehavesLike(sharedTestDontUpdate, @{configFileKey : configFileValid,
                                              appTokenKey   : @""});
        
        itBehavesLike(sharedTestUpdate, @{configFileKey : configFileValid,
                                          appTokenKey   : appTokenValid});
    });
    
    context(@"with previous data", ^{
        
        before(^{
            // clean context
            [PubnativeConfigManager setStoredAppToken:appTokenValid];
            [PubnativeConfigManager setStoredTimestamp:1];
            [PubnativeConfigManager setStoredConfig:[PubnativeConfigUtils getModelFromJSONFile:configFileValid]];
        });
        
        itBehavesLike(sharedTestDontUpdate, @{});
        
        itBehavesLike(sharedTestDontUpdate, @{appTokenKey    : @""});
        
        itBehavesLike(sharedTestDontUpdate, @{appTokenKey    : appTokenValid});
        
        itBehavesLike(sharedTestDontUpdate, @{configFileKey  : configFileEmpty});
        
        itBehavesLike(sharedTestDontUpdate, @{configFileKey  : configFileEmpty,
                                              appTokenKey    : @""});
        
        itBehavesLike(sharedTestDontUpdate, @{configFileKey  : configFileEmpty,
                                              appTokenKey    : appTokenValid});
        
        itBehavesLike(sharedTestDontUpdate, @{configFileKey  : configFileValid});
        
        itBehavesLike(sharedTestDontUpdate, @{configFileKey  : configFileValid,
                                              appTokenKey    : @""});
        
        itBehavesLike(sharedTestUpdate, @{configFileKey  : configFileValid,
                                          appTokenKey    : appTokenValid});
    });
});

describe(@"processing next request in queue", ^{
    
    __block id managerMock;
    
    before(^{
        managerMock = OCMClassMock([PubnativeConfigManager class]);
    });
    
    context(@"with idle manager", ^{
        
        before(^{
            [PubnativeConfigManager sharedInstance].idle = YES;
        });
        
        it(@"without next request keeps manager idle", ^{
            OCMStub([managerMock dequeueRequestDelegate]).andReturn(nil);
            [PubnativeConfigManager doNextRequest];
            expect([PubnativeConfigManager sharedInstance].idle).to.equal(YES);
        });
        
        it(@"with next request manager idle is disabled", ^{
            
            id requestModel = OCMClassMock([PubnativeConfigRequestModel class]);
            OCMExpect([managerMock getNextConfigWithModel:requestModel]);
            OCMStub([managerMock dequeueRequestDelegate]).andReturn(requestModel);
            
            [PubnativeConfigManager doNextRequest];
            
            expect([PubnativeConfigManager sharedInstance].idle).to.equal(NO);
            OCMVerifyAll(managerMock);
        });
    });
    
    after(^{
        [managerMock stopMocking];
    });
});

describe(@"request queue", ^{
    
    NSString *queueKey = @"queue";
    
    NSString *sharedExampleEnqueues = @"enqueues request";
    sharedExamples(sharedExampleEnqueues, ^(NSDictionary *globalData) {
        
        NSString *appTokenKey = @"appToken";
        NSString *delegateKey = @"delegate";
        
        context(@"nil", ^{
            
            it(@"dont modifies queue", ^{
                // Set queue value
                NSMutableArray *oldQueue = globalData[queueKey];
                [PubnativeConfigManager sharedInstance].requestQueue = oldQueue;
                
                // set value and check
                [PubnativeConfigManager enqueueRequestModel:nil];
                expect([PubnativeConfigManager sharedInstance].requestQueue).to.equal(oldQueue);
            });
        });
        
        context(@"invalid", ^{
            
            NSString *sharedExampleAddsRequest = @"adds request";
            sharedExamples(sharedExampleAddsRequest, ^(NSDictionary *data) {
                
                before(^{
                    [PubnativeConfigManager sharedInstance].requestQueue = globalData[queueKey];
                });
                
                it(@"dont changes request", ^{
                    
                    // Given
                    NSMutableArray *oldQueue = [PubnativeConfigManager sharedInstance].requestQueue;
                    
                    PubnativeConfigRequestModel *requestModel = OCMClassMock([PubnativeConfigRequestModel  class]);
                    OCMStub(requestModel.appToken).andReturn(data[appTokenKey]);
                    OCMStub(requestModel.delegate).andReturn(data[delegateKey]);
                    
                    // When
                    [PubnativeConfigManager enqueueRequestModel:requestModel];
                    
                    // Expect
                    expect([PubnativeConfigManager sharedInstance].requestQueue).to.equal(oldQueue);
                });
            });
            
            context(@"nil appToken, nil delegate", ^{
                itBehavesLike(sharedExampleAddsRequest, nil);
            });
            
            context(@"empty appToken, nil delegate", ^{
                itBehavesLike(sharedExampleAddsRequest, @{appTokenKey : @""});
            });
            
            context(@"valid appToken, nil delegate", ^{
                itBehavesLike(sharedExampleAddsRequest, @{appTokenKey : @"appToken"});
            });
            
            context(@"nil appToken, valid delegate", ^{
                itBehavesLike(sharedExampleAddsRequest, @{delegateKey : OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate))});
            });
            context(@"empty appToken, valid delegate", ^{
                itBehavesLike(sharedExampleAddsRequest, @{appTokenKey : @"",
                                                          delegateKey : OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate))});
            });
        });
        
        context(@"valid", ^{
            
            __block PubnativeConfigRequestModel *validRequest;
            
            before(^{
                [PubnativeConfigManager sharedInstance].requestQueue = globalData[queueKey];
                validRequest = OCMClassMock([PubnativeConfigRequestModel  class]);
                OCMStub(validRequest.appToken).andReturn(@"appToken");
                OCMStub(validRequest.delegate).andReturn(OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate)));
            });
            
            it(@"initializes the queue", ^{
                [PubnativeConfigManager enqueueRequestModel:validRequest];
                expect([PubnativeConfigManager sharedInstance].requestQueue).toNot.beNil;
            });
            
            it(@"adds the request to the queue", ^{
                [PubnativeConfigManager enqueueRequestModel:validRequest];
                expect([PubnativeConfigManager sharedInstance].requestQueue).to.contain(validRequest);
            });
            
            it(@"increments queue count by 1", ^{
                
                NSInteger oldCount = 0;
                if([PubnativeConfigManager sharedInstance].requestQueue){
                    oldCount = [[PubnativeConfigManager sharedInstance].requestQueue count];
                }
                [PubnativeConfigManager enqueueRequestModel:validRequest];
                expect([PubnativeConfigManager sharedInstance].requestQueue).to.haveCount(oldCount+1);
            });
        });
    });
    
    context(@"uninintialized", ^{
        
        itBehavesLike(sharedExampleEnqueues, nil);
        
        it(@"dequeues nil", ^{
            [PubnativeConfigManager sharedInstance].requestQueue = nil;
            PubnativeConfigRequestModel *model = [PubnativeConfigManager dequeueRequestDelegate];
            expect(model).to.beNil;
        });
    });
    
    context(@"initialized", ^{
        
        itBehavesLike(sharedExampleEnqueues, ^{
            PubnativeConfigRequestModel *requestModel = OCMClassMock([PubnativeConfigRequestModel class]);
            return @{queueKey : [NSMutableArray arrayWithObject:requestModel]};
        });
        
        context(@"dequeues", ^{
            
            __block PubnativeConfigRequestModel *firstItem;
            
            before(^{
                PubnativeConfigRequestModel *requestModel = OCMClassMock([PubnativeConfigRequestModel class]);
                [PubnativeConfigManager sharedInstance].requestQueue = [NSMutableArray arrayWithObject:requestModel];
                firstItem = [PubnativeConfigManager sharedInstance].requestQueue[0];
            });
            
            it(@"dequeues first item", ^{
                PubnativeConfigRequestModel *model = [PubnativeConfigManager dequeueRequestDelegate];
                expect(model).to.equal(firstItem);
            });
            
            it(@"repeated dequeues returns different items", ^{
                PubnativeConfigRequestModel *model1 = [PubnativeConfigManager dequeueRequestDelegate];
                PubnativeConfigRequestModel *model2 = [PubnativeConfigManager dequeueRequestDelegate];
                
                expect(model1).toNot.equal(model2);
            });
            
            it(@"dequeues nil when finish", ^{
                expect([PubnativeConfigManager dequeueRequestDelegate]).toNot.beNil;
                expect([PubnativeConfigManager dequeueRequestDelegate]).to.beNil;
            });
        });
    });
    
    afterAll(^{
        [PubnativeConfigManager sharedInstance].requestQueue = nil;
    });
});

describe(@"public interface", ^{
    
    context(@"with invalid values", ^{
        
        NSString *appTokenKey = @"appToken";
        
        NSString *sharedExampleFails = @"fails";
        sharedExamples(sharedExampleFails, ^(NSDictionary *data) {
            
            it(@"callbacks with nil result and assigned error", ^{
                
                id delegateMock = OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate));
                NSString *appToken = data[appTokenKey];
                
                // Delegate mock
                OCMExpect([delegateMock configDidFailWithError:[OCMArg any]]);
                
                
                [PubnativeConfigManager configWithAppToken:appToken
                                                  delegate:delegateMock];
                
                OCMVerifyAll(delegateMock);
            });
        });
        itBehavesLike(sharedExampleFails, nil);
        itBehavesLike(sharedExampleFails, @{appTokenKey : @""});
    });
    
    context(@"with valid values", ^{
        
        // ConfigManager mock
        __block id  managerMock;
        __block id  delegateMock;
        NSString *appTokenValidValue = @"appToken";
        
        before(^{
            managerMock = OCMClassMock([PubnativeConfigManager class]);
            delegateMock = OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate));
        });
        
        it(@"calls doNextRequest", ^{
            
            OCMStub([managerMock enqueueRequestModel:[OCMArg any]]).andDo(nil);
            OCMExpect([managerMock doNextRequest]);
            
            [PubnativeConfigManager configWithAppToken:appTokenValidValue
                                              delegate:delegateMock];
            OCMVerifyAll(managerMock);
        });
        
        it(@"call enqueueRequestModel", ^{
            
            OCMStub([managerMock doNextRequest]).andDo(nil);
            OCMExpect([managerMock enqueueRequestModel:[OCMArg any]]);
            
            [PubnativeConfigManager configWithAppToken:appTokenValidValue
                                              delegate:delegateMock];
            OCMVerifyAll(managerMock);
            
        });
        
        it(@"enqueues item with app token and delegate", ^{
            
            // GIVEN
            [PubnativeConfigManager sharedInstance].requestQueue = nil;
            OCMStub([managerMock doNextRequest]).andDo(nil);
            
            // WHEN
            [PubnativeConfigManager configWithAppToken:appTokenValidValue
                                              delegate:delegateMock];
            
            // THEN
            PubnativeConfigRequestModel *model = [PubnativeConfigManager dequeueRequestDelegate];
            expect(model).toNot.beNil();
            expect(model.appToken).to.equal(appTokenValidValue);
            expect(model.delegate).to.equal(delegateMock);
        });
        
        it(@"doNextRequest calls getNextConfigWithModel", ^{
            
            // GIVEN
            OCMStub([managerMock dequeueRequestDelegate]).andReturn(OCMClassMock([PubnativeConfigRequestModel class]));
            OCMExpect([managerMock getNextConfigWithModel:[OCMArg any]]);
            
            // WHEN
            [PubnativeConfigManager doNextRequest];
            
            // THEN
            OCMVerifyAll(managerMock);
        });
        
        after(^{
            [managerMock stopMocking];
            [PubnativeConfigManager sharedInstance].requestQueue = nil;
        });
    });
});

SpecEnd
