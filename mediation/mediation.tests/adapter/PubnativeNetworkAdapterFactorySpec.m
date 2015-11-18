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

SpecBegin(PubnativeNetworkAdapterFactory)

describe(@"adapter creation", ^{
    
    NSString *networkModelKey = @"networkModel";
    
    context(@"with nil model parameter", ^{
        it(@"returns nil", ^{
            expect([PubnativeNetworkAdapterFactory createApdaterWithNetwork:nil]).to.beNil();
        });
    });
    
    context(@"with valid network model", ^{
    
        __block id networkModelMock;
        
        before(^{
            networkModelMock = OCMClassMock([PubnativeNetworkModel class]);
        });
        
        context(@"and nil adapter name", ^{
            
            before(^{
                OCMStub([networkModelMock adapter]).andReturn(nil);
            });
            
            it(@"returns nil", ^{
                expect([PubnativeNetworkAdapterFactory createApdaterWithNetwork:networkModelMock]).to.beNil();
            });
        });
        
        context(@"and empty adapter name", ^{
            
            before(^{
                OCMStub([networkModelMock adapter]).andReturn(@"");
            });
            
            it(@"returns nil", ^{
                expect([PubnativeNetworkAdapterFactory createApdaterWithNetwork:networkModelMock]).to.beNil();
            });
        });
        
        context(@"and invalid adapter name", ^{
            
            before(^{
                OCMStub([networkModelMock adapter]).andReturn(@"NSObject");
            });
            
            it(@"returns nil", ^{
                expect([PubnativeNetworkAdapterFactory createApdaterWithNetwork:networkModelMock]).to.beNil();
            });
        });
        
        context(@"and not existent adapter name", ^{
            
            before(^{
                OCMStub([networkModelMock adapter]).andReturn(@"NotExistentClass");
            });
            
            it(@"returns nil", ^{
                expect([PubnativeNetworkAdapterFactory createApdaterWithNetwork:networkModelMock]).to.beNil();
            });
        });
        
        context(@"and valid adapter name", ^{
            
            NSString *validAdapterName = @"TestValidNetworkAdapter";
            before(^{
                OCMStub([networkModelMock adapter]).andReturn(validAdapterName);
            });
            
            
            it(@"creates a valid adapter", ^{
                PubnativeNetworkAdapter *adapter = [PubnativeNetworkAdapterFactory createApdaterWithNetwork:networkModelMock];
                expect(adapter).toNot.beNil();
                expect([adapter class]).to.equal(NSClassFromString(validAdapterName));
                expect([adapter class]).beSubclassOf([PubnativeNetworkAdapter class]);
            });
        });
    });
});

SpecEnd
