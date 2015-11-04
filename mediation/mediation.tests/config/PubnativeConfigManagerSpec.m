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

NSString * const kFileConfigValid   = @"config_valid";
NSString * const kFileConfigEmpty   = @"config_empty";

NSString * const kAppTokenDefault   = @"app_token_default";
NSString * const kAppTokenValid     = @"app_token_valid";

NSString * const kDataFirstKey      = @"data_first_key";
NSString * const kDataSecondKey     = @"data_second_key";

@interface PubnativeConfigManager (Private)

@property (nonatomic, strong)NSMutableArray<PubnativeConfigRequestModel*>   *requestQueue;
@property (nonatomic, assign)BOOL                                           idle;

// Singleton
+ (instancetype)sharedInstance;

// Download config
+ (void)updateStoredConfig:(PubnativeConfigModel*)model withAppToken:(NSString*)appToken;

// Callback methods
+ (void)invokeDidFinishWithModel:(PubnativeConfigModel*)model
                        delegate:(NSObject<PubnativeConfigManagerDelegate>*)delegate;

+ (void)invokeDidFailWithError:(NSError*)error
                      delegate:(NSObject<PubnativeConfigManagerDelegate>*)delegate;

// Storage methods
+ (void)setStoredTimestamp:(NSTimeInterval)timestamp;
+ (NSTimeInterval)getStoredTimestamp;
+ (void)setStoredAppToken:(NSString*)appToken;
+ (NSString*)getStoredAppToken;
+ (void)setStoredConfig:(PubnativeConfigModel*)model;
+ (PubnativeConfigModel*)getStoredConfig;

// Queue
+ (void)enqueueRequestModel:(PubnativeConfigRequestModel*)request;
+ (PubnativeConfigRequestModel*)dequeueRequestDelegate;

//Public interface
+ (void)doNextRequest;

@end

SpecBegin(PubnativeConfigManager)

