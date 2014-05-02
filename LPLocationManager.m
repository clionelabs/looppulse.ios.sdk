//
//  LPLocationManager.m
//  LightHouse
//
//  Created by Thomas Pun on 5/2/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPLocationManager.h"

@interface LPLocationManager ()
@property (readonly) NSArray *beaconRegions;
@end

@implementation LPLocationManager

- (NSArray *)beaconRegions
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"LoopPulse-Generic"];
    return @[beaconRegion];
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

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if ([region.identifier hasPrefix:@"LoopPulse"]) {
        if ([region isKindOfClass:[CLBeaconRegion class]]) {
            CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
            if (state==CLRegionStateInside) {
                [self startRangingBeaconsInRegion:beaconRegion];
            }
            else if (state==CLRegionStateOutside) {
                [self stopRangingBeaconsInRegion:beaconRegion];
            }
        }
    }
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region.identifier hasPrefix:@"LoopPulse"]) {
        if ([region isKindOfClass:[CLBeaconRegion class]]) {
            CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
            if (beaconRegion.major && beaconRegion.minor) {
                [self notifyLocally:[NSString stringWithFormat:@"didEnterRegion %@", [self colorForMajor:beaconRegion.major]]];
            } else {
                [self startRangingBeaconsInRegion:beaconRegion];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region.identifier hasPrefix:@"LoopPulse"]) {
        if ([region isKindOfClass:[CLBeaconRegion class]]) {
            CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
            if (beaconRegion.major && beaconRegion.minor) {
                [self notifyLocally:[NSString stringWithFormat:@"didExitRegion %@", [self colorForMajor:beaconRegion.major]]];

                [self stopRangingBeaconsInRegion:beaconRegion];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if ([region.identifier hasPrefix:@"LoopPulse"]) {
        if ([beacons count]==0) {
            //[self notifyLocally:@"No beacon detected. stopRangingBeaconsInRegion"];
            [manager stopRangingBeaconsInRegion:region];
            return;
        }

        for (CLBeacon *beacon in beacons) {
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
    }
    return @"Unknown";
}


@end
