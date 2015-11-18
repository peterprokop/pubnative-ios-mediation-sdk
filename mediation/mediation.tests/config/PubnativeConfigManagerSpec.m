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
+ (BOOL)storedConfigNeedsUpdateWithAppToken:(NSString*)appToken;
+ (void)downloadConfigWithRequest:(PubnativeConfigRequestModel*)requestModel;
+ (void)processDownloadResponseWithRequest:(PubnativeConfigRequestModel*)requestModel
                                  withJson:(id)json
                                     error:(JSONModelError*)error;

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
    
    __block id userDefaultsMock;
    
    before(^{
        userDefaultsMock = OCMClassMock([NSUserDefaults class]);
        OCMStub([userDefaultsMock standardUserDefaults]).andReturn(userDefaultsMock);
        OCMStub([userDefaultsMock synchronize]).andReturn(YES);
    });
    
    context(@"for app token", ^{
        
        it(@"removes value when setting nil", ^{
            OCMExpect([userDefaultsMock removeObjectForKey:kUserDefaultsStoredAppTokenKey]);
            [PubnativeConfigManager setStoredAppToken:nil];
            OCMVerifyAll(userDefaultsMock);
        });
        
        it(@"removes value when setting empty", ^{
            OCMExpect([userDefaultsMock removeObjectForKey:kUserDefaultsStoredAppTokenKey]);
            [PubnativeConfigManager setStoredAppToken:@""];
            OCMVerifyAll(userDefaultsMock);
        });
        
        it(@"sets value when not empty or nil", ^{
            OCMExpect([userDefaultsMock setObject:@"app_token_valid" forKey:kUserDefaultsStoredAppTokenKey]);
            [PubnativeConfigManager setStoredAppToken:@"app_token_valid"];
            OCMVerifyAll(userDefaultsMock);
        });
    });
    
    context(@"for timestamp", ^{
        
        it(@"sets 0 when setting negative", ^{
            OCMExpect([userDefaultsMock setDouble:0 forKey:kUserDefaultsStoredTimestampKey]);
            [PubnativeConfigManager setStoredTimestamp:-1];
            OCMVerifyAll(userDefaultsMock);
        });
        
        it(@"sets 0 when setting 0", ^{
            OCMExpect([userDefaultsMock setDouble:0 forKey:kUserDefaultsStoredTimestampKey]);
            [PubnativeConfigManager setStoredTimestamp:0];
            OCMVerifyAll(userDefaultsMock);
        });
        
        it(@"sets value when setting possitive", ^{
            OCMExpect([userDefaultsMock setDouble:1 forKey:kUserDefaultsStoredTimestampKey]);
            [PubnativeConfigManager setStoredTimestamp:1];
            OCMVerifyAll(userDefaultsMock);
        });
    });
    
    context(@"config", ^{
        
        it(@"clears when setting nil", ^{
            OCMExpect([userDefaultsMock removeObjectForKey:kUserDefaultsStoredConfigKey]);
            [PubnativeConfigManager setStoredConfig:nil];
            OCMVerifyAll(userDefaultsMock);
        });
        
        it(@"clears when setting empty", ^{
            PubnativeConfigModel *emptyConfig = OCMClassMock([PubnativeConfigModel class]);
            OCMStub([emptyConfig isEmpty]).andReturn(YES);
            
            OCMExpect([userDefaultsMock removeObjectForKey:kUserDefaultsStoredConfigKey]);
            [PubnativeConfigManager setStoredConfig:emptyConfig];
            OCMVerifyAll(userDefaultsMock);
        });
        
        it(@"sets config when setting valid config", ^{
            PubnativeConfigModel *validConfig = OCMClassMock([PubnativeConfigModel class]);
            OCMStub([validConfig isEmpty]).andReturn(NO);
            
            OCMExpect([userDefaultsMock setObject:[OCMArg any] forKey:kUserDefaultsStoredConfigKey]);
            [PubnativeConfigManager setStoredConfig:validConfig];
            OCMVerifyAll(userDefaultsMock);
        });
    });
    
    after(^{
        [userDefaultsMock stopMocking];
    });
});