describe(@"storage methods", ^{
    
    context(@"app token", ^{
        
        sharedExamplesFor(@"when setting", ^(NSDictionary *data) {
            
            __block NSString *oldValue;
            beforeAll(^{
                oldValue = data[kDataFirstKey];
            });
            
            beforeEach(^{
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
                [PubnativeConfigManager setStoredAppToken:kAppTokenValid];
                NSString *newValue = [PubnativeConfigManager getStoredAppToken];
                expect(newValue).to.equal(kAppTokenValid);
            });
        });
        
        context(@"with previous nil value", ^{
            itBehavesLike(@"when setting", nil);
        });
        
        context(@"with previous different value", ^{
            itBehavesLike(@"when setting", @{kDataFirstKey : kAppTokenDefault});
        });
        
        context(@"with previous valid value", ^{
            itBehavesLike(@"when setting", @{kDataFirstKey : kAppTokenValid});
        });
    });
    
    context(@"timestamp", ^{
        
        sharedExamplesFor(@"when setting", ^(NSDictionary *data) {
            
            __block NSNumber *oldValue;
            beforeAll(^{
                oldValue = data[kDataFirstKey];
            });
            
            beforeEach(^{
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
            itBehavesLike(@"when setting", @{kDataFirstKey : @-1});
        });
        
        context(@"with previous zero value", ^{
            itBehavesLike(@"when setting", @{kDataFirstKey : @0});
        });
        
        context(@"with previous positive value", ^{
            itBehavesLike(@"when setting", @{kDataFirstKey : @1});
        });
    });
    
    context(@"config", ^{
        
        sharedExamplesFor(@"when setting", ^(NSDictionary *data) {
            
            __block PubnativeConfigModel *oldValue;
            beforeAll(^{
                NSString *oldValueFile = data[kDataFirstKey];
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
                PubnativeConfigModel *config = [PubnativeConfigUtils getModelFromJSONFile:@"config_empty"];
                [PubnativeConfigManager setStoredConfig:config];
                PubnativeConfigModel *newValue = [PubnativeConfigManager getStoredConfig];
                expect(newValue).to.beNil;
            });
            
            it(@"valid, it sets value", ^{
                PubnativeConfigModel *config = [PubnativeConfigUtils getModelFromJSONFile:@"config_valid"];
                [PubnativeConfigManager setStoredConfig:config];
                PubnativeConfigModel *newValue = [PubnativeConfigManager getStoredConfig];
                expect(newValue).toNot.beNil;
            });
        });
        
        context(@"with previous nil value", ^{
            itBehavesLike(@"when setting", nil);
        });
        
        context(@"with previous empty value", ^{
            itBehavesLike(@"when setting", @{kDataFirstKey : @"config_empty"});
        });
        
        context(@"with previous valid value", ^{
            itBehavesLike(@"when setting", @{kDataFirstKey : @"config_valid"});
        });
    });
});

describe(@"callback methods", ^{
   
    context(@"error", ^{
        
        sharedExamples(@"call methods", ^(NSDictionary *data) {
            
            it(@"doNextRequest", ^{
                id configManagerMock = OCMClassMock([PubnativeConfigManager class]);
                OCMStub([configManagerMock invokeDidFailWithError:[OCMArg any] delegate:[OCMArg any]]).andForwardToRealObject();
                OCMExpect([configManagerMock doNextRequest]);
                [configManagerMock invokeDidFailWithError:data[kDataFirstKey] delegate:nil];
                OCMVerifyAll(configManagerMock);
            });
            
            pending(@"resets IDLE to NO");
        });
        
        context(@"with nil delegate", ^{
            
            itBehavesLike(@"call methods", nil);
            itBehavesLike(@"call methods", @{kDataFirstKey : OCMClassMock([NSError class])});
        });
        
        context(@"with valid delegate", ^{
            
            sharedExamples(@"invokes delegate", ^(NSDictionary *data) {
                
                it(@"didFailWithError", ^{
                    
                    // Setup
                    id configManagerMock = OCMClassMock([PubnativeConfigManager class]);
                    OCMStub([configManagerMock invokeDidFailWithError:[OCMArg any] delegate:[OCMArg any]]).andForwardToRealObject();
                    OCMStub([configManagerMock doNextRequest]).andDo(nil);
                    
                    id delegateMock = OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate));
                    
                    /// Test
                    OCMExpect([delegateMock configDidFailWithError:[OCMArg any]]);
                    [configManagerMock invokeDidFailWithError:data[kDataFirstKey]
                                                     delegate:delegateMock];
                    OCMVerifyAll(delegateMock);
                });
            });
            
            context(@"and nil error", ^{
                itBehavesLike(@"call methods", nil);
                itBehavesLike(@"invokes delegate", nil);
            });
            
            context(@"and valid error", ^{
                itBehavesLike(@"call methods", @{kDataFirstKey : OCMClassMock([NSError class])});
                itBehavesLike(@"invokes delegate", @{kDataFirstKey : OCMClassMock([NSError class])});
            });
        });
    });
    
    sharedExamples(@"call methods", ^(NSDictionary *data) {
        
        it(@"doNextRequest", ^{
            id configManagerMock = OCMClassMock([PubnativeConfigManager class]);
            OCMStub([configManagerMock invokeDidFailWithError:[OCMArg any] delegate:[OCMArg any]]).andForwardToRealObject();
            OCMExpect([configManagerMock doNextRequest]);
            [configManagerMock invokeDidFailWithError:data[kDataFirstKey]
                                             delegate:nil];
            OCMVerifyAll(configManagerMock);
        });
        
        pending(@"resets IDLE to NO");
    });
    
    context(@"with nil delegate", ^{
        itBehavesLike(@"call methods", nil);
        itBehavesLike(@"call methods", @{kDataFirstKey : OCMClassMock([NSError class])});
    });
    
    context(@"with valid delegate", ^{
        
        sharedExamples(@"invokes delegate", ^(NSDictionary *data) {
            
            it(@"didFailWithError", ^{
                // Set up
                id configManagerMock = OCMClassMock([PubnativeConfigManager class]);
                OCMStub([configManagerMock invokeDidFailWithError:[OCMArg any] delegate:[OCMArg any]]).andForwardToRealObject();
                OCMStub([configManagerMock doNextRequest]).andDo(nil);
                
                id delegateMock = OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate));
                
                // Test
                OCMExpect([delegateMock configDidFailWithError:[OCMArg any]]);
                [configManagerMock invokeDidFailWithError:data[kDataFirstKey] delegate:delegateMock];
                OCMVerifyAll(delegateMock);
            });
        });
        
        context(@"and nil model", ^{
            itBehavesLike(@"call methods", nil);
            itBehavesLike(@"invokes delegate", nil);
        });
        context(@"and valid model", ^{
            itBehavesLike(@"call methods", @{kDataFirstKey : OCMClassMock([PubnativeConfigModel class])});
            itBehavesLike(@"invokes delegate", @{kDataFirstKey : OCMClassMock([PubnativeConfigModel class])});
        });
    });
});

