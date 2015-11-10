//
//  PubnativeNetworkRequestSpec.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "Specta.h"
#import "Expecta.h"
#import "PubnativeNetworkRequest.h"
#import <OCMock/OCMock.h>

static NSString * const kAppTokenValid              = @"e3886645aabbf0d5c06f841a3e6d77fcc8f9de4469d538ab8a96cb507d0f2660";
static NSString * const kPlacementFacebookOnlyKey   = @"facebook_only";

SpecBegin(PubnativeNetworkRequest)

describe(@"Behaviour", ^{

    beforeAll(^{
        // This is run once and only once before all of the examples
        // in this group and before any beforeEach blocks.
    });
    
    beforeEach(^{
        // This is run before each example.
    });
    
    it(@"Pubnative Request Start Request", ^{
        PubnativeNetworkRequest *request = [[PubnativeNetworkRequest alloc]init];
        [request startRequestWithAppToken:kAppTokenValid placementKey:kPlacementFacebookOnlyKey delegate:OCMProtocolMock(@protocol(PubnativeNetworkRequestDelegate))];
        pending(@"write some tests");
    });
    
    pending(@"write some tests");
    
    afterEach(^{
        // This is run after each example.
    });
    
    afterAll(^{
        // This is run once and only once after all of the examples
        // in this group and after any afterEach blocks.
    });
});

SpecEnd
