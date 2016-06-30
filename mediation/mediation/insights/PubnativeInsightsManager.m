//
//  PubnativeInsightsManager.m
//  mediation
//
//  Created by Alvarlega on 23/06/16.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import "PubnativeInsightsManager.h"
#import "PubnativeInsightRequestModel.h"
#import "PubnativeInsightApiResponseModel.h"
#import "PubnativeHttpRequest.h"
#import "PubnativeConfigManager.h"

NSString * const kPubnativeInsightsManagerQueueKey          = @"PubnativeInsightsManager.queue.key";
NSString * const kPubnativeInsightsManagerFailedQueueKey    = @"PubnativeInsightsManager.failedQueue.key";

@interface PubnativeInsightsManager () <NSURLConnectionDataDelegate>

@property (nonatomic, assign)BOOL idle;

@end

@implementation PubnativeInsightsManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.idle = YES;
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static PubnativeInsightsManager *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PubnativeInsightsManager alloc] init];
    });
    return _sharedInstance;
}

+ (void)trackDataWithUrl:(NSString*)url
              parameters:(NSDictionary<NSString*,NSString*>*)parameters
                    data:(PubnativeInsightDataModel*)data
{
    if (data && url && url.length > 0) {
        
        PubnativeInsightRequestModel *model = [[PubnativeInsightRequestModel alloc] init];
        model.data.generated_at = [NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970]*1000000)];
        model.data = data;
        model.params = parameters;
        model.url = url;
        
        NSMutableArray *failedQueue = [PubnativeInsightsManager queueForKey:kPubnativeInsightsManagerFailedQueueKey];
        for (PubnativeInsightRequestModel *failedModel in failedQueue) {
            [PubnativeInsightsManager enqueueRequestModel:failedModel];
        }
        [PubnativeInsightsManager setQueue:nil forKey:kPubnativeInsightsManagerFailedQueueKey];
        
        [PubnativeInsightsManager enqueueRequestModel:model];
        [PubnativeInsightsManager doNextRequest];

    } else {
        NSLog(@"PubnativeInsightsManager - data or url to track are nil");
    }
}

+ (void)doNextRequest
{
    if([PubnativeInsightsManager sharedInstance].idle){
        [PubnativeInsightsManager sharedInstance].idle = NO;
        PubnativeInsightRequestModel *model = [PubnativeInsightsManager dequeueRequestModel];
        if(model){
            [PubnativeInsightsManager sendRequest:model];
        } else {
            [PubnativeInsightsManager sharedInstance].idle = YES;
        }
    }
}

+ (void)sendRequest:(PubnativeInsightRequestModel *) model
{
    NSString *url = [PubnativeInsightsManager requestUrlWithModel:model];
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:[model.data toDictionary]
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    
    if(error){
        NSLog(@"PubnativeInsightsManager - request model parsing error: %@", error);
    } else {
        __block PubnativeInsightRequestModel *requestModelBlock = model;
        [PubnativeHttpRequest requestWithURL:url httpBody:json andCompletionHandler:^(NSString *result, NSError *error) {
            if (error) {
                NSLog(@"PubnativeInsightsManager - request error: %@", error.localizedDescription);
                [PubnativeInsightsManager enqueueFailedRequestModel:requestModelBlock];
            } else {
                NSData *jsonData = [result dataUsingEncoding:NSUTF8StringEncoding];
                NSError *parseError;
                NSDictionary *jsonDictonary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                              options:NSJSONReadingMutableContainers
                                                                                error:&parseError];
                if(parseError){
                    // TODO: ADD EXTRAS TO INSIGHT
                    NSLog(@"PubnativeInsightsManager - tracking response parsing error: %@", result);
                } else {
                    PubnativeInsightApiResponseModel *apiResponse = [PubnativeInsightApiResponseModel modelWithDictionary:jsonDictonary];
                    if([apiResponse isSuccess]) {
                        NSLog(@"PubnativeInsightsManager - tracking %@ success: %@", url, result);
                    } else {
                        NSLog(@"PubnativeInsightsManager - tracking failed: %@", apiResponse.error_message);
                        [PubnativeInsightsManager enqueueFailedRequestModel:requestModelBlock];
                    }
                }
            }
            [PubnativeInsightsManager sharedInstance].idle = YES;
            [PubnativeInsightsManager doNextRequest];
        }];
    }
}

+ (NSString*)requestUrlWithModel:(PubnativeInsightRequestModel*)model
{
    NSString *result = nil;
    if (model) {
        NSURLComponents *components = [[NSURLComponents alloc] initWithString:model.url];
        if(model.params){
            
            NSMutableArray *queryItems = [NSMutableArray array];
            for (NSString *key in model.params) {
                
                NSString *value = model.params[key];
                NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:value];
                [queryItems addObject:item];
            }
            [components setQueryItems:queryItems];
        }
        result = [components.URL absoluteString];
    }
    return result;
}

#pragma mark - QUEUE -

+ (void)enqueueRequestModel:(PubnativeInsightRequestModel *)request
{
    if(request){
        NSMutableArray *queue = [PubnativeInsightsManager queueForKey:kPubnativeInsightsManagerQueueKey];
        [queue addObject:[request toDictionary]];
        [PubnativeInsightsManager setQueue:queue forKey:kPubnativeInsightsManagerQueueKey];
    }
}

+ (PubnativeInsightRequestModel*)dequeueRequestModel
{
    PubnativeInsightRequestModel *result = nil;
    NSMutableArray *queue = [PubnativeInsightsManager queueForKey:kPubnativeInsightsManagerQueueKey];
    if (queue.count > 0) {
        result = [[PubnativeInsightRequestModel alloc] initWithDictionary:queue[0]];
        [queue removeObjectAtIndex:0];
        [PubnativeInsightsManager setQueue:queue forKey:kPubnativeInsightsManagerQueueKey];
    }
    return result;
}

+ (void)enqueueFailedRequestModel:(PubnativeInsightRequestModel *)request
{
    if(request){
        request.data.retry = [NSNumber numberWithInteger:[request.data.retry integerValue] + 1];
        NSMutableArray *queue = [PubnativeInsightsManager queueForKey:kPubnativeInsightsManagerFailedQueueKey];
        [queue addObject:[request toDictionary]];
        [PubnativeInsightsManager setQueue:queue forKey:kPubnativeInsightsManagerFailedQueueKey];
    }
}

#pragma mark NSUserDefaults

+ (NSMutableArray*)queueForKey:(NSString*)key
{
    NSArray *queue = [[NSUserDefaults standardUserDefaults] objectForKey:kPubnativeInsightsManagerQueueKey];
    NSMutableArray *result = [NSMutableArray array];

    if(queue){
        result = [queue mutableCopy];
    }
    return result;
}

+ (void)setQueue:(NSArray*)queue forKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setObject:queue
                                              forKey:kPubnativeInsightsManagerQueueKey];
}

@end

