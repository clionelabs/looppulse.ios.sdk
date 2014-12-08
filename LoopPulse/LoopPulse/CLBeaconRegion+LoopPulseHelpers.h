//
//  CLBeaconRegion+LoopPulseHelpers.h
//  LoopPulse
//
//  Created by Thomas Pun on 8/13/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLBeaconRegion (LoopPulseHelpers)
- (NSString *)key;
- (NSString *)description;

- (instancetype)initGenericWithProximityUUID:(NSUUID *)proximityUUID major:(CLBeaconMajorValue)major;
- (instancetype)initSpecificWithProximityUUID:(NSUUID *)proximityUUID major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor;
@end