describe(@"callback methods", ^{
    
    __block id managerMock;
    
    before(^{
        managerMock = OCMClassMock([PubnativeConfigManager class]);
        OCMStub([managerMock sharedInstance]).andReturn(managerMock);
    });
    
    context(@"on error", ^{
        
        __block id errorMock;
        
        before(^{
            errorMock = OCMClassMock([NSError class]);
        });
    
        context(@"with nil delegate", ^{
        
            it(@"sets manager idle and calls doNextRequest", ^{
                OCMExpect([managerMock doNextRequest]);
                OCMExpect([managerMock setIdle:YES]);
                [PubnativeConfigManager invokeDidFailWithError:errorMock
                                                      delegate:nil];
                OCMVerifyAll(managerMock);
            });
        });
        
        context(@"with valid delegate", ^{
            
            it(@"callbacks and continues", ^{
                id delegateMock = OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate));
                
                OCMExpect([delegateMock configDidFailWithError:errorMock]);
                OCMExpect([managerMock doNextRequest]);
                OCMExpect([managerMock setIdle:YES]);
                [PubnativeConfigManager invokeDidFailWithError:errorMock
                                                      delegate:delegateMock];
                OCMVerifyAll(managerMock);
            });
        });
    });
    
    context(@"on success", ^{
        
        __block id modelMock;
        
        before(^{
            modelMock = OCMClassMock([PubnativeConfigModel class]);
        });
        
        context(@"with nil delegate", ^{
            
            it(@"sets manager idle and calls doNextRequest", ^{
                OCMExpect([managerMock doNextRequest]);
                OCMExpect([managerMock setIdle:YES]);
                [PubnativeConfigManager invokeDidFinishWithModel:modelMock
                                                        delegate:nil];
                OCMVerifyAll(managerMock);
            });
        });
        
        context(@"with valid delegate", ^{
            
            it(@"callbacks and continues", ^{
                id delegateMock = OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate));
                
                OCMExpect([delegateMock configDidFinishWithModel:modelMock]);
                OCMExpect([managerMock doNextRequest]);
                OCMExpect([managerMock setIdle:YES]);
                [PubnativeConfigManager invokeDidFinishWithModel:modelMock
                                                        delegate:delegateMock];
                OCMVerifyAll(managerMock);
            });
        });
    });
    
    after(^{
        [managerMock stopMocking];
    });
});

describe(@"updating a config", ^{
    
    NSString *appTokenValid = @"app_token_valid";
    
    NSString *configKey     = @"config";
    NSString *appTokenKey   = @"appToken";
    
    NSString *sharedTestUpdate = @"updates internal values";
    sharedExamples(sharedTestUpdate, ^(NSDictionary *data) {
        
        it(@"invoking set storage values", ^{
            id managerMock = OCMClassMock([PubnativeConfigManager class]);
            id configModel = data[configKey];
            id appToken = data[appTokenKey];
            
            OCMExpect([managerMock setStoredAppToken:appToken]);
            OCMExpect([managerMock setStoredConfig:configModel]);
            OCMExpect([[managerMock ignoringNonObjectArgs] setStoredTimestamp:0]);
            [PubnativeConfigManager updateStoredConfig:configModel
                                          withAppToken:appToken];
            
            OCMVerifyAll(managerMock);
            [managerMock stopMocking];
        });
    });
    
    NSString *sharedTestDontUpdate = @"dont update";
    sharedExamples(sharedTestDontUpdate, ^(NSDictionary *data) {
        
        it(@"inner storage values", ^{
            id managerMock = OCMClassMock([PubnativeConfigManager class]);
            id configModel = data[configKey];
            id appToken = data[appTokenKey];
            
            [[managerMock reject] setStoredAppToken:[OCMArg any]];
            [[managerMock reject] setStoredConfig:[OCMArg any]];
            [[managerMock reject] setStoredTimestamp:0];
            
            [PubnativeConfigManager updateStoredConfig:configModel
                                          withAppToken:appToken];
            
            [managerMock stopMocking];
        });
    });
    
    context(@"with nil model", ^{
       
        context(@"and nil app token", ^{
            itShouldBehaveLike(sharedTestDontUpdate, @{});
        });
       
        context(@"and empty app token", ^{
            itShouldBehaveLike(sharedTestDontUpdate, @{appTokenKey : @""});
        });
        
        context(@"and valid app token", ^{
            itShouldBehaveLike(sharedTestDontUpdate, @{appTokenKey : appTokenValid});
        });
    });
    
    context(@"with empty model", ^{
        
        __block id modelMock;
        
        before(^{
            modelMock = OCMClassMock([PubnativeConfigModel class]);
            OCMStub([modelMock isEmpty]).andReturn(YES);
        });
        
        context(@"and nil app token", ^{
            itShouldBehaveLike(sharedTestDontUpdate,^{ return @{configKey : modelMock}; });
        });
        
        context(@"and empty app token", ^{
            itShouldBehaveLike(sharedTestDontUpdate,^{ return @{configKey : modelMock,
                                                                appTokenKey : @""}; });
        });
        
        context(@"and valid app token", ^{
            itShouldBehaveLike(sharedTestDontUpdate,^{ return @{configKey : modelMock,
                                                                appTokenKey : appTokenValid}; });
        });
    });
    
    context(@"with valid model", ^{
        
        __block id modelMock;
        
        before(^{
            modelMock = OCMClassMock([PubnativeConfigModel class]);
            OCMStub([modelMock isEmpty]).andReturn(NO);
        });
        
        context(@"and nil app token", ^{
            itShouldBehaveLike(sharedTestDontUpdate,^{ return @{configKey : modelMock}; });
        });
        
        context(@"and empty app token", ^{
            itShouldBehaveLike(sharedTestDontUpdate,^{ return @{configKey : modelMock,
                                                                appTokenKey : @""}; });
        });
        
        context(@"and valid app token", ^{
            itShouldBehaveLike(sharedTestUpdate,^{ return @{configKey : modelMock,
                                                            appTokenKey : appTokenValid}; });
        });
    });
});

