//
//  PubnativePriorityRulesModel.h
//  mediation
//
//  Created by Mohit on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "JSONModel.h"

@protocol PubnativePriorityRulesModel <NSObject>

@end

@interface PubnativePriorityRulesModel : JSONModel

@property(nonatomic,strong)NSNumber         *id;
@property(nonatomic,strong)NSString         *network_code;
@property(nonatomic,strong)NSDictionary     *params;

@end
