//
//  PubnativeConfigManager.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeConfigManager.h"
#import "PubnativeConfigAPIResponseModel.h"
#import "PubnativeConfigRequestModel.h"
#import "PubnativeHttpRequest.h"

static PubnativeConfigManager* _sharedInstance;

NSString * const kDefaultConfigURL                  = @"https://ml.pubnative.net/ml/v1/config";
NSString * const kAppTokenURLParameter              = @"app_token";

NSString * const kUserDefaultsStoredConfigKey       = @"net.pubnative.mediation.PubnativeConfigManager.configJSON";
NSString * const kUserDefaultsStoredAppTokenKey     = @"net.pubnative.mediation.PubnativeConfigManager.configAppToken";
NSString * const kUserDefaultsStoredTimestampKey    = @"net.pubnative.mediation.PubnativeConfigManager.configTimestamp";

@interface PubnativeConfigManager () <NSURLConnectionDataDelegate>

@property (nonatomic, strong)NSMutableArray *requestQueue;
@property (nonatomic, assign)BOOL           idle;

@end

@implementation PubnativeConfigManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.idle = YES;
    }
    return self;
}

+ (instancetype)sharedInstance {
    static PubnativeConfigManager *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PubnativeConfigManager alloc] init];
    });
    return _sharedInstance;
}

+ (void)configWithAppToken:(NSString*)appToken
                  delegate:(NSObject<PubnativeConfigManagerDelegate>*)delegate
{
    // Drop the call if no completion handler specified
    if(delegate){
        if(appToken && [appToken length] > 0){
            PubnativeConfigRequestModel *requestModel = [[PubnativeConfigRequestModel alloc] init];
            requestModel.appToken = appToken;
            requestModel.delegate = delegate;
            [PubnativeConfigManager enqueueRequestModel:requestModel];
            [PubnativeConfigManager doNextRequest];
        } else {
            NSLog(@"PubnativeConfigManager - invalid app token");
            [PubnativeConfigManager invokeDidFinishWithModel:nil
                                                  delegate:delegate];
        }
    } else {
        NSLog(@"PubnativeConfigManager - delegate not specified, dropping the call");
    }
}

+ (void)doNextRequest
{
    if([PubnativeConfigManager sharedInstance].idle){
        PubnativeConfigRequestModel *requestModel = [PubnativeConfigManager dequeueRequestDelegate];
        if(requestModel){
            [PubnativeConfigManager sharedInstance].idle = NO;
            [PubnativeConfigManager getNextConfigWithModel:requestModel];
        }
    }
}

+ (void)getNextConfigWithModel:(PubnativeConfigRequestModel*)requestModel
{
    if([PubnativeConfigManager storedConfigNeedsUpdateWithAppToken:requestModel.appToken]){
        // Download
        [PubnativeConfigManager downloadConfigWithRequest:requestModel];
    } else {
        // Serve stored config
        [PubnativeConfigManager serveStoredConfigWithRequest:requestModel];
    }
}

+ (BOOL)storedConfigNeedsUpdateWithAppToken:(NSString*)appToken
{
    BOOL result = YES;
    
    PubnativeConfigModel    *storedModel    = [PubnativeConfigManager getStoredConfig];
    NSString                *storedAppToken = [PubnativeConfigManager getStoredAppToken];
    NSTimeInterval          storedTimestamp = [PubnativeConfigManager getStoredTimestamp];
    
    if(storedModel && storedAppToken && storedTimestamp){
        NSNumber *refreshInMinutes = [storedModel.globals objectForKey:CONFIG_GLOBAL_KEY_REFRESH];
        
        if(refreshInMinutes && refreshInMinutes > 0) {
            NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval elapsedTime = currentTimestamp - storedTimestamp;
            NSTimeInterval refreshSeconds = [refreshInMinutes intValue] * 60;
            
            if(elapsedTime < refreshSeconds){
                // Config still valid
                result = NO;
            }
        }
    }
    
    return result;
}

+ (void)serveStoredConfigWithRequest:(PubnativeConfigRequestModel*)requestModel
{
    PubnativeConfigModel *storedConfig = [PubnativeConfigManager getStoredConfig];
    if(!storedConfig){
        NSLog(@"PubnativeConfigManager - error serving stored config");
    }
    [PubnativeConfigManager invokeDidFinishWithModel:storedConfig
                                            delegate:requestModel.delegate];
}

#pragma mark - QUEUE -
+ (void)enqueueRequestModel:(PubnativeConfigRequestModel*)request
{
    if(request &&
       request.delegate &&
       request.appToken && [request.appToken length] > 0)
    {
        if(![PubnativeConfigManager sharedInstance].requestQueue){
            [PubnativeConfigManager sharedInstance].requestQueue = [[NSMutableArray alloc] init];
        }
        [[PubnativeConfigManager sharedInstance].requestQueue addObject:request];
    }
}

+ (PubnativeConfigRequestModel*)dequeueRequestDelegate
{
    PubnativeConfigRequestModel *result = nil;
    
    if([PubnativeConfigManager sharedInstance].requestQueue &&
       [[PubnativeConfigManager sharedInstance].requestQueue count] > 0){
        
        result = [[PubnativeConfigManager sharedInstance].requestQueue objectAtIndex:0];
        [[PubnativeConfigManager sharedInstance].requestQueue removeObjectAtIndex:0];
    }
    return result;
}

