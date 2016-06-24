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

static PubnativeInsightsManager* _sharedInstance;

@interface PubnativeInsightsManager () <NSURLConnectionDataDelegate>

@property (nonatomic, strong)NSMutableArray *requestQueue;
@property (nonatomic, assign)BOOL           idle;

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

+ (instancetype)sharedInstance {
    static PubnativeInsightsManager *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PubnativeInsightsManager alloc] init];
    });
    return _sharedInstance;
}

+ (void)configWithAppToken:(NSString*)appToken
                  delegate:(NSObject<PubnativeInsightsManagerDelegate>*)delegate
{
    // Drop the call if no completion handler specified
    if(delegate){
        if(appToken && [appToken length] > 0){
            PubnativeInsightRequestModel *requestModel = [[PubnativeInsightRequestModel alloc] init];
            requestModel.appToken = appToken;
            requestModel.delegate = delegate;
            [PubnativeInsightsManager enqueueRequestModel:requestModel];
            [PubnativeInsightsManager doNextRequest];
        } else {
            NSLog(@"PubnativeInsightsManager - invalid app token");
            [PubnativeInsightsManager invokeDidFinishWithModel:nil
                                                    delegate:delegate];
        }
    } else {
        NSLog(@"PubnativeInsightsManager - delegate not specified, dropping the call");
    }
}

+ (void)doNextRequest
{
    if([PubnativeInsightsManager sharedInstance].idle){
        PubnativeInsightRequestModel *requestModel = [PubnativeInsightsManager dequeueRequestDelegate];
        if(requestModel){
            [PubnativeInsightsManager sharedInstance].idle = NO;
            [PubnativeInsightsManager sendRequest:requestModel withBaseUrl:@""];
        }
    }
}

+ (void)sendRequest:(PubnativeInsightRequestModel *) model withBaseUrl:(NSString *) baseUrl
{
    NSString *requestURL = [NSString stringWithFormat:@"%@?%@=%@", baseUrl, @"", model.appToken];
    __block PubnativeInsightRequestModel *requestModelBlock = model;
    [PubnativeHttpRequest requestWithURL:requestURL andCompletionHandler:^(NSString *result, NSError *error) {
        if (error) {
            [PubnativeInsightsManager invokeDidFinishWithModel:nil delegate:requestModelBlock.delegate];
        } else {
            NSData *jsonData = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSError *dataError;
            NSDictionary *jsonDictonary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&dataError];
            
            if (dataError) {
                NSLog(@"PubnativeInsightsManager - data error: %@", dataError);
                [PubnativeInsightsManager invokeDidFinishWithModel:nil delegate:requestModelBlock.delegate];
            } else {
                PubnativeInsightApiResponseModel *apiResponse = [PubnativeInsightApiResponseModel modelWithDictionary:jsonDictonary];
                if(apiResponse) {
                    if([apiResponse isSuccess]) {
                        NSLog(@"PubnativeInsightsManager - succes");
                        //[PubnativeInsightsManager invokeDidFinishWithModel:requestModelBlock.dataModel delegate:requestModelBlock.delegate];
                    } else {
                        NSLog(@"PubnativeInsightsManager - server error: %@", apiResponse.error_message);
                        [PubnativeInsightsManager invokeDidFinishWithModel:nil delegate:requestModelBlock.delegate];
                    }
                } else {
                    NSLog(@"PubnativeInsightsManager - parsing error");
                    [PubnativeInsightsManager invokeDidFinishWithModel:nil delegate:requestModelBlock.delegate];
                }
            }
        }
    }];
}

#pragma mark - QUEUE -
+ (void)enqueueRequestModel:(PubnativeInsightRequestModel *)request
{
    if(request &&
       request.delegate &&
       request.appToken && [request.appToken length] > 0)
    {
        if(![PubnativeInsightsManager sharedInstance].requestQueue){
            [PubnativeInsightsManager sharedInstance].requestQueue = [[NSMutableArray alloc] init];
        }
        [[PubnativeInsightsManager sharedInstance].requestQueue addObject:request];
    }
}

+ (PubnativeInsightRequestModel*)dequeueRequestDelegate
{
    PubnativeInsightRequestModel *result = nil;
    
    if([PubnativeInsightsManager sharedInstance].requestQueue &&
       [[PubnativeInsightsManager sharedInstance].requestQueue count] > 0){
        
        result = [[PubnativeInsightsManager sharedInstance].requestQueue objectAtIndex:0];
        [[PubnativeInsightsManager sharedInstance].requestQueue removeObjectAtIndex:0];
    }
    return result;
}

#pragma mark Callback helpers

+ (void)invokeDidFinishWithModel:(PubnativeInsightsManager*)model
                        delegate:(NSObject<PubnativeInsightsManagerDelegate>*)delegate
{
    if(delegate &&
       [delegate respondsToSelector:@selector(configDidFinishWithModel:)]){
        [delegate configDidFinishWithModel:model];
    }
    [PubnativeInsightsManager sharedInstance].idle = YES;
    [PubnativeInsightsManager doNextRequest];
}

@end

