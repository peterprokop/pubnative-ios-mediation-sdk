//
//  PubnativeDeliveryManager.h
//  mediation
//
//  Created by David Martin on 22/06/2016.
//  Copyright © 2016 pubnative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PubnativeDeliveryManager : NSObject

+ (int)currentDayCountForPlacementName:(NSString*)placementName;
+ (int)currentHourCountForPlacementName:(NSString*)placementName;

@end
