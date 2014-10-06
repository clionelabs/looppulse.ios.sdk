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
#import "LoopPulsePrivate.h"

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
    return beaconRegionManager.genericRegionsToMonitor;
}

- (void)requestAuthorization
{
    // http://stackoverflow.com/questions/7848766/how-can-we-programmatically-detect-which-ios-version-is-device-running-on
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        [self requestAlwaysAuthorization];
    } else {
        // we're on iOS 7 or below
    }
}

- (BOOL)isAuthorizedForLoopPulseUse
{
    return (CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorized);
}

- (void)startMonitoringForAllRegions
{
    if ([self isAuthorizedForLoopPulseUse]) {
        [self startMonitoringForBeaconRegions:self.beaconRegions];
    } else {
        // Monitoring will be started once we receive the right authorization.
        [self requestAuthorization];
    }
}

- (void)stopMonitoringForAllRegions
{
    for (CLBeaconRegion *region in self.monitoredRegions) {
        if ([region isLoopPulseBeaconRegion]) {
            [self stopMonitoringForRegion:region];
        }
    }

    for (CLBeaconRegion *region in self.rangedRegions) {
        if ([region isLoopPulseBeaconRegion]) {
            [self stopRangingBeaconsInRegion:region];
        }
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
    NSLog(@"startMonitoringForBeaconRegions: %@", self.monitoredRegions);
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

- (BOOL)shouldOnlySendBeaconEventsWithKnownProximity
{
    NSUserDefaults *defaults = LoopPulse.defaults;
    return [defaults boolForKey:@"onlySendBeaconEventsWithKnownProximity"];
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
        NSArray *filteredBeacons = beacons;
        if ([self shouldOnlySendBeaconEventsWithKnownProximity]) {
            filteredBeacons = [self filterByKnownProximities:beacons];
        }

        for (CLBeacon *beacon in filteredBeacons) {
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

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"didChangeAuthorizationStatus: %d", status);
    // iOS 8 kCLAuthorizationStatusAuthorized is the same as kCLAuthorizationStatusAuthorizedAlways
    if ([self isAuthorizedForLoopPulseUse]) {
        [self startMonitoringForBeaconRegions:self.beaconRegions];
    } else {
        // TODO: What should we do if we got denied
    }
}

@end
