//
//  PubnativeConfigGlobalsModel.h
//  mediation
//
//  Created by David Martin on 28/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface PubnativeConfigGlobalsModel : JSONModel

@property (nonatomic, assign) NSNumber  *refresh;
@property (nonatomic, assign) NSNumber  *impression_timeout;
@property (nonatomic, strong) NSString  *config_url;
@property (nonatomic, strong) NSString  *impression_beacon;
@property (nonatomic, strong) NSString  *click_beacon;
@property (nonatomic, strong) NSString  *request_beacon;

@end
