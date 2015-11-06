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
        if (model.adapter && [model.adapter length] > 0) {
            Class adapterClass = NSClassFromString(model.adapter);
            if (adapterClass && [adapterClass isSubclassOfClass:[PubnativeNetworkAdapter class]]) {
                    adapter = [[adapterClass alloc] initWithDictionary:model.params];
            } else {
                NSLog(@"PubnativeNetworkAdapterFactory.createApdaterWithNetwork - Adapter not available");
            }
        } else {
            NSLog(@"PubnativeNetworkAdapterFactory.createApdaterWithNetwork - Invalid adapter name");
        }
    } else {
        NSLog(@"PubnativeNetworkAdapterFactory.createApdaterWithNetwork - Invalid network");
    }
    return adapter;
}

@end
