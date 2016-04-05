//
//  PubnativeNetworkModel.m
//  mediation
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeNetworkModel.h"

@implementation PubnativeNetworkModel

+(instancetype)modelWithDictionary:(NSDictionary *)dictionary
{
    PubnativeNetworkModel *result;
    if(dictionary){
        result = [[PubnativeNetworkModel alloc] init];
        result.params = dictionary[@"params"];
        result.adapter = dictionary[@"adapter"];
        result.timeout = dictionary[@"timeout"];
        result.crash_report = dictionary[@"crash_report"];
    }
    return result;
}

- (BOOL)isCrashReportEnabled
{
    BOOL result = NO;
    if(self.crash_report){
    result = [self.crash_report boolValue];
    }
    return result;
}

@end
