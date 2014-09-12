//
//  LPLocationManager.h
//  LightHouse
//
//  Created by Thomas Pun on 5/2/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "LPDataStore.h"

@interface LPLocationManager : CLLocationManager <CLLocationManagerDelegate>

- (id)initWithDataStore:(LPDataStore *)dataStore;
- (void)startMonitoringForAllRegions;
- (void)stopMonitoringForAllRegions;

@end
