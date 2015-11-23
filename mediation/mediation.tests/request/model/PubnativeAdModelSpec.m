//
//  PubnativeNetworkAdapterSpec.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "Specta.h"
#import "Expecta.h"
#import "PubnativeAdModel.h"
#import <OCMock/OCMock.h>

@interface PubnativeAdModel (Private)

@property (nonatomic, weak) NSObject<PubnativeAdModelDelegate> *delegate;

- (void)invokeDidConfirmedImpression:(PubnativeAdModel*)ad;
- (void)invokeDidClicked:(PubnativeAdModel*)ad;

@end

SpecBegin(PubnativeAdModel)

describe(@"callback methods", ^{

    context(@"with delegate", ^{
        
        __block id modelMock;
        __block id delegateMock;
        
        before(^{
            delegateMock = OCMProtocolMock(@protocol(PubnativeAdModelDelegate));
            modelMock = OCMPartialMock([[PubnativeAdModel alloc] init]);
            OCMStub([modelMock delegate]).andReturn(delegateMock);
        });
        
        it(@"invokeDidClicked callback delegate", ^{
            OCMExpect([delegateMock pubnativeAdDidClicked:[OCMArg isNotNil]]);
            [modelMock invokeDidClicked:modelMock];
            OCMVerifyAll(delegateMock);
        });
        
        it(@"invokeDidConfirmedImpression callback delegate", ^{
            OCMExpect([delegateMock pubantiveAdDidConfirmedImpression:[OCMArg isNotNil]]);
            [modelMock invokeDidConfirmedImpression:modelMock];
            OCMVerifyAll(delegateMock);
        });
    });
});

SpecEnd
