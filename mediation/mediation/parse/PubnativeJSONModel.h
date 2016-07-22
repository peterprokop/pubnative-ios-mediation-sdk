//
//  PubnativeJSONModel.h
//  mediation
//
//  Created by David Martin on 05/04/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PubnativeJSONModel : NSObject

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

+ (instancetype)modelWithDictionary:(NSDictionary*)dictionary;
+ (NSDictionary*)parseDictionaryValues:(NSDictionary*)dictionary;
+ (NSArray*)parseArrayValues:(NSArray*)array;

- (NSDictionary*)toDictionary;

@end
