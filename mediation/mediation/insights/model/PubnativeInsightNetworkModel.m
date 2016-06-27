//
//  PubnativeInsightNetworkModel.m
//  mediation
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PubnativeInsightNetworkModel.h"

@implementation PubnativeInsightNetworkModel

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.code = [coder decodeObjectForKey:@"code"];
        self.priority_rule_id = [coder decodeObjectForKey:@"priority_rule_id"];
        self.priority_segment_ids = [coder decodeObjectForKey:@"priority_segment_ids"];
        self.response_time = [coder decodeObjectForKey:@"response_time"];
        self.crash_report = [coder decodeObjectForKey:@"crash_report"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.code forKey:@"code"];
    [coder encodeObject:self.priority_rule_id forKey:@"priority_rule_id"];
    [coder encodeObject:self.priority_segment_ids forKey:@"priority_segment_ids"];
    [coder encodeObject:self.response_time forKey:@"response_time"];
    [coder encodeObject:self.crash_report forKey:@"crash_report"];
}

@end
