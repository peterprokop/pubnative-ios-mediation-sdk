//
//  PubnativeNetworkModel.h
//  mediation
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface PubnativeNetworkModel : JSONModel

@property (nonatomic, strong) NSDictionary  *params;
@property (nonatomic, strong) NSString      *adapter;
@property (nonatomic, strong) NSNumber      *timeout;
@property (nonatomic, assign) BOOL          *crash_report;

@end
