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
            __block PubnativeNetworkModel   *model;
            __block PubnativeNetworkAdapter *adapter;
            
            beforeAll(^{
                model = OCMClassMock([PubnativeNetworkModel class]);
                OCMStub(model.params).andReturn(OCMClassMock([NSDictionary class]));
            });
            
            it(@"nil, does not create adapter", ^{
                OCMStub(model.adapter).andReturn(data[kAdapterKey]);
                adapter = [PubnativeNetworkAdapterFactory createApdaterWithNetwork:model];
                expect(adapter).to.beNil();
            });
            
            it(@"empty, does not create adapter", ^{
                OCMStub(model.adapter).andReturn(data[kAdapterKey]);
                adapter = [PubnativeNetworkAdapterFactory createApdaterWithNetwork:model];
                expect(adapter).to.beNil();
            });
            
            it(@"invalid, does not creates adapter", ^{
                OCMStub(model.adapter).andReturn(data[kAdapterKey]);
                adapter = [PubnativeNetworkAdapterFactory createApdaterWithNetwork:model];
                expect([adapter class]).to.beNil();
            });
            
            it(@"with nil network model", ^{
                model = nil;
                adapter = [PubnativeNetworkAdapterFactory createApdaterWithNetwork:model];
                expect([adapter class]).to.beNil();
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
        sharedExamplesFor(@"when creating", ^(NSDictionary *data) {
            
            __block PubnativeNetworkModel   *model;
            __block PubnativeNetworkAdapter *adapter;
            
            beforeAll(^{
                model = OCMClassMock([PubnativeNetworkModel class]);
                OCMStub(model.params).andReturn(OCMClassMock([NSDictionary class]));
            });
            
            it(@"valid, creates adapter", ^{
                OCMStub(model.adapter).andReturn(data[kAdapterKey]);
                adapter = [PubnativeNetworkAdapterFactory createApdaterWithNetwork:model];
                expect(adapter).toNot.beNil();
                expect([adapter class]).to.equal(NSClassFromString(data[kAdapterKey]));
                expect([adapter class]).beSubclassOf([PubnativeNetworkAdapter class]);
            });
        });
        
        context(@"with valid network adapter", ^{
            itBehavesLike(@"when creating", @{kAdapterKey : kValidNetworkAdapter});
        });
    });
    
});

SpecEnd