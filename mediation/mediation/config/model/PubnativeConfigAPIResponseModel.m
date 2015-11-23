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

+ (instancetype)parseDictionary:(NSDictionary*)dictionary error:(NSError*)error
{
    PubnativeConfigAPIResponseModel *result = nil;
    result = [[PubnativeConfigAPIResponseModel alloc] initWithDictionary:dictionary
                                                                   error:&error];
    if(error){
        result = nil;
    }
    return result;
}

- (BOOL)success
{
    return [kAPIStatusSuccessValue isEqualToString:[self.status lowercaseString]];
}

@end