describe(@"processing next request in queue", ^{
    
    __block id managerMock;
    
    before(^{
        managerMock = OCMClassMock([PubnativeConfigManager class]);
        OCMStub([managerMock sharedInstance]).andReturn(managerMock);
    });
    
    context(@"with idle manager", ^{
        
        before(^{
            OCMStub([managerMock idle]).andReturn(YES);
        });
        
        it(@"without next request keeps manager idle", ^{
            OCMStub([managerMock dequeueRequestDelegate]).andReturn(nil);
            
            OCMExpect([managerMock setIdle:YES]);
            [PubnativeConfigManager doNextRequest];
            OCMVerifyAll(managerMock);
        });
        
        it(@"with next request manager idle is disabled", ^{
            id requestModel = OCMClassMock([PubnativeConfigRequestModel class]);
            
            OCMStub([managerMock dequeueRequestDelegate]).andReturn(requestModel);
            
            OCMExpect([managerMock getNextConfigWithModel:requestModel]);
            OCMExpect([managerMock setIdle:NO]);
            [PubnativeConfigManager doNextRequest];
            OCMVerifyAll(managerMock);
        });
    });
    
    after(^{
        [managerMock stopMocking];
    });
});

describe(@"request queue", ^{
    
    NSString *appTokenValid = @"app_token_valid";
    
    __block id managerMock;
    
    before(^{
        managerMock = OCMClassMock([PubnativeConfigManager class]);
        OCMStub([managerMock sharedInstance]).andReturn(managerMock);
    });
    
    context(@"enqueuing", ^{
       
        context(@"never access request queue", ^{

            before(^{
                [[managerMock reject] requestQueue];
            });
            
            it(@"with nil request", ^{
                [PubnativeConfigManager enqueueRequestModel:nil];
            });
            
            context(@"with valid request", ^{
               
                __block id requestMock;
                
                before(^{
                    requestMock = OCMClassMock([PubnativeConfigRequestModel class]);
                });
                
                context(@"nil delegate", ^{
                    
                    before(^{
                        OCMStub([requestMock delegate]).andReturn(nil);
                    });
                   
                    it(@"and nil appToken", ^{
                        OCMStub([requestMock appToken]).andReturn(nil);
                        [PubnativeConfigManager enqueueRequestModel:requestMock];
                    });
                    
                    it(@"and empty appToken", ^{
                        OCMStub([requestMock appToken]).andReturn(@"");
                        [PubnativeConfigManager enqueueRequestModel:requestMock];
                    });
                    
                    it(@"and valid appToken", ^{
                        OCMStub([requestMock appToken]).andReturn(appTokenValid);
                        [PubnativeConfigManager enqueueRequestModel:requestMock];
                    });
                });
                
                context(@"valid delegate", ^{
                    
                    before(^{
                        OCMStub([requestMock delegate]).andReturn(OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate)));
                    });
                    
                    it(@"and nil appToken", ^{
                        OCMStub([requestMock appToken]).andReturn(nil);
                        [PubnativeConfigManager enqueueRequestModel:requestMock];
                    });
                    
                    it(@"and empty appToken", ^{
                        OCMStub([requestMock appToken]).andReturn(@"");
                        [PubnativeConfigManager enqueueRequestModel:requestMock];
                    });
                });
            });
        });
        
        context(@"with valid request", ^{
            
            __block id requestMock;
            
            before(^{
                requestMock = OCMClassMock([PubnativeConfigRequestModel class]);
                OCMStub([requestMock delegate]).andReturn(OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate)));
                OCMStub([requestMock appToken]).andReturn(appTokenValid);
            });
            
            context(@"previously not initialized", ^{
                
                before(^{
                    OCMStub([managerMock requestQueue]).andReturn(nil);
                });
                
                it(@"initializes queue", ^{
                    OCMExpect([managerMock setRequestQueue:[OCMArg any]]);
                    [PubnativeConfigManager enqueueRequestModel:requestMock];
                    OCMVerifyAll(managerMock);
                });
            });
            
            context(@"previously initialized", ^{
               
                __block id queueMock;
                
                before(^{
                    queueMock = OCMClassMock([NSMutableArray class]);
                    OCMStub([managerMock requestQueue]).andReturn(queueMock);
                });
                
                it(@"adds request", ^{
                    OCMExpect([queueMock addObject:[OCMArg any]]);
                    [PubnativeConfigManager enqueueRequestModel:requestMock];
                    OCMVerifyAll(queueMock);
                });
            });
        });
    });
    
    context(@"dequeues", ^{

        context(@"without request queue", ^{
            
            before(^{
                OCMStub([managerMock requestQueue]).andReturn(nil);
            });
            
            it(@"returns nil", ^{
                expect([PubnativeConfigManager dequeueRequestDelegate]).to.beNil();
            });
        });
        
        context(@"with request queue", ^{
            
            __block id queueMock;
            
            before(^{
                queueMock = OCMClassMock([NSMutableArray class]);
                OCMStub([managerMock requestQueue]).andReturn(queueMock);
            });
            
            context(@"empty", ^{
                
                before(^{
                    OCMStub([queueMock count]).andReturn(0);
                });
                
                it(@"returns nil", ^{
                    expect([PubnativeConfigManager dequeueRequestDelegate]).to.beNil();
                });
            });
            
            context(@"with something", ^{
                
                before(^{
                    OCMStub([queueMock count]).andReturn(1);
                });
                
                it(@"access the first item and removes it from the queue", ^{
                    OCMExpect([queueMock objectAtIndex:0]);
                    OCMExpect([queueMock removeObjectAtIndex:0]);
                    [PubnativeConfigManager dequeueRequestDelegate];
                    OCMVerifyAll(queueMock);
                });
            });
        });
    });
    
    after(^{
        [managerMock stopMocking];
    });
});

