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
NSString * const kInvalidInExistentClass        = @"PubnativeAdapter";
NSString * const kInvalidNonPubnativeAdapter    = @"PubnativeConfigManager";

SpecBegin(PubnativeNetworkAdapterFactory)

describe(@"adapter creation", ^{
    
    sharedExamplesFor(@"dont create", ^(NSDictionary *data) {
        
        it(@"adapter", ^{
            PubnativeNetworkModel *model = OCMClassMock([PubnativeNetworkModel class]);
            OCMStub(model.adapter).andReturn(data[kAdapterKey]);
            PubnativeNetworkAdapter *adapter = [PubnativeNetworkAdapterFactory createApdaterWithNetwork:model];
            
            ///Test
            expect(adapter).to.beNil();
        });
    });
    
    sharedExamplesFor(@"create", ^(NSDictionary *data) {
        
        it(@"adapter", ^{
            PubnativeNetworkModel *model = OCMClassMock([PubnativeNetworkModel class]);
            OCMStub(model.adapter).andReturn(data[kAdapterKey]);
            PubnativeNetworkAdapter *adapter = [PubnativeNetworkAdapterFactory createApdaterWithNetwork:model];
            
            ///Test
            expect(adapter).toNot.beNil();
            expect([adapter class]).to.equal(NSClassFromString(kValidNetworkAdapter));
            expect([adapter class]).beSubclassOf([PubnativeNetworkAdapter class]);
        });
    });
    
    context(@"with valid network", ^{
        
        context(@"and nil adapter", ^{
            itBehavesLike(@"dont create", nil);
        });
        
        context(@"and empty adapter", ^{
            itBehavesLike(@"dont create", @{ kAdapterKey : @""});
        });
        
        context(@"and invalid adapter", ^{
            itBehavesLike(@"dont create", @{ kAdapterKey : kInvalidNonPubnativeAdapter});
        });
        
        context(@"and inexistent class", ^{
            itBehavesLike(@"dont create", @{ kAdapterKey : kInvalidInExistentClass});
        });
        
        context(@"and valid adapter", ^{
            itBehavesLike(@"create", @{ kAdapterKey : kValidNetworkAdapter});
        });
    });

    context(@"with nil network", ^{
        it(@"dont create adapter", ^{
            PubnativeNetworkAdapter *adapter = [PubnativeNetworkAdapterFactory createApdaterWithNetwork:nil];
            expect(adapter).to.beNil();
        });
    });
});

SpecEnd