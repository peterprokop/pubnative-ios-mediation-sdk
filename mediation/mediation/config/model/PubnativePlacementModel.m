//
//  PubnativePlacementModel.m
//  mediation
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativePlacementModel.h"

@implementation PubnativePlacementModel

+(JSONKeyMapper *)keyMapper{
    return  [[JSONKeyMapper alloc] initWithDictionary:@{ @"delivery_rule" : @"delivery_rules"}];
}

@end