describe(@"public interface", ^{
    
    NSString *appTokenValid = @"app_token_valid";
    
    __block id  managerMock;
    
    before(^{
        managerMock = OCMClassMock([PubnativeConfigManager class]);
    });
    
    context(@"never continues without delegate", ^{
           
        before(^{
            [[managerMock reject] doNextRequest];
            [[managerMock reject] enqueueRequestModel:[OCMArg any]];
        });
        
        it(@"and nil appToken", ^{
            [PubnativeConfigManager configWithAppToken:nil
                                              delegate:nil];
        });
        
        it(@"and empty appToken", ^{
            [PubnativeConfigManager configWithAppToken:@""
                                              delegate:nil];
        });
            
        it(@"and valid appToken", ^{
            [PubnativeConfigManager configWithAppToken:appTokenValid
                                              delegate:nil];
        });
    });
        
    context(@"with valid delegate", ^{

        __block id delegateMock;
        
        before(^{
            delegateMock = OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate));
        });
            
        it(@"and nil appToken fail callback", ^{
            OCMExpect([managerMock invokeDidFailWithError:[OCMArg any] delegate:delegateMock]);
            [PubnativeConfigManager configWithAppToken:nil
                                              delegate:delegateMock];
            OCMVerifyAll(managerMock);
        });
            
        it(@"and empty appToken fail callback", ^{
            OCMExpect([managerMock invokeDidFailWithError:[OCMArg any] delegate:delegateMock]);
            [PubnativeConfigManager configWithAppToken:@""
                                              delegate:delegateMock];
            OCMVerifyAll(managerMock);
        });
            
        it(@"and valid appToken continues", ^{
            OCMExpect([managerMock doNextRequest]);
            OCMExpect([managerMock enqueueRequestModel:[OCMArg checkWithBlock:^BOOL(id obj) {
                PubnativeConfigRequestModel *model = obj;
                return [model.appToken isEqualToString:appTokenValid] && [model.delegate isEqual:delegateMock];
            }]]);
            
            [PubnativeConfigManager configWithAppToken:appTokenValid
                                              delegate:delegateMock];
            
            OCMVerifyAll(managerMock);
        });
    });
    
    after(^{
        [managerMock stopMocking];
    });
});

