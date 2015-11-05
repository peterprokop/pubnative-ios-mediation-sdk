//
//  PubnativeAdapterFactory.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeNetworkAdapterFactory.h"

@implementation PubnativeNetworkAdapterFactory

+ (PubnativeNetworkAdapter *)createApdaterWithNetwork:(PubnativeNetworkModel*)model
{
    PubnativeNetworkAdapter *adapter = nil;
    if (model) {
        if (model.adapter) {
            Class adapterClass = NSClassFromString(model.adapter);
            if (adapterClass && [adapterClass isSubclassOfClass:[PubnativeNetworkAdapter class]]) {
                    adapter = [[adapterClass alloc] initWithDictionary:model.params];
            }
        }
    }
    return adapter;
}

@end
