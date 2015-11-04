//
//  PubnativeConfigModel.m
//  mediation
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeConfigModel.h"

@interface PubnativeConfigModel ()

@property (nonatomic, strong) NSDictionary<Ignore> *dictionaryValue;

@end

@implementation PubnativeConfigModel

- (instancetype)initWithDictionary:(NSDictionary*)dict error:(NSError **)err
{
    self = [super initWithDictionary:dict error:err];
    
    if (self) {
        
        self.dictionaryValue = dict;
        self.networks = [self parseStringKeyDictionary:self.networks
                                        withValueClass:[PubnativeNetworkModel class]];
        self.placements = [self parseStringKeyDictionary:self.placements
                                          withValueClass:[PubnativePlacementModel class]];
    }

    return self;
}

- (NSDictionary*)parseStringKeyDictionary:(NSDictionary*)unparsedDictionary
                           withValueClass:(Class)valueClass
{
    NSMutableDictionary *result = nil;
    if(unparsedDictionary){
        for (NSString *key in [unparsedDictionary allKeys]){
            NSDictionary *valueDictionary = unparsedDictionary[key];
            NSError *error = nil;
            NSObject *valueInstance = [((JSONModel*)[valueClass alloc]) initWithDictionary:valueDictionary
                                                                                     error:&error];
            if(!error){
                if(!result){
                    result = [NSMutableDictionary dictionary];
                }
                result[key] = valueInstance;
            }
        }
    }
    return result;
}

- (BOOL)isEmpty
{
    BOOL result = YES;
    if(self.networks && [self.networks count] > 0 &&
       self.placements && [self.placements count] > 0)
    {
        result = NO;
    }
    return result;
}

- (NSDictionary *)toDictionary
{
    return self.dictionaryValue;
}

@end
