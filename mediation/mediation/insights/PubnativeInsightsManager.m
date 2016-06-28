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

NSString * const kPubnativeInsightsManagerQueueKey = @"PubnativeInsightsManager.queue.key";
NSString * const kPubnativeInsightsManagerFailedQueueKey = @"PubnativeInsightsManager.failedQueue.key";

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
        model.data = data;
        model.params = parameters;
        model.url = url;
        
        // TODO: Enqueue all failed items
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
        PubnativeInsightRequestModel *model = [PubnativeInsightsManager dequeueRequestDelegate];
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
    
    __block PubnativeInsightRequestModel *requestModelBlock = model;
    [PubnativeHttpRequest requestWithURL:url andCompletionHandler:^(NSString *result, NSError *error) {
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
                NSLog(@"");
                // TODO: ADD EXTRAS TO INSIGHT
                NSLog(@"PubnativeInsightsManager - tracking response parsing error: %@", result);
                [PubnativeInsightsManager enqueueFailedRequestModel:requestModelBlock];
            } else {
                
                PubnativeInsightApiResponseModel *apiResponse = [PubnativeInsightApiResponseModel modelWithDictionary:jsonDictonary];
                if([apiResponse isSuccess]) {
                    NSLog(@"PubnativeInsightsManager - tracking success: %@", result);
                } else {
                    NSLog(@"PubnativeInsightsManager - tracking failed: %@", apiResponse.error_message);
                    [PubnativeInsightsManager enqueueFailedRequestModel:requestModelBlock];
                }
            }
        }
        [PubnativeInsightsManager doNextRequest];
    }];
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
        [queue addObject:request];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:queue];
        [PubnativeInsightsManager setQueue:data forKey:kPubnativeInsightsManagerQueueKey];
    }
}

+ (PubnativeInsightRequestModel*)dequeueRequestDelegate
{
    PubnativeInsightRequestModel *result = nil;
    NSMutableArray *queue = [PubnativeInsightsManager queueForKey:kPubnativeInsightsManagerQueueKey];
    if (queue.count > 0) {
        result = queue[0];
        [queue removeObjectAtIndex:0];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:queue];
        [PubnativeInsightsManager setQueue:data forKey:kPubnativeInsightsManagerQueueKey];
    }
    return result;
}

+ (void)enqueueFailedRequestModel:(PubnativeInsightRequestModel *)request
{
    if(request){
        request.data.retry = [NSNumber numberWithInteger:[request.data.retry integerValue] + 1];
        NSMutableArray *queue = [PubnativeInsightsManager queueForKey:kPubnativeInsightsManagerFailedQueueKey];
        [queue addObject:request];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:queue];
        [PubnativeInsightsManager setQueue:data forKey:kPubnativeInsightsManagerFailedQueueKey];
    }
}

#pragma mark NSUserDefaults

+ (NSMutableArray*)queueForKey:(NSString*)key
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kPubnativeInsightsManagerQueueKey];
    NSArray *storedQueue = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSMutableArray *result = [storedQueue mutableCopy];
    if(result == nil){
        result = [NSMutableArray array];
    }
    return result;
}

+ (void)setQueue:(NSData*)queue forKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setObject:queue
                                              forKey:kPubnativeInsightsManagerQueueKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

