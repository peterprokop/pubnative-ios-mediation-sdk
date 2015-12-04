//
//  PubnativeLibraryNetworkAdapter.m
//  mediation
//
//  Created by Mohit on 17/11/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import "PubnativeLibraryNetworkAdapter.h"
#import "PubnativeLibraryAdModel.h"
#import "PNAdRequest.h"
#import "PNNativeAdModel.h"

NSString * const kAppTokenKey = @"app_token";

@interface PubnativeNetworkAdapter (Private)

- (void)invokeDidFail:(NSError*)error;
- (void)invokeDidLoad:(PubnativeAdModel*)ad;

@end

@interface PubnativeLibraryNetworkAdapter ()

@property (strong, nonatomic) PNAdRequest *request;

@end

@implementation PubnativeLibraryNetworkAdapter

- (void)doRequest
{
    if (self.params) {
        NSString *appToken = [self.params valueForKey:kAppTokenKey];
        
        if (appToken && [appToken length] > 0) {
            [self createRequestWithAppToken:appToken];
        } else {
            NSError *error = [NSError errorWithDomain:@"PubnativeLibraryNetworkAdapter.doRequest - Invalid apptoken provided"
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        }
        
    } else {
        NSError *error = [NSError errorWithDomain:@"PubnativeLibraryNetworkAdapter.doRequest - apptoken not avaliable"
                                             code:0
                                         userInfo:nil];
        [self invokeDidFail:error];
    }
}

- (void)createRequestWithAppToken:(NSString*)appToken
{
    PNAdRequestParameters *parameters = [PNAdRequestParameters requestParameters];
    parameters.app_token = appToken;
    
    __weak typeof(self) weakSelf = self;
    self.request = [PNAdRequest request:PNAdRequest_Native
                         withParameters:parameters
                          andCompletion:^(NSArray *ads, NSError *error) {
                              
                              NSLog(@"PubnativeLibraryNetworkAdapter.createRequestWithAppToken - Request end");
                              
                              if(error) {
                                  [weakSelf invokeDidFail:error];
                              }
                              else if ([ads count]>0) {
                                  
                                  PubnativeLibraryAdModel *wrapModel = [[PubnativeLibraryAdModel alloc] initWithNativeAd:[ads firstObject]];
                                  [weakSelf invokeDidLoad:wrapModel];
                              }
                          }];
    
    [self.request startRequest];
}

@end
