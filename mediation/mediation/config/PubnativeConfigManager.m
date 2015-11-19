//
//  PubnativeConfigManager.m
//  mediation
//
//  Created by David Martin on 06/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeConfigManager.h"
#import <JSONModel/JSONApi.h>
#import "PubnativeConfigAPIResponseModel.h"
#import "PubnativeConfigRequestModel.h"

static PubnativeConfigManager* _sharedInstance;

NSString * const kDefaultConfigURL                  = @"http://ml.pubnative.net/ml/v1/config";
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
            NSError *error = [NSError errorWithDomain:@"PubnativeConfigManager - wrong app token" code:0 userInfo:nil];
            [PubnativeConfigManager invokeDidFailWithError:error
                                                  delegate:delegate];
        }
    }
}

+ (void)doNextRequest
{
    if([PubnativeConfigManager sharedInstance].idle){
        [PubnativeConfigManager sharedInstance].idle = NO;
        PubnativeConfigRequestModel *requestModel = [PubnativeConfigManager dequeueRequestDelegate];
        if(requestModel){
            [PubnativeConfigManager getNextConfigWithModel:requestModel];
        } else {
            [PubnativeConfigManager sharedInstance].idle = YES;
        }
    }
}

+ (void)getNextConfigWithModel:(PubnativeConfigRequestModel*)requestModel
{
    if(requestModel){
        if([PubnativeConfigManager storedConfigNeedsUpdateWithAppToken:requestModel.appToken]){
            // Download
            [PubnativeConfigManager downloadConfigWithRequest:requestModel];
        } else {
            // Serve stored config
            [PubnativeConfigManager serveStoredConfigWithRequest:requestModel];
        }
    }
}

+ (BOOL)storedConfigNeedsUpdateWithAppToken:(NSString*)appToken
{
    BOOL result = NO;
    
    PubnativeConfigModel *storedModel = [PubnativeConfigManager getStoredConfig];
    if(storedModel){
       
        NSString *storedAppToken = [PubnativeConfigManager getStoredAppToken];
        if(storedAppToken && [storedAppToken isEqualToString:appToken]){
    
            NSTimeInterval storedTimestamp = [PubnativeConfigManager getStoredTimestamp];
            
            if(storedTimestamp &&
               storedModel.globals &&
               storedModel.globals.refresh &&
               storedModel.globals.refresh > 0) {
                
                NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
                NSTimeInterval elapsedTime = currentTimestamp - storedTimestamp;
                
                NSTimeInterval refreshSeconds = [storedModel.globals.refresh intValue] * 60;
                if(elapsedTime > refreshSeconds){
                    // Config overdue
                    result = YES;
                }
                
            } else {
                // There was no previous stored timestamp
                result = YES;
            }
            
            
        } else {
            // Config app token is different than the one provided
            result = YES;
        }
        
    } else {
        // No config stored, need to download a new one
        result = YES;
    }
    
    return result;
}

+ (void)serveStoredConfigWithRequest:(PubnativeConfigRequestModel*)requestModel
{
    PubnativeConfigModel *storedConfig = [PubnativeConfigManager getStoredConfig];
    if(storedConfig){
        [PubnativeConfigManager invokeDidFinishWithModel:storedConfig
                                                delegate:requestModel.delegate];
    } else {
        NSError *storedConfigError = [NSError errorWithDomain:@"PubnativeConfigManager - error serving stored config"
                                                         code:0
                                                     userInfo:nil];
        [PubnativeConfigManager invokeDidFailWithError:storedConfigError
                                              delegate:requestModel.delegate];
    }
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

+ (void)downloadConfigWithRequest:(PubnativeConfigRequestModel*)requestModel
{
    // Handle only when correct request data
    if(requestModel){
        
        [JSONAPI setAPIBaseURLWithString:kDefaultConfigURL];
        [JSONAPI getWithPath:@""
                   andParams:@{kAppTokenURLParameter : requestModel.appToken}
                  completion:^(id json, JSONModelError *err)
        {
            [PubnativeConfigManager processDownloadResponseWithRequest:requestModel
                                                              withJson:json
                                                                 error:err];
        }];
    }
}

+ (void)processDownloadResponseWithRequest:(PubnativeConfigRequestModel*)requestModel
                                  withJson:(id)json
                                     error:(JSONModelError*)error
{
    if(error){
        // ERROR: Connection error
        [PubnativeConfigManager invokeDidFailWithError:error
                                              delegate:requestModel.delegate];
    } else {
        
        if(json){
            
            NSError *parsingError = nil;
            PubnativeConfigAPIResponseModel *responseModel = [PubnativeConfigAPIResponseModel parseDictionary:json
                                                                                                        error:&parsingError];
            if(parsingError){
                // ERROR: Parsing error
                [PubnativeConfigManager invokeDidFailWithError:parsingError
                                                      delegate:requestModel.delegate];
            } else {
                if([responseModel success]){
                    
                    // SUCCESS
                    [PubnativeConfigManager updateStoredConfig:responseModel.config
                                                  withAppToken:requestModel.appToken];
                    [PubnativeConfigManager serveStoredConfigWithRequest:requestModel];
                    
                } else {
                    
                    // ERROR: Server returned error
                    NSString *errorString = [NSString stringWithFormat:@"Pubnative - Server error: %@", responseModel.error_message];
                    NSError *serverError = [NSError errorWithDomain:errorString
                                                               code:0
                                                           userInfo:nil];
                    [PubnativeConfigManager invokeDidFailWithError:serverError
                                                          delegate:requestModel.delegate];
                }
            }
        } else {
            // ERROR: Response empty
            NSError *responseError = [NSError errorWithDomain:@"Pubnative - error downloading config, empty response"
                                                         code:0
                                                     userInfo:nil];
            [PubnativeConfigManager invokeDidFailWithError:responseError
                                                  delegate:requestModel.delegate];
        }   
    }
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

#pragma mark - Callback -

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

+ (void)invokeDidFailWithError:(NSError*)error
                      delegate:(NSObject<PubnativeConfigManagerDelegate>*)delegate
{
    if(delegate &&
       [delegate respondsToSelector:@selector(configDidFailWithError:)]){
        [delegate configDidFailWithError:error];
    }
    [PubnativeConfigManager sharedInstance].idle = YES;
    [PubnativeConfigManager doNextRequest];
}

#pragma mark - NSUserDefaults -

#pragma mark Timestamp

+ (void)setStoredTimestamp:(NSTimeInterval)timestamp
{
    if(timestamp > 0){
        [[NSUserDefaults standardUserDefaults] setDouble:timestamp forKey:kUserDefaultsStoredTimestampKey];
    } else {
        //0 has been set as default value
        [[NSUserDefaults standardUserDefaults] setDouble:0 forKey:kUserDefaultsStoredTimestampKey];
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
        NSDictionary *dictionary = [model toDictionary];
        [[NSUserDefaults standardUserDefaults] setObject:dictionary forKey:kUserDefaultsStoredConfigKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsStoredConfigKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (PubnativeConfigModel*)getStoredConfig
{
    NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsStoredConfigKey];
    return [[PubnativeConfigModel alloc] initWithDictionary:dictionary error:nil];
}

@end
