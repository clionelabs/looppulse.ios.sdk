//
//  LPLocationManager.h
//  LightHouse
//
//  Created by Thomas Pun on 5/2/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "LPUser.h"

@interface LPLocationManager : CLLocationManager <CLLocationManagerDelegate>
- (id)initWithToken:(NSString *)token andUser:(LPUser *)user;
- (void)startMonitoringForAllRegions;
- (void)stopMonitoringForAllRegions;
- (void)startRangingBeaconsInAllRegions;
- (void)stopRangingBeaconsInAllRegions;
@end
