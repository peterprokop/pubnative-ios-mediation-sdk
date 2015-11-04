//
//  PubnativeConfigAPIResponseModel.m
//  mediation
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeConfigAPIResponseModel.h"

NSString * const kAPIStatusSuccessValue         = @"ok";
NSString * const kAPIStatusErrorValue           = @"error";

@implementation PubnativeConfigAPIResponseModel

- (BOOL)success
{
    return [kAPIStatusSuccessValue isEqualToString:[self.status lowercaseString]];
}

@end
