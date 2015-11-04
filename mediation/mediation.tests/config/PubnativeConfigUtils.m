//
//  PubnativeConfigUtils.m
//  mediation
//
//  Created by David Martin on 28/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeConfigUtils.h"

@implementation PubnativeConfigUtils

+ (NSString*)getStringFromJSONFile:(NSString*)file
{
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    return [NSString stringWithContentsOfFile:[testBundle pathForResource:file ofType:@"json"]
                                 usedEncoding:nil
                                        error:nil];
}


+ (NSDictionary*)getDictionaryFromJSONFile:(NSString*)file
{
    NSString *jsonString = [PubnativeConfigUtils getStringFromJSONFile:file];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return jsonDictionary;
}

+ (PubnativeConfigModel*)getModelFromJSONFile:(NSString*)file
{
    NSDictionary *jsonModelDictionary = [PubnativeConfigUtils getDictionaryFromJSONFile:file];
    return [[PubnativeConfigModel alloc] initWithDictionary:jsonModelDictionary error:nil];
}

@end