describe(@"serving stored config", ^{
    
    __block id managerMock;
    
    before(^{
       managerMock = OCMClassMock([PubnativeConfigManager class]);
    });
    
    context(@"without stored config", ^{
        
        before(^{
            OCMStub([managerMock getStoredConfig]).andReturn(nil);
        });
        
        it(@"callback fail", ^{
            id delegateMock = OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate));
            id requestModelMock = OCMClassMock([PubnativeConfigRequestModel class]);
            OCMStub([requestModelMock delegate]).andReturn(delegateMock);
            
            OCMExpect([managerMock invokeDidFailWithError:[OCMArg any] delegate:delegateMock]);
            [PubnativeConfigManager serveStoredConfigWithRequest:requestModelMock];
            OCMVerifyAll(managerMock);
        });
    });
    
    context(@"with stored config", ^{
        
        __block id modelMock;
        
        before(^{
            modelMock = OCMClassMock([PubnativeConfigModel class]);
            OCMStub([managerMock getStoredConfig]).andReturn(modelMock);
        });
        
        it(@"callback finish", ^{
            id delegateMock = OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate));
            id requestModelMock = OCMClassMock([PubnativeConfigRequestModel class]);
            OCMStub([requestModelMock delegate]).andReturn(delegateMock);
            
            OCMExpect([managerMock invokeDidFinishWithModel:modelMock delegate:delegateMock]);
            [PubnativeConfigManager serveStoredConfigWithRequest:requestModelMock];
            OCMVerifyAll(managerMock);
        });
    });
    
    after(^{
       [managerMock stopMocking];
    });
});

describe(@"requesting a config", ^{
   
    __block id managerMock;
    
    before(^{
        managerMock = OCMClassMock([PubnativeConfigManager class]);
    });
    
    context(@"with update needed", ^{
        
        before(^{
            OCMStub([managerMock storedConfigNeedsUpdateWithAppToken:[OCMArg any]]).andReturn(YES);
        });
        
        it(@"tries downloading a config", ^{
            id requestModelMock = OCMClassMock([PubnativeConfigRequestModel class]);
            
            OCMExpect([managerMock downloadConfigWithRequest:requestModelMock]);
            [PubnativeConfigManager getNextConfigWithModel:requestModelMock];
            OCMVerifyAll(managerMock);
        });
    });
    
    context(@"without update needed", ^{
        
        before(^{
            OCMStub([managerMock storedConfigNeedsUpdateWithAppToken:[OCMArg any]]).andReturn(NO);
        });
        
        it(@"tries downloading a config", ^{
            id requestModelMock = OCMClassMock([PubnativeConfigRequestModel class]);
            
            OCMExpect([managerMock serveStoredConfigWithRequest:requestModelMock]);
            [PubnativeConfigManager getNextConfigWithModel:requestModelMock];
            OCMVerifyAll(managerMock);
        });
    });
    
    after(^{
        [managerMock stopMocking];
    });
});

