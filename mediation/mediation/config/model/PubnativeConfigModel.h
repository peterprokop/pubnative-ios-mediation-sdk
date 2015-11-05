//
//  PubnativeConfigModel.h
//  mediation
//
//  Created by David Martin on 22/10/15.
//  Copyright © 2015 pubnative. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "PubnativeConfigGlobalsModel.h"
#import "PubnativeNetworkModel.h"
#import "PubnativePlacementModel.h"

@interface PubnativeConfigModel : JSONModel

@property (nonatomic, strong) PubnativeConfigGlobalsModel   *globals;
@property (nonatomic, strong) NSDictionary                  *networks;
@property (nonatomic, strong) NSDictionary                  *placements;

- (BOOL)isEmpty;

@end