describe(@"updating a config", ^{
    
    sharedExamples(@"set", ^(NSDictionary *data) {
        
        __block NSString                *configFile;
        __block NSString                *appToken;
        __block PubnativeConfigModel    *model;
        
        beforeAll(^{
            configFile = data[kDataFirstKey];
            appToken = data[kDataSecondKey];
        });
        
        beforeEach(^{
            if(configFile){
                model = [PubnativeConfigUtils getModelFromJSONFile:configFile];
            }
        });
        
        it(@"inner storage values", ^{
            NSTimeInterval oldTimestamp = [PubnativeConfigManager getStoredTimestamp];
            [PubnativeConfigManager updateStoredConfig:model withAppToken:appToken];
            expect([PubnativeConfigManager getStoredAppToken]).to.equal(appToken);
            expect([PubnativeConfigManager getStoredTimestamp]).toNot.equal(oldTimestamp);
            expect([[PubnativeConfigManager getStoredConfig] toDictionary]).to.equal([model toDictionary]);
        });
    });
    
    sharedExamples(@"dont set", ^(NSDictionary *data) {
        
        __block NSString                *configFile;
        __block NSString                *appToken;
        __block PubnativeConfigModel    *model;
        
        beforeAll(^{
            configFile = data[kDataFirstKey];
            appToken = data[kDataSecondKey];
        });
        
        beforeEach(^{
            if(configFile){
                model = [PubnativeConfigUtils getModelFromJSONFile:configFile];
            }
        });
        
        it(@"inner storage values", ^{
            NSString *oldAppToken = [PubnativeConfigManager getStoredAppToken];
            NSTimeInterval oldTimestamp = [PubnativeConfigManager getStoredTimestamp];
            PubnativeConfigModel *oldModel = [PubnativeConfigManager getStoredConfig];
            
            [PubnativeConfigManager updateStoredConfig:model withAppToken:appToken];
            
            expect([PubnativeConfigManager getStoredAppToken]).to.equal(oldAppToken);
            expect([PubnativeConfigManager getStoredTimestamp]).to.equal(oldTimestamp);
            expect([[PubnativeConfigManager getStoredConfig] toDictionary]).to.equal([oldModel toDictionary]);
        });
    });
    
    __block PubnativeConfigModel *emptyModelMock;
    __block PubnativeConfigModel *validModel;
    
    beforeAll(^{
        emptyModelMock = OCMClassMock([PubnativeConfigModel class]);
        OCMStub([emptyModelMock isEmpty]).andReturn(YES);
        
        validModel = [PubnativeConfigUtils getModelFromJSONFile:@"config_valid"];
    });
    
    context(@"without previous data", ^{
       
        beforeEach(^{
            // clean context
            [PubnativeConfigManager setStoredAppToken:nil];
            [PubnativeConfigManager setStoredTimestamp:0];
            [PubnativeConfigManager setStoredConfig:nil];
        });
        
        context(@"nil model and nil app token", ^{
            itBehavesLike(@"dont set", nil);
        });
        
        context(@"nil model and empty app token", ^{
            itBehavesLike(@"dont set", @{ kDataSecondKey : @"" });
        });
        
        context(@"nil model and valid app token", ^{
            itBehavesLike(@"dont set", @{ kDataSecondKey : kAppTokenValid });
        });
        
        context(@"empty model and nil app token", ^{
            itBehavesLike(@"dont set", @{ kDataFirstKey : kFileConfigEmpty });
        });
        
        context(@"empty model and empty app token", ^{
            itBehavesLike(@"dont set", @{ kDataFirstKey : kFileConfigEmpty,  kDataSecondKey : @"" });
        });
        
        context(@"empty model and valid app token", ^{
            itBehavesLike(@"dont set", @{ kDataFirstKey : kFileConfigEmpty,  kDataSecondKey : kAppTokenValid });
        });
        
        context(@"valid model and nil app token", ^{
            itBehavesLike(@"dont set", @{ kDataFirstKey : kFileConfigValid });
        });
        
        context(@"valid model and empty app token", ^{
            itBehavesLike(@"dont set", @{ kDataFirstKey : kFileConfigValid,  kDataSecondKey : @"" });
        });
        
        context(@"valid model and valid app token", ^{
            itBehavesLike(@"set", @{ kDataFirstKey : kFileConfigValid,  kDataSecondKey : kAppTokenValid });
        });
    });
    
    context(@"with previous data", ^{
        
        beforeEach(^{
            // clean context
            [PubnativeConfigManager setStoredAppToken:kAppTokenValid];
            [PubnativeConfigManager setStoredTimestamp:1];
            [PubnativeConfigManager setStoredConfig:validModel];
        });
        
        context(@"nil model and nil app token", ^{
            itBehavesLike(@"dont set", nil);
        });
        
        context(@"nil model and empty app token", ^{
            itBehavesLike(@"dont set", @{ kDataSecondKey : @"" });
        });
        
        context(@"nil model and valid app token", ^{
            itBehavesLike(@"dont set", @{ kDataSecondKey : kAppTokenValid });
        });
        
        context(@"empty model and nil app token", ^{
            itBehavesLike(@"dont set", @{ kDataFirstKey : kFileConfigEmpty });
        });
        
        context(@"empty model and empty app token", ^{
            itBehavesLike(@"dont set", @{ kDataFirstKey : kFileConfigEmpty,  kDataSecondKey : @"" });
        });
        
        context(@"empty model and valid app token", ^{
            itBehavesLike(@"dont set", @{ kDataFirstKey : kFileConfigEmpty,  kDataSecondKey : kAppTokenValid });
        });
        
        context(@"valid model and nil app token", ^{
            itBehavesLike(@"dont set", @{ kDataFirstKey : kFileConfigValid });
        });
        
        context(@"valid model and empty app token", ^{
            itBehavesLike(@"dont set", @{ kDataFirstKey : kFileConfigValid,  kDataSecondKey : @"" });
        });
        
        context(@"valid model and valid app token", ^{
            itBehavesLike(@"set", @{ kDataFirstKey : kFileConfigValid,  kDataSecondKey : kAppTokenValid });
        });
    });
    
});

