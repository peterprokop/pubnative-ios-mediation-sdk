//
//  PubnativeConfigUtils.h
//  mediation
//
//  Created by David Martin on 28/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubnativeConfigModel.h"

@interface PubnativeConfigUtils : NSObject

+ (NSString*)getStringFromJSONFile:(NSString*)file;
+ (NSDictionary*)getDictionaryFromJSONFile:(NSString*)file;
+ (PubnativeConfigModel*)getModelFromJSONFile:(NSString*)file;

@end
