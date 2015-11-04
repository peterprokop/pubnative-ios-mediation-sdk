//
//  PubnativeAdapterFactory.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeNetworkAdapterFactory.h"

@implementation PubnativeNetworkAdapterFactory

+ (PubnativeNetworkAdapter *)createApdaterWithNetworkModel:(PubnativeNetworkModel*)networkModel
{
    PubnativeNetworkAdapter *adapter = nil;
    if (networkModel) {
        //First Get the string for the type of network adapter required
        NSString *adapterString = networkModel.adapter;
        
        if (adapterString) {
            
            Class adapterClass = NSClassFromString(adapterString);
            
            if (adapterClass && [adapterClass isSubclassOfClass:[PubnativeNetworkAdapter class]]) {
                
                if (networkModel.params) {
                    
                    adapter = [[adapterClass alloc] initWithParams:networkModel.params];
                    
                }
            }
        }
    }
    return adapter;
}

@end
