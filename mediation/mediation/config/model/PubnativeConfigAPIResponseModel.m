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

+ (instancetype)modelWithDictionary:(NSDictionary*)dictionary
{
    PubnativeConfigAPIResponseModel *result = nil;
    
    if(dictionary) {
    
        result = [[PubnativeConfigAPIResponseModel alloc] init];
        
        result.status = dictionary[@"status"];
        result.error_message = dictionary[@"error_message"];
        result.config = [PubnativeConfigModel modelWithDictionary:dictionary[@"config"]];
    }
    
    return result;
}

- (BOOL)isSuccess
{
    return [kAPIStatusSuccessValue isEqualToString:[self.status lowercaseString]];
}

@end
