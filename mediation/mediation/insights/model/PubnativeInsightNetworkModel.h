//
//  PubnativeInsightNetworkModel.h
//  mediation
//
//  Created by Alvarlega on 27/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubnativeJSONModel.h"
#import "PubnativeInsightCrashModel.h"

@interface PubnativeInsightNetworkModel : PubnativeJSONModel<NSCoding>

//public String                     code;
//public int                        priority_rule_id;
//public List<Integer>              priority_segment_ids;
//public long                       response_time;
//public PubnativeInsightCrashModel crash_report;

@property (nonatomic, strong) NSString                      *code;
@property (nonatomic, strong) NSNumber                      *priority_rule_id;
@property (nonatomic, strong) NSArray<NSNumber*>            *priority_segment_ids;
@property (nonatomic, strong) NSNumber                      *response_time;
@property (nonatomic, strong) PubnativeInsightCrashModel    *crash_report;

@end
