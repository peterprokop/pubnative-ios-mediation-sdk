//
//  FacebookNetworkAdapter.h
//  mediation
//
//  Created by Mohit on 27/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeNetworkAdapter.h"

@import FBAudienceNetwork;

@interface FacebookNetworkAdapter : PubnativeNetworkAdapter<FBNativeAdDelegate>

- (void) makeRequest;

@end
