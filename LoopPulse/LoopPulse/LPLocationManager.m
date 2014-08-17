//
//  LPLocationManager.m
//  LightHouse
//
//  Created by Thomas Pun on 5/2/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPLocationManager.h"
#import "LPBeaconRegionManager.h"
#import "CLRegion+LoopPulseHelpers.h"
#import "CLBeacon+LoopPulseHelpers.h"
#import "CLBeaconRegion+LoopPulseHelpers.h"
#import "LPDataStore+LPLocationManager.h"

@interface LPLocationManager ()
@property (readonly) NSArray *beaconRegions;
@property (readonly, retain) LPDataStore *dataStore;
@end

@implementation LPLocationManager {
    LPBeaconRegionManager *beaconRegionManager;
}

- (id)initWithDataStore:(LPDataStore *)dataStore
{
    self = [super init];
    if (self) {
        _dataStore = dataStore;
        self.delegate = self;
        beaconRegionManager = [LPBeaconRegionManager new];

        [self requestStateForAllRegions];
    }
    return self;
}

- (NSArray *)beaconRegions
{
//    // Estimote
//    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
//    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
//                                                                      identifier:@"LoopPulse-Generic"];
    return beaconRegionManager.genericRegionsToMonitor;
}

- (void)startMonitoringForAllRegions
{
    [self startMonitoringForBeaconRegions:self.beaconRegions];
    NSLog(@"startMonitoringForAllRegions: %@", self.monitoredRegions);
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

- (void)requestStateForAllRegions
{
    for (CLBeaconRegion *beaconRegion in [self beaconRegions]) {
        [self requestStateForRegion:beaconRegion];
    }
}

- (NSArray *)filterByKnownProximities:(NSArray *)beacons
{
    NSArray *knownProximities = @[@(CLProximityImmediate), @(CLProximityNear), @(CLProximityFar)];
    NSPredicate *knownProximityPredicate = [NSPredicate predicateWithFormat:@"proximity IN %@", knownProximities];
    return [beacons filteredArrayUsingPredicate:knownProximityPredicate];
}

- (BOOL)firstEncounteredWithBeaconRegion:(CLBeaconRegion *)beaconRegion
{
    return (![self.monitoredRegions containsObject:beaconRegion]);
}

- (void)startMonitoringForBeaconRegions:(NSArray *)beaconRegionsToMonitor
{
    // TODO: should limit the number regions to monitor
    for (CLBeaconRegion *region in beaconRegionsToMonitor) {
        // From iOS 7.1 doc: If a region of the same type with the same
        // identifier is already being monitored for this application,
        // it will be removed from monitoring.
        if (![self.monitoredRegions containsObject:region]) {
            [self startMonitoringForRegion:region];
        }
    }
}

- (void)stopMonitoringAndRangingForBeaconRegions:(NSArray *)beaconRegionsToMonitor
{
    for (CLBeaconRegion *beaconRegion in beaconRegionsToMonitor) {
        [self stopMonitoringForRegion:beaconRegion];
        [self stopRangingBeaconsInRegion:beaconRegion];
    }
}

- (void)startMonitoringNearbyBeaconRegions:(CLBeaconRegion *)beaconRegionInRange
{
    NSArray *regions = [beaconRegionManager regionsToMonitor:beaconRegionInRange];
    [self startMonitoringForBeaconRegions:regions];
}

- (void)stopMonitoringNearbyBeaconRegions:(CLBeaconRegion *)beaconRegionExiting
{
    NSArray *regions = [beaconRegionManager regionsToNotMonitor:beaconRegionExiting];
    [self stopMonitoringAndRangingForBeaconRegions:regions];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (state==CLRegionStateInside) {
        if ([region isLoopPulseBeaconRegion]) {
            CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
            [self startRangingBeaconsInRegion:beaconRegion];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region isLoopPulseBeaconRegion]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        if ([beaconRegion isLoopPulseSpecificBeaconRegion]) {
            [self startMonitoringNearbyBeaconRegions:beaconRegion];
            [self.dataStore logEvent:@"didEnterRegion" withBeaconRegion:beaconRegion atTime:[NSDate date]];
        } else {
            // We just entered our generic beacon region
            [self startRangingBeaconsInRegion:beaconRegion];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region isLoopPulseBeaconRegion]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        [self stopRangingBeaconsInRegion:beaconRegion];
        if ([beaconRegion isLoopPulseSpecificBeaconRegion]) {
            [self stopMonitoringNearbyBeaconRegions:beaconRegion];
            [self.dataStore logEvent:@"didExitRegion" withBeaconRegion:beaconRegion atTime:[NSDate date]];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if ([region isLoopPulseBeaconRegion]) {
        for (CLBeacon *beacon in [self filterByKnownProximities:beacons]) {
            // If we range a specific beacon without a match from currently monitored regions,
            // then we know we have just entered a generic beacon region.
            CLBeaconRegion *beaconRegion = [beacon beaconRegion];
            if ([self firstEncounteredWithBeaconRegion:beaconRegion]) {
                [self startMonitoringNearbyBeaconRegions:beaconRegion];
                [self.dataStore logEvent:@"didEnterRegion" withBeaconRegion:beaconRegion atTime:[NSDate date]];
            } else {
                [self.dataStore logEvent:@"didRangeBeacons" withBeacon:beacon atTime:[NSDate date]];
            }
        }
    }
}

@end
