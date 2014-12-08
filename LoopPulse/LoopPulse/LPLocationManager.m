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

- (void)startMonitoringForAllRegions
{
    // For iOS 8, we need to call requestAlwaysAuthorization explicity for permission
    //   It's okay we call it everytime without checking the authorization status, because it won't prompt again once it's authorized.
    // For iOS 7, we just need to call startMonitoring, and iOS will prompt the permission dialog automatically
    if ([self respondsToSelector: @selector(requestAlwaysAuthorization)]) {
        [self requestAlwaysAuthorization];
    }
    [self startMonitoringForBeaconRegions:self.beaconRegions];
    
//    // We do a random ranging purely for the purpose of speeding up responsiveness.
//    // Due to the underlying implementation of iOS monitoring, a ranging event will force the
//    // system to do bluetooth scan immediately, which as a side effect, will trigger didEnter/ didExit events if there are ones.
//    if ([self.beaconRegions count] > 0) {
//        // Just build a random region to range. Doesn't really matter what it is.
//        CLBeaconRegion *firstRegion = [self.beaconRegions firstObject];
//        CLBeaconRegion *randomRegion = [[CLBeaconRegion alloc] initWithProximityUUID:firstRegion.proximityUUID identifier:[NSString stringWithFormat:@"%@:%@", LP_REGION_IDENTIFIER_PREFIX, firstRegion.proximityUUID]];
//        [self startRangingBeaconsInRegion:randomRegion];
//    }
    
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
        // it will be removed from monitoring.
        if (![self.monitoredRegions containsObject:region]) {
            [self startMonitoringForRegion:region];
        }
    }
}

#pragma mark Region Events - Generic and Specific
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
    NSLog(@"didRange in Region: %@", region);
    NSArray *filteredBeacons = beacons;
    if ([self shouldOnlySendBeaconEventsWithKnownProximity]) {
        filteredBeacons = [self filterByKnownProximities:beacons];
    }
    if ([region isLoopPulseGenericBeaconRegion]) {
        [self didRangeBeacons:beacons inGenericRegion:region];
    } else if ([region isLoopPulseSpecificBeaconRegion]) {
        [self didRangeBeacons:beacons inSpecificRegion:region];
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