describe(@"request queue", ^{
    
    sharedExamples(@"enqueue", ^(NSDictionary *globalData) {
       
        context(@"nil", ^{
            
            it(@"dont modifies queue", ^{
                // Set queue value
                NSMutableArray *oldQueue = globalData[kDataFirstKey];
                [PubnativeConfigManager sharedInstance].requestQueue = oldQueue;
                
                // set value and check
                [PubnativeConfigManager enqueueRequestModel:nil];
                expect([PubnativeConfigManager sharedInstance].requestQueue).to.equal(oldQueue);
            });
        });
        
        context(@"invalid", ^{
            
            sharedExamples(@"assigning request", ^(NSDictionary *data) {
            
                before(^{
                    [PubnativeConfigManager sharedInstance].requestQueue = globalData[kDataFirstKey];
                });
                it(@"dont changes request", ^{
                    NSMutableArray *oldQueue = [PubnativeConfigManager sharedInstance].requestQueue;
                    
                    // mock request
                    PubnativeConfigRequestModel *requestModel = OCMClassMock([PubnativeConfigRequestModel  class]);
                    OCMStub(requestModel.appToken).andReturn(data[kDataFirstKey]);
                    OCMStub(requestModel.completion).andReturn(data[kDataSecondKey]);
                    
                    // set value and check
                    [PubnativeConfigManager enqueueRequestModel:requestModel];
                    expect([PubnativeConfigManager sharedInstance].requestQueue).to.equal(oldQueue);
                });
            });
            
            context(@"nil appToken, nil completion", ^{
                itBehavesLike(@"assigning request", nil);
            });
            
            context(@"empty appToken, nil completion", ^{
                itBehavesLike(@"assigning request", @{kDataFirstKey : @""});
            });
            
            context(@"valid appToken, nil completion", ^{
                itBehavesLike(@"assigning request", @{kDataFirstKey : kAppTokenValid});
            });
            
            context(@"nil appToken, valid completion", ^{
                itBehavesLike(@"assigning request", @{kDataSecondKey : ^{}});
            });
            context(@"empty appToken, valid completion", ^{
                itBehavesLike(@"assigning request", @{kDataFirstKey : @"", kDataSecondKey : ^{}});
            });
        });
        
        context(@"valid", ^{
            
            __block PubnativeConfigRequestModel *validRequest;
            
            before(^{
                [PubnativeConfigManager sharedInstance].requestQueue = globalData[kDataFirstKey];
                validRequest = OCMClassMock([PubnativeConfigRequestModel  class]);
                OCMStub(validRequest.appToken).andReturn(kAppTokenValid);
                OCMStub(validRequest.completion).andReturn(^{});
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
        
        itBehavesLike(@"enqueue", nil);
        
        it(@"dequeues nil", ^{
            [PubnativeConfigManager sharedInstance].requestQueue = nil;
            PubnativeConfigRequestModel *model = [PubnativeConfigManager dequeueRequestDelegate];
            expect(model).to.beNil;
        });
    });
    
    context(@"initialized", ^{
        
        itBehavesLike(@"enqueue", ^{
            PubnativeConfigRequestModel *requestModel = OCMClassMock([PubnativeConfigRequestModel class]);
            return @{kDataFirstKey : [NSMutableArray arrayWithObject:requestModel]};
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
});

describe(@"public interface", ^{
    
    context(@"with invalid values", ^{
        
        sharedExamples(@"fails", ^(NSDictionary *data) {
        
            __block NSString *appToken;
            __block NSObject<PubnativeConfigManagerDelegate> *delegate;
            
            beforeAll(^{
                
            });
            
            it(@"callbacks with nil result and assigned error", ^{
                
                // ConfigManager mock
                PubnativeConfigManager *managerMock = OCMClassMock([PubnativeConfigManager class]);
                
                // Delegate mock
                NSObject<PubnativeConfigManagerDelegate> *delegateMock = OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate));
                OCMExpect([delegateMock configDidFailWithError:[OCMArg any]]);
                
                
                [managerMock configWithAppToken:data[kDataFirstKey]
                                       delegate:delegateMock];
                OCMVerifyAll(delegateMock);
                });
            });
        });
        
        itBehavesLike(@"fails", nil);
        itBehavesLike(@"fails", @{kDataFirstKey : @""});
    });
    
    context(@"with valid values", ^{
       
        it(@"calls doNextRequest", ^{
            PubnativeConfigManager *configManagerClassMock = OCMClassMock([PubnativeConfigManager class]);
            [configManagerClassMock configWithAppToken:kAppTokenValid
                                            completion:^(PubnativeConfigModel *result, NSError *error) {}];
            [verifyCount(configManagerClassMock, times(1)) doNextRequest];
        });
            
        it(@"enqueues item with app token and completion", ^{
            PubnativeConfigManager *configManagerClassMock = OCMClassMock([PubnativeConfigManager class]);
            [configManagerClassMock configWithAppToken:kAppTokenValid
                                        completion:^(PubnativeConfigModel *result, NSError *error) {}];
            expect([configManagerClassMock dequeueRequestDelegate]).toNot.beNil;
        });
    });
});

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

SpecEnd
