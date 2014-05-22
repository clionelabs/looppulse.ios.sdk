//
//  LPDataStore+LPLocationManager.h
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPDataStore.h"
#import <CoreLocation/CoreLocation.h>

@interface LPDataStore (LPLocationManager)

// Location
- (void)logEvent:(NSString *)event withBeacon:(CLBeacon *)beacon atTime:(NSDate *)createdAt;
- (void)logEvent:(NSString *)event withBeaconRegion:(CLBeaconRegion *)region atTime:(NSDate *)createdAt;

@end