describe(@"checking if stored config needs update", ^{
   
    NSString *requestAppToken = @"appToken";
    
    __block id managerMock;
    
    before(^{
        managerMock = OCMClassMock([PubnativeConfigManager class]);
    });
    
    context(@"without previous stored config", ^{
        
        before(^{
           OCMStub([managerMock getStoredConfig]).andReturn(nil);
        });
        
        it(@"should return YES", ^{
            expect([PubnativeConfigManager storedConfigNeedsUpdateWithAppToken:requestAppToken]).to.beTruthy();
        });
    });
    
    context(@"with previous stored config", ^{
        
        __block id modelMock;
        
        before(^{
            modelMock = OCMClassMock([PubnativeConfigModel class]);
            OCMStub([managerMock getStoredConfig]).andReturn(modelMock);
        });
        
        context(@"without previous stored app token", ^{
            before(^{
                OCMStub([managerMock getStoredAppToken]).andReturn(nil);
            });
            
            it(@"should return YES", ^{
                expect([PubnativeConfigManager storedConfigNeedsUpdateWithAppToken:requestAppToken]).to.beTruthy();
            });
        });
        
        context(@"with previous stored app token different", ^{
            
            before(^{
                OCMStub([managerMock getStoredAppToken]).andReturn(@"invalidAppToken");
            });
            
            it(@"should return YES", ^{
                expect([PubnativeConfigManager storedConfigNeedsUpdateWithAppToken:requestAppToken]).to.beTruthy();
            });
        });
        
        context(@"with previous stored app token same", ^{
            
            before(^{
                OCMStub([managerMock getStoredAppToken]).andReturn(requestAppToken);
            });
            
            context(@"without previous stored timestamp", ^{
                
                before(^{
                    OCMStub([managerMock getStoredTimestamp]).andReturn(nil);
                });
                
                expect([PubnativeConfigManager storedConfigNeedsUpdateWithAppToken:requestAppToken]).to.beTruthy();
            });
            
            context(@"with refresh time nil", ^{
                
                __block id globalsMock;
                
                before(^{
                    globalsMock = OCMClassMock([PubnativeConfigGlobalsModel class]);
                    OCMStub([modelMock globals]).andReturn(globalsMock);
                    OCMStub([globalsMock refresh]).andReturn(nil);
                });
                
                it(@"should return YES", ^{
                    expect([PubnativeConfigManager storedConfigNeedsUpdateWithAppToken:requestAppToken]).to.beTruthy();
                });
            });
            
            context(@"with refresh time 0", ^{
                
                __block id globalsMock;
                
                before(^{
                    globalsMock = OCMClassMock([PubnativeConfigGlobalsModel class]);
                    OCMStub([modelMock globals]).andReturn(globalsMock);
                    OCMStub([globalsMock refresh]).andReturn(@0);
                });
                
                it(@"should return YES", ^{
                    expect([PubnativeConfigManager storedConfigNeedsUpdateWithAppToken:requestAppToken]).to.beTruthy();
                });
            });
            
            context(@"with previous stored timestamp and positive refresh time", ^{
                
                NSNumber *refreshValue = @1;
                
                __block id globalsMock;
                
                before(^{
                    globalsMock = OCMClassMock([PubnativeConfigGlobalsModel class]);
                    OCMStub([modelMock globals]).andReturn(globalsMock);
                    OCMStub([globalsMock refresh]).andReturn(refreshValue);
                });
                
                context(@"and overdue time", ^{
                    
                    before(^{
                        OCMStub([managerMock getStoredTimestamp]).andReturn(0);
                    });
                    
                    it(@"should return YES", ^{
                        expect([PubnativeConfigManager storedConfigNeedsUpdateWithAppToken:requestAppToken]).to.beTruthy();
                    });
                });
                
                context(@"and still valid time", ^{
                    
                    before(^{
                        OCMStub([managerMock getStoredTimestamp]).andReturn([[NSDate date] timeIntervalSince1970]);
                    });
                    
                    it(@"should return NO", ^{
                        expect([PubnativeConfigManager storedConfigNeedsUpdateWithAppToken:requestAppToken]).to.beFalsy();
                    });
                });
            });
        });
    });
    
    after(^{
        [managerMock stopMocking];
    });
});

