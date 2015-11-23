//
//  PubnativeConfigAPIResponseModel.h
//  mediation
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "PubnativeConfigModel.h"

@interface PubnativeConfigAPIResponseModel : JSONModel

@property (nonatomic, strong) NSString                          *status;
@property (nonatomic, strong) NSString<Optional>                *error_message;
@property (nonatomic, strong) PubnativeConfigModel<Optional>    *config;

+ (instancetype)parseDictionary:(NSDictionary*)dictionary error:(NSError*)error;
- (BOOL)success;

@end
