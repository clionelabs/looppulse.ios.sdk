//
//  LPLocationManager.m
//  LightHouse
//
//  Created by Thomas Pun on 5/2/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//
//  Please refer to the README file in repository for detailed explanation on the monitoring logic.
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
    // For iOS 8, we need to call requestAlwaysAuthorization explicity for permission
    //   It's okay we call it everytime without checking the authorization status, because it won't prompt again once it's authorized.
    // For iOS 7, we just need to call startMonitoring, and iOS will prompt the permission dialog automatically
    if ([self respondsToSelector: @selector(requestAlwaysAuthorization)]) {
        [self requestAlwaysAuthorization];
        [[LoopPulse sharedInstance] track:@"requestAlwaysAuthorization" withProperties:@{}];
    } else {
        [[LoopPulse sharedInstance] track:@"requestAuthorization" withProperties:@{}];
    }
}

- (void)startMonitoringForAllRegions
{
    if (!self.isAuthorized) {
        [self requestAuthorization];
    }

    // Noted that you can set monitoredRegions before authorization, but they won't function until it's authorized
    [self startMonitoringForBeaconRegions:self.beaconRegions];
    [self trackCurrentMonitoredRegions];
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
    
    [self trackCurrentMonitoredRegions];
}

- (void)requestStateForAllRegions
{
    for (CLBeaconRegion *beaconRegion in [self beaconRegions]) {
        [self requestStateForRegion:beaconRegion];
    }
}

- (void)startMonitoringForBeaconRegions:(NSArray *)beaconRegionsToMonitor
{
    // TODO: should limit the number regions to monitor
    for (CLBeaconRegion *region in beaconRegionsToMonitor) {
        // From iOS 7.1 doc: If a region of the same type with the same
        // identifier is already being monitored for this application,
        // it will be replaced by the new one.
        if (![self.monitoredRegions containsObject:region]) {
            [self startMonitoringForRegion:region];
        }
    }
}

#pragma mark Region Events - Generic and Specific
// Please refer to the README under the source repository in order the understand the following logic
- (void)didEnterGenericRegion:(CLRegion *)region
{
    [self startRangingBeaconsInRegion:(CLBeaconRegion *)region];
}
- (void)didExitGenericRegion:(CLRegion *)region
{
    // Do Nothing
}
- (void)didRangeBeacons:(NSArray *)beacons inGenericRegion:(CLRegion *)region
{
    for (CLBeacon *beacon in beacons) {
        CLBeaconRegion *beaconRegion = [beacon beaconRegion];
        if (![self.monitoredRegions containsObject:beaconRegion]) {
            [self.dataStore logEvent:@"didEnterRegion" withBeaconRegion:beaconRegion atTime:[NSDate date]];
            [self startMonitoringForRegion:beaconRegion];
        }
    }
}

- (void)didEnterSpecificRegion:(CLRegion *)region
{
    // Do Nothing
}
- (void)didExitSpecificRegion:(CLRegion *)region
{
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    [self.dataStore logEvent:@"didExitRegion" withBeaconRegion:beaconRegion atTime:[NSDate date]];
    [self stopMonitoringForRegion:beaconRegion];
}
- (void)didRangeBeacons:(NSArray *)beacons inSpecificRegion:(CLRegion *)region
{
    // Do Nothing - We won't range specific beacon regions anyway.
    NSAssert(![region isLoopPulseSpecificBeaconRegion], @"Tried to range a specific region. %@", region);
}

#pragma mark - locationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSLog(@"didDetermineState in Region: %@, state: %d", region, state);
    if (state == CLRegionStateInside) {
        if ([region isLoopPulseGenericBeaconRegion]) {
            [self didEnterGenericRegion:region];
        } else if ([region isLoopPulseSpecificBeaconRegion]) {
            [self didEnterSpecificRegion:region];
        }
    } else if (state == CLRegionStateOutside) {
        if ([region isLoopPulseGenericBeaconRegion]) {
            [self didExitGenericRegion:region];
        } else if ([region isLoopPulseSpecificBeaconRegion]) {
            [self didExitSpecificRegion:region];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    // Only deal with beacons from given POIs.
    NSArray *filteredBeacons = [self filterByKnownBeacons:beacons];
    if ([self shouldOnlySendBeaconEventsWithKnownProximity]) {
        filteredBeacons = [self filterByKnownProximities:filteredBeacons];
    }
    if (filteredBeacons.count > 0) {
        if ([region isLoopPulseGenericBeaconRegion]) {
            [self didRangeBeacons:filteredBeacons inGenericRegion:region];
        } else if ([region isLoopPulseSpecificBeaconRegion]) {
            [self didRangeBeacons:filteredBeacons inSpecificRegion:region];
        }
    }
}



- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [[LoopPulse sharedInstance] track:@"didChangeAuthorizationStatus" withProperties:@{@"status": [NSString stringWithFormat:@"%D", status]}];
    
    if ([self isAuthorized]) {
        [self startMonitoringForAllRegions];
        [LoopPulse postNotification:LoopPulseLocationAuthorizationGrantedNotification withUserInfo:nil];
    } else {
        [self stopMonitoringForAllRegions];
        [LoopPulse postNotification:LoopPulseLocationAuthorizationDeniedNotification withUserInfo:@{@"authorizationStatus": @(status)}];
    }
}

#pragma mark - utils
- (BOOL)isAuthorized
{
    // IOS 7: kCLAuthorizationStatusAuthorized
    // IOS 8: kCLAuthorizationStatusAuthorizedAlways
    return (CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorized
            || CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways);
}

// Ensure we only deal with the beacons we expected
- (NSArray *)filterByKnownBeacons:(NSArray *)beacons
{
    NSArray *pois = [LoopPulse.defaults objectForKey:@"pois"];
    NSPredicate *isKnownBeacon = [NSPredicate predicateWithBlock:^BOOL(CLBeacon * beacon, NSDictionary *bindings) {
        for (NSDictionary *poi in pois) {
            NSDictionary *knownBeacon = [poi objectForKey:@"beacon"];
            if ([[beacon.proximityUUID UUIDString] caseInsensitiveCompare:[knownBeacon objectForKey:@"uuid"]]==NSOrderedSame &&
                beacon.major == [knownBeacon objectForKey:@"major"] &&
                beacon.minor == [knownBeacon objectForKey:@"minor"]) {
                return true;
            }
        }
        return false;
    }];
    return [beacons filteredArrayUsingPredicate:isKnownBeacon];
}

- (NSArray *)filterByKnownProximities:(NSArray *)beacons
{
    NSArray *knownProximities = @[@(CLProximityImmediate), @(CLProximityNear), @(CLProximityFar)];
    NSPredicate *knownProximityPredicate = [NSPredicate predicateWithFormat:@"proximity IN %@", knownProximities];
    return [beacons filteredArrayUsingPredicate:knownProximityPredicate];
}

- (BOOL)shouldOnlySendBeaconEventsWithKnownProximity
{
    return [LoopPulse.defaults boolForKey:@"onlySendBeaconEventsWithKnownProximity"];
}

- (void)trackCurrentMonitoredRegions
{
    NSMutableArray *regions = [[NSMutableArray alloc] init];
    for (CLBeaconRegion *region in [self monitoredRegions]) {
        [regions addObject:region.identifier];
    }
    [[LoopPulse sharedInstance] track:@"monitoredRegions" withProperties:@{@"regions": regions}];
}

@end