describe(@"processing download", ^{
    
    NSString *requestAppToken = @"appToken";
    __block id managerMock;
    __block id delegateMock;
    __block id requestMock;
    
    before(^{
        managerMock = OCMClassMock([PubnativeConfigManager class]);
        delegateMock = OCMProtocolMock(@protocol(PubnativeConfigManagerDelegate));
        requestMock = OCMClassMock([PubnativeConfigRequestModel class]);
        OCMStub([requestMock appToken]).andReturn(requestAppToken);
        OCMStub([requestMock delegate]).andReturn(delegateMock);
    });
    
    __block id jsonParameter;
    __block id errorParameter;
    
    context(@"with error", ^{
        
        before(^{
            errorParameter = OCMClassMock([JSONModelError class]);
        });
        
        context(@"and nil dictionary", ^{
            
            before(^{
                jsonParameter = nil;
            });
            
            it(@"callback fail", ^{
                OCMExpect([managerMock invokeDidFailWithError:[OCMArg any] delegate:delegateMock]);
                [PubnativeConfigManager processDownloadResponseWithRequest:requestMock
                                                                  withJson:jsonParameter
                                                                     error:errorParameter];
                OCMVerifyAll(managerMock);
            });
        });
        
        context(@"and valid dictionary", ^{
            
            before(^{
                jsonParameter = OCMClassMock([NSDictionary class]);
            });
            
            it(@"callback fail", ^{
                OCMExpect([managerMock invokeDidFailWithError:[OCMArg any] delegate:delegateMock]);
                [PubnativeConfigManager processDownloadResponseWithRequest:requestMock
                                                                  withJson:jsonParameter
                                                                     error:errorParameter];
                OCMVerifyAll(managerMock);
            });
        });
    });
    
    context(@"with nil error", ^{
        
        before(^{
            errorParameter = nil;
        });
        
        context(@"and nil dictionary", ^{
            
            before(^{
                jsonParameter = nil;
            });
            
            it(@"callback fail", ^{
                OCMExpect([managerMock invokeDidFailWithError:[OCMArg any] delegate:delegateMock]);
                [PubnativeConfigManager processDownloadResponseWithRequest:requestMock
                                                                  withJson:jsonParameter
                                                                     error:errorParameter];
                OCMVerifyAll(managerMock);
            });
        });
        
        context(@"and valid dictionary", ^{
            
            __block id responseModelMock;
            
            before(^{
                responseModelMock = OCMClassMock([PubnativeConfigAPIResponseModel class]);
                jsonParameter = OCMClassMock([NSDictionary class]);
            });
            
            context(@"non parseable", ^{
               
                __block id parseError;
                
                before(^{
                    parseError = OCMClassMock([NSError class]);
                    OCMStub([responseModelMock parseDictionary:[OCMArg any]
                                                         error:[OCMArg setTo:parseError]]).andReturn(nil);
                });
                
                it(@"callback fail", ^{
                    OCMExpect([managerMock invokeDidFailWithError:parseError
                                                         delegate:delegateMock]);
                    
                    [PubnativeConfigManager processDownloadResponseWithRequest:requestMock
                                                                      withJson:jsonParameter
                                                                         error:errorParameter];
                    OCMVerifyAll(managerMock);
                });
            });
            
            context(@"parseable", ^{
                
                before(^{
                    OCMStub([responseModelMock parseDictionary:[OCMArg any]
                                                         error:[OCMArg anyObjectRef]]).andReturn(responseModelMock);
                });
                
                context(@"with error response", ^{
                    
                    before(^{
                        OCMStub([responseModelMock success]).andReturn(NO);
                    });
                    
                    it(@"callback fail", ^{
                        OCMExpect([responseModelMock error_message]);
                        OCMExpect([managerMock invokeDidFailWithError:[OCMArg any]
                                                             delegate:delegateMock]);
                        
                        [PubnativeConfigManager processDownloadResponseWithRequest:requestMock
                                                                          withJson:jsonParameter
                                                                             error:errorParameter];
                        OCMVerifyAll(managerMock);
                        OCMVerifyAll(responseModelMock);
                    });
                });
                
                context(@"with success response", ^{
                    
                    __block id configMock;
                    
                    before(^{
                        configMock = OCMClassMock([PubnativeConfigModel class]);
                        OCMStub([responseModelMock success]).andReturn(YES);
                        OCMStub([responseModelMock config]).andReturn(configMock);
                        
                    });
                    
                    it(@"updates and serve", ^{
                        OCMExpect([managerMock updateStoredConfig:configMock withAppToken:requestAppToken]);
                        OCMExpect([managerMock serveStoredConfigWithRequest:requestMock]);
                        
                        [PubnativeConfigManager processDownloadResponseWithRequest:requestMock
                                                                          withJson:jsonParameter
                                                                             error:errorParameter];
                        
                        OCMVerifyAll(managerMock);
                    });
                });
            });
            
            after(^{
                [responseModelMock stopMocking];
            });
        });
    });
    
    after(^{
        [managerMock stopMocking];
    });
});

SpecEnd
