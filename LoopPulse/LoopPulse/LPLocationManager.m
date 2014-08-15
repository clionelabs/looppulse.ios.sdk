//
//  LPLocationManager.m
//  LightHouse
//
//  Created by Thomas Pun on 5/2/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPLocationManager.h"
#import "CLRegion+LoopPulseHelpers.h"
#import "CLBeaconRegion+LoopPulseHelpers.h"
#import "LPDataStore+LPLocationManager.h"

@interface LPLocationManager ()
@property (readonly) NSArray *beaconRegions;
@property (readonly, retain) LPDataStore *dataStore;
@end

@implementation LPLocationManager {
    NSMutableDictionary *monitoredBeaconRegionsAndItsCount;
}

- (id)initWithDataStore:(LPDataStore *)dataStore
{
    self = [super init];
    if (self) {
        _dataStore = dataStore;
        self.delegate = self;
        monitoredBeaconRegionsAndItsCount = [NSMutableDictionary new];

        [self requestStateForAllRegions];
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

- (CLBeaconRegion *)beaconRegion:(CLBeacon *)beacon
{
    NSString *identifier = [NSString stringWithFormat:@"LoopPulse-%@:%@", beacon.major, beacon.minor];
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beacon.proximityUUID
                                                                           major:[beacon.major integerValue]
                                                                           minor:[beacon.minor integerValue]
                                                                      identifier:identifier];
    return beaconRegion;
}

// Based on the beacons in range, we calculate the nearby
// beacon regions we also need to monitor.
- (NSArray *)beaconRegionsToMonitor:(NSArray *)beaconsInRange
{
    NSMutableArray *beaconRegions = [[NSMutableArray alloc] initWithCapacity:beaconsInRange.count];
    for (CLBeacon *beacon in beaconsInRange) {
        [beaconRegions addObject:[self beaconRegion:beacon]];
    }
    return beaconRegions;
}

- (BOOL)firstEncounteredWithBeaconRegion:(CLBeaconRegion *)beaconRegion
{
    return (![self.monitoredRegions containsObject:beaconRegion]);
}

- (void)startMonitoringForBeaconRegions:(NSArray *)beaconRegionsToMonitor
{
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

- (NSArray *)retainBeaconRegions:(NSArray *)beaconRegions
{
    for (CLBeaconRegion *beaconRegion in beaconRegions) {
        NSString *beaconRegionKey = [NSString stringWithFormat:@"%@-%@-%@", beaconRegion.proximityUUID, beaconRegion.major, beaconRegion.minor];
        NSNumber *oldCount = [monitoredBeaconRegionsAndItsCount objectForKey:beaconRegionKey];
        NSInteger newCountInt = [oldCount integerValue] + 1;
        [monitoredBeaconRegionsAndItsCount setObject:[NSNumber numberWithInteger:newCountInt]
                                             forKey:beaconRegionKey];
    }
    return beaconRegions;
}

// Returns newly released beacon regions
- (NSArray *)releaseBeaconRegions:(NSArray *)beaconRegions
{
    NSMutableSet *deleted = [NSMutableSet new];
    for (CLBeaconRegion *beaconRegion in beaconRegions) {
        NSString *beaconRegionKey = [NSString stringWithFormat:@"%@-%@-%@", beaconRegion.proximityUUID, beaconRegion.major, beaconRegion.minor];
        NSNumber *oldCount = [monitoredBeaconRegionsAndItsCount objectForKey:beaconRegionKey];
        NSInteger newCountInt = [oldCount integerValue] - 1;
        if (newCountInt <= 0) {
            [monitoredBeaconRegionsAndItsCount removeObjectForKey:beaconRegionKey];
            [deleted addObject:beaconRegion];
        }
    }
    return [deleted allObjects];
}

// We use reference counting to determine when a region is good to be removed.
- (void)startMonitoringNearbyBeaconRegions:(CLBeaconRegion *)beaconRegionInRange
{
    NSArray *nearbyBeaconRegions = @[beaconRegionInRange];
    NSArray *beaconRegionsToMonitor = [self retainBeaconRegions:nearbyBeaconRegions];
    [self startMonitoringForBeaconRegions:beaconRegionsToMonitor];
}

- (void)stopMonitoringNearbyBeaconRegions:(CLBeaconRegion *)beaconRegionExiting
{
    NSArray *nearbyBeaconRegions = @[beaconRegionExiting];
    NSArray *beaconRegionsToRemove = [self releaseBeaconRegions:nearbyBeaconRegions];
    [self stopMonitoringAndRangingForBeaconRegions:beaconRegionsToRemove];
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
            CLBeaconRegion *beaconRegion = [self beaconRegion:beacon];
            if ([self firstEncounteredWithBeaconRegion:beaconRegion]) {
                [self startMonitoringNearbyBeaconRegions:beaconRegion];
                [self.dataStore logEvent:@"didEnterRegion" withBeaconRegion:beaconRegion atTime:[NSDate date]];
            } else {
                [self.dataStore logEvent:@"didRangeBeacons" withBeaconRegion:beaconRegion atTime:[NSDate date]];
            }
        }
    }
}

@end