#pragma mark - DOWNLOAD -

+ (NSString*)getConfigDownloadBaseURL
{
    NSString *result = kDefaultConfigURL;
    PubnativeConfigModel *storedConfig = [PubnativeConfigManager getStoredConfig];
    if(storedConfig && ![storedConfig isEmpty]){
        result = storedConfig.globals[CONFIG_GLOBAL_KEY_CONFIG_URL];
    }
    return result;
}


+ (void)downloadConfigWithRequest:(PubnativeConfigRequestModel*)requestModel
{
    NSString *baseURL = [PubnativeConfigManager getConfigDownloadBaseURL];
    NSString *requestURL = [NSString stringWithFormat:@"%@?%@=%@", baseURL, kAppTokenURLParameter, requestModel.appToken];
    
    __block PubnativeConfigRequestModel *requestModelBlock = requestModel;
    [PubnativeHttpRequest requestWithURL:requestURL
                    andCompletionHandler:^(NSString *result, NSError *error) {
        if(error) {
            [PubnativeConfigManager invokeDidFinishWithModel:nil delegate:requestModelBlock.delegate];
        } else {
            
            NSData *jsonData = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSError *dataError;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                           options:NSJSONReadingMutableContainers
                                                                             error:&dataError];
            if(dataError) {
                NSLog(@"PubnativeConfigManager - data error: %@", dataError);
                [PubnativeConfigManager invokeDidFinishWithModel:nil delegate:requestModelBlock.delegate];
            } else {
                PubnativeConfigAPIResponseModel *apiResponse = [PubnativeConfigAPIResponseModel modelWithDictionary:jsonDictionary];
                
                if(apiResponse) {
                    if([apiResponse isSuccess]) {
                        
                        [PubnativeConfigManager updateStoredConfig:apiResponse.config
                                                      withAppToken:requestModelBlock.appToken];
                        [PubnativeConfigManager serveStoredConfigWithRequest:requestModelBlock];
                    } else {
                        NSLog(@"PubnativeConfigManager - server error: %@", apiResponse.error_message);
                        [PubnativeConfigManager invokeDidFinishWithModel:nil delegate:requestModelBlock.delegate];
                    }
                } else {
                    NSLog(@"PubnativeConfigManager - parsing error");
                    [PubnativeConfigManager invokeDidFinishWithModel:nil delegate:requestModelBlock.delegate];
                }
            }
        }
    }];
}

+ (void)updateStoredConfig:(PubnativeConfigModel*)model
              withAppToken:(NSString*)appToken
{
    if(appToken && [appToken length] > 0 &&
       model && ![model isEmpty]){
        [PubnativeConfigManager setStoredConfig:model];
        [PubnativeConfigManager setStoredAppToken:appToken];
        [PubnativeConfigManager setStoredTimestamp:[[NSDate date] timeIntervalSince1970]];
    }
}

#pragma mark Callback helpers

+ (void)invokeDidFinishWithModel:(PubnativeConfigModel*)model
                        delegate:(NSObject<PubnativeConfigManagerDelegate>*)delegate
{
    if(delegate &&
       [delegate respondsToSelector:@selector(configDidFinishWithModel:)]){
        [delegate configDidFinishWithModel:model];
    }
    [PubnativeConfigManager sharedInstance].idle = YES;
    [PubnativeConfigManager doNextRequest];
}

#pragma mark - NSUserDefaults -

+ (BOOL)clean
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsStoredAppTokenKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsStoredConfigKey];
    [[NSUserDefaults standardUserDefaults] setDouble:0 forKey:kUserDefaultsStoredTimestampKey];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Timestamp

+ (void)setStoredTimestamp:(NSTimeInterval)timestamp
{
    if(timestamp > 0){
        [[NSUserDefaults standardUserDefaults] setDouble:timestamp forKey:kUserDefaultsStoredTimestampKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsStoredTimestampKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSTimeInterval)getStoredTimestamp
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kUserDefaultsStoredTimestampKey];
}

#pragma mark AppToken

+ (void)setStoredAppToken:(NSString*)appToken
{
    if(appToken && [appToken length] > 0){
        [[NSUserDefaults standardUserDefaults] setObject:appToken forKey:kUserDefaultsStoredAppTokenKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsStoredAppTokenKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString*)getStoredAppToken
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsStoredAppTokenKey];
}

#pragma mark Config

+ (void)setStoredConfig:(PubnativeConfigModel*)model
{
    if(model && ![model isEmpty])
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[model toDictionary]
                                                           options:0
                                                             error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:jsonData forKey:kUserDefaultsStoredConfigKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsStoredConfigKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (PubnativeConfigModel*)getStoredConfig
{
    PubnativeConfigModel *result;
    
    NSData *jsonData = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsStoredConfigKey];
    
    if(jsonData){
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                       options:NSJSONReadingMutableContainers
                                                                         error:nil];
        result = [PubnativeConfigModel modelWithDictionary:jsonDictionary];
    }
    return result;
}

@end
