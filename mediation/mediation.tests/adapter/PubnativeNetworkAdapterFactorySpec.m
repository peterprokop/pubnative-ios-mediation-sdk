//
//  PubnativeNetworkAdapterFactorySpec.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "Specta.h"
#import "Expecta.h"
#import "PubnativeNetworkAdapterFactory.h"
#import "PubnativeNetworkAdapter.h"
#import <OCMock/OCMock.h>

NSString * const kAdapterKey                    = @"adapter_key";
NSString * const kValidNetworkAdapter           = @"TestValidNetworkAdapter";
NSString * const kInvalidNonExistentClass       = @"PubnativeAdapter";
NSString * const kInvalidNonPubnativeAdapter    = @"PubnativeConfigManager";

SpecBegin(PubnativeNetworkAdapterFactory)

describe(@"adapter creation", ^{
    
    context(@"for error", ^{
        
        sharedExamplesFor(@"when creating", ^(NSDictionary *data) {
            
            __block PubnativeNetworkModel *networkModel;
            __block PubnativeNetworkAdapter *networkAdapter;
            
            beforeAll(^{
                networkModel = OCMClassMock([PubnativeNetworkModel class]);
                OCMStub(networkModel.params).andReturn(OCMClassMock([NSDictionary class]));
            });
            
            it(@"nil, does not create adapter", ^{
                OCMStub(networkModel.adapter).andReturn(data[kAdapterKey]);
                networkAdapter = [PubnativeNetworkAdapterFactory createApdaterWithNetworkModel:networkModel];
                expect(networkAdapter).to.beNil();
            });
            
            it(@"empty, does not create adapter", ^{
                OCMStub(networkModel.adapter).andReturn(data[kAdapterKey]);
                networkAdapter = [PubnativeNetworkAdapterFactory createApdaterWithNetworkModel:networkModel];
                expect(networkAdapter).to.beNil();
            });
            
            it(@"invalid, does not creates adapter", ^{
                OCMStub(networkModel.adapter).andReturn(data[kAdapterKey]);
                networkAdapter = [PubnativeNetworkAdapterFactory createApdaterWithNetworkModel:networkModel];
                expect([networkAdapter class]).to.beNil();
            });
            
            it(@"with nil network model", ^{
                networkModel = nil;
                networkAdapter = [PubnativeNetworkAdapterFactory createApdaterWithNetworkModel:networkModel];
                expect([networkAdapter class]).to.beNil();
            });
        });
        
        context(@"with invalid adapter", ^{
            itBehavesLike(@"when creating", @{kAdapterKey : kInvalidNonExistentClass});
        });
        
        context(@"with valid class but invalid adpater", ^{
            itBehavesLike(@"when creating", @{kAdapterKey : kInvalidNonPubnativeAdapter});
        });
        
        context(@"with empty adapter", ^{
            itBehavesLike(@"when creating", @{kAdapterKey : @""});
        });
       
        context(@"with nil adapter", ^{
            itBehavesLike(@"when creating", nil);
        });
        
    });
    
    context(@"for success", ^{
        {
            
            sharedExamplesFor(@"when creating", ^(NSDictionary *data) {
                
                __block PubnativeNetworkModel *networkModel;
                __block PubnativeNetworkAdapter *networkAdapter;
                
                beforeAll(^{
                    networkModel = OCMClassMock([PubnativeNetworkModel class]);
                    OCMStub(networkModel.params).andReturn(OCMClassMock([NSDictionary class]));
                });
                
                it(@"valid, creates adapter", ^{
                    OCMStub(networkModel.adapter).andReturn(data[kAdapterKey]);
                    networkAdapter = [PubnativeNetworkAdapterFactory createApdaterWithNetworkModel:networkModel];
                    expect(networkAdapter).toNot.beNil();
                    expect([networkAdapter class]).to.equal(NSClassFromString(data[kAdapterKey]));
                    expect([networkAdapter class]).beSubclassOf([PubnativeNetworkAdapter class]);
                });
            });
            
            context(@"with valid network adapter", ^{
                itBehavesLike(@"when creating", @{kAdapterKey : kValidNetworkAdapter});
            });
            
        }
    });
    
});

SpecEnd