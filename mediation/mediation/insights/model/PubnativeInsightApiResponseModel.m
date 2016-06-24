//
//  PubnativeInsightApiResponseModel.m
//  mediation
//
//  Created by Alvarlega on 23/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PubnativeInsightApiResponseModel.h"

NSString * const kAPIStatusSuccess         = @"ok";
NSString * const kAPIStatusError           = @"error";

@implementation PubnativeInsightApiResponseModel

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
{
    self = [super initWithDictionary:dictionary];
    
    if(self) {
        self.status = dictionary[@"status"];
        self.error_message = dictionary[@"error_message"];
    }
    return self;
}

- (BOOL)isSuccess
{
    return [kAPIStatusSuccess isEqualToString:[self.status lowercaseString]];
}

@end
