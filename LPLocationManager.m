//
//  LPLocationManager.m
//  LightHouse
//
//  Created by Thomas Pun on 5/2/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPLocationManager.h"
#import "CLRegion+LoopPulseHelpers.h"
#import "LPDataStore+LPLocationManager.h"

@interface LPLocationManager ()
@property (readonly) NSArray *beaconRegions;
@property (readonly, retain) LPDataStore *dataStore;
@end

@implementation LPLocationManager

- (id)initWithDataStore:(LPDataStore *)dataStore
{
    self = [super init];
    if (self) {
        _dataStore = dataStore;
        self.delegate = self;
    }
    return self;
}

- (NSArray *)beaconRegions
{
    // Estimote
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                      identifier:@"LoopPulse-Generic"];

    // iTouch
    NSUUID *uuid2 = [[NSUUID alloc] initWithUUIDString:@"74278BDA-B644-4520-8F0C-720EAF059935"];
    CLBeaconRegion *beaconRegion2 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid2
                                                                       identifier:@"LoopPulse-Generic2"];

    // xBeacon
    NSUUID *uuid3 = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    CLBeaconRegion *beaconRegion3 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid3
                                                                       identifier:@"LoopPulse-Generic3"];

    return @[beaconRegion, beaconRegion2, beaconRegion3];
}

- (NSArray *)ignoredProximity
{
    return @[@(CLProximityUnknown), @(CLProximityFar), @(CLProximityNear)];
}

- (void)startMonitoringForAllRegions
{
    for (CLBeaconRegion *region in self.beaconRegions) {
        [self startMonitoringForRegion:region];
    }
}

- (void)stopMonitoringForAllRegions
{
    for (CLBeaconRegion *region in self.monitoredRegions) {
        [self stopMonitoringForRegion:region];
    }
}

- (void)startRangingBeaconsInAllRegions
{
    for (CLBeaconRegion *region in self.beaconRegions) {
        [self startRangingBeaconsInRegion:region];
    }
}

- (void)stopRangingBeaconsInAllRegions
{
    for (CLBeaconRegion *region in self.rangedRegions) {
        [self stopRangingBeaconsInRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region isLoopPulseBeaconRegion]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        if (beaconRegion.major && beaconRegion.minor) {
            [self.dataStore logEvent:@"didEnterRegion" withBeaconRegion:beaconRegion atTime:[NSDate date]];
        } else {
            [self startRangingBeaconsInRegion:beaconRegion];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region isLoopPulseBeaconRegion]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        if (beaconRegion.major && beaconRegion.minor) {
            [self.dataStore logEvent:@"didExitRegion" withBeaconRegion:beaconRegion atTime:[NSDate date]];
            [self stopRangingBeaconsInRegion:beaconRegion];
            [self stopMonitoringForRegion:beaconRegion];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if ([region isLoopPulseBeaconRegion]) {
        if ([beacons count]==0) {
            [manager stopRangingBeaconsInRegion:region];
            return;
        }

        for (CLBeacon *beacon in beacons) {
            // Ignore beacons with unknown proximity
            if ([[self ignoredProximity] containsObject:@(beacon.proximity)]) {
                continue;
            }

            [self.dataStore logEvent:@"didRangeBeacons" withBeacon:beacon atTime:[NSDate date]];

            // Monitor specific beacons
            NSString *identifier = [NSString stringWithFormat:@"LoopPulse-%@:%@", beacon.major, beacon.minor];
            CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:region.proximityUUID
                                                                                   major:[beacon.major integerValue]
                                                                                   minor:[beacon.minor integerValue]
                                                                              identifier:identifier];
            if (![self.monitoredRegions containsObject:beaconRegion]) {
                [self startMonitoringForRegion:beaconRegion];
            }
        }
    }
}


#pragma mark - Debug Helpers

- (void)notifyLocally:(NSString *)string
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = string;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (NSString *)colorForMajor:(NSNumber *)major
{
    if ([major isEqualToNumber:@28364]) {
        return @"Blue";
    } else if ([major isEqualToNumber:@54330]) {
        return @"Green";
    } else if ([major isEqualToNumber:@100]) {
        return @"Red";
    } else if ([major isEqualToNumber:@10]) {
        return @"White";
    }
    return @"Unknown";
}


@end
