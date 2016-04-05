//
//  PubnativeNetworkModel.h
//  mediation
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PubnativeNetworkModel : NSObject

@property (nonatomic, strong) NSDictionary  *params;
@property (nonatomic, strong) NSString      *adapter;
@property (nonatomic, strong) NSNumber      *timeout;
@property (nonatomic, strong) NSNumber      *crash_report;

+ (instancetype)modelWithDictionary:(NSDictionary*)dictionary;
- (BOOL)isCrashReportEnabled;

@end
