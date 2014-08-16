//
//  LPBeaconRegionManager.m
//  LoopPulse
//
//  Created by Thomas Pun on 8/15/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPBeaconRegionManager.h"
#import "CLBeaconRegion+LoopPulseHelpers.h"

@implementation LPBeaconRegionManager {
    NSMutableDictionary *monitoredBeaconRegionKeysAndCounts;
    NSDictionary *beaconRegionsNearby;
}

- (id)init
{
    self = [super init];
    if (self) {
        monitoredBeaconRegionKeysAndCounts = [NSMutableDictionary dictionary];
        beaconRegionsNearby = [self generateBeaconRegionsNearby];
    }
    return self;
}

- (NSDictionary *)readInstallationFile
{
    NSString* jsonPath = [[NSBundle mainBundle]pathForResource:@"megabox" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:8 error:&error];
    if (error)
        NSLog(@"readInstallationFile: error: %@", error);
    NSLog(@"readInstallationFile: %@", json);
    return json;
}

// Given current beacon region, return an array of possiblily overlapping regions
- (NSDictionary *)generateBeaconRegionsNearby
{
    NSMutableDictionary *regionsNearby = [NSMutableDictionary dictionary];
//    NSDictionary *company = [self readInstallationFile];
//    NSDictionary * locations = [company objectForKey:@"locations"];
//    for (NSDictionary *location in locations) {
//        NSDictionary *installations = [location objectForKey:@"installations"];
//        NSDictionary *keyAndRegions = [self generateRegionKeyAndNearbyRegions:installations];
//        [regionsNearby addEntriesFromDictionary:keyAndRegions];
//    }
    return regionsNearby;
}

//- (CLBeaconRegion *)beaconRegionFromBeaconDictionary:(NSDictionary *)beacon
//{
//    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[beacon objectForKey:@"proximityUUID"]];
//    NSNumber *major = [beacon objectForKey:@"major"];
//    NSNumber *minor = [beacon objectForKey:@"minor"];
//    NSString *identifier = [NSString stringWithFormat:@"LoopPulse-%@:%@", major, minor]; // TODO: refactor
//    return [[CLBeaconRegion alloc] initWithProximityUUID:uuid
//                                                   major:[major integerValue]
//                                                   minor:[minor integerValue]
//                                              identifier:identifier];
//}
//
//- (NSDictionary *)generateRegionKeyAndNearbyRegions:(NSDictionary *)installations
//{
//    NSMutableDictionary *keyAndRegions = [NSMutableDictionary dictionary];
//    for (NSDictionary *installation in installations) {
//        NSDictionary *beacon = [installation objectForKey:@"beacon"];
//        CLBeaconRegion *currentRegion = [self beaconRegionFromBeaconDictionary:beacon];
//        NSString *key = [currentRegion key];
//        // Initialize the value to be an empty array.
//        [keyAndRegions setObject:[NSMutableArray array] forKey:key];
//        for (NSDictionary *otherInstallation in installations) {
//            if ([otherInstallation isEqual:installation]) {
//                continue;
//            }
//            NSDictionary *otherBeacon = [otherInstallation objectForKey:@"beacon"];
//            CLBeaconRegion *otherRegion = [self beaconRegionFromBeaconDictionary:otherBeacon];
//            NSMutableArray *regions = [keyAndRegions objectForKey:key];
//            [regions addObject:otherRegion];
//        }
//    }
//    return keyAndRegions;
//}

- (NSArray *)retainBeaconRegions:(NSArray *)beaconRegions
{
    for (CLBeaconRegion *beaconRegion in beaconRegions) {
        NSString *beaconRegionKey = [beaconRegion key];
        NSNumber *oldCount = [monitoredBeaconRegionKeysAndCounts objectForKey:beaconRegionKey];
        NSInteger newCountInt = [oldCount integerValue] + 1;
        [monitoredBeaconRegionKeysAndCounts setObject:[NSNumber numberWithInteger:newCountInt]
                                              forKey:beaconRegionKey];
    }
    return beaconRegions;
}

// Returns newly released beacon regions to be removed
- (NSArray *)releaseBeaconRegions:(NSArray *)beaconRegions
{
    NSMutableSet *deleted = [NSMutableSet new];
    for (CLBeaconRegion *beaconRegion in beaconRegions) {
        NSString *beaconRegionKey = [beaconRegion key];
        NSNumber *oldCount = [monitoredBeaconRegionKeysAndCounts objectForKey:beaconRegionKey];
        NSInteger newCountInt = [oldCount integerValue] - 1;
        if (newCountInt <= 0) {
            [monitoredBeaconRegionKeysAndCounts removeObjectForKey:beaconRegionKey];
            [deleted addObject:beaconRegion];
        }
    }
    return [deleted allObjects];
}

- (NSArray *)regionsToMonitor:(CLBeaconRegion *)enteredRegion
{
    // Please note regionsNearby.count <= regionsToMonitor.count
    // because regionsToMonitor contains previously monitored regions
    NSArray *regionsNearby = @[enteredRegion];
    NSArray *regionsToMonitor = [self retainBeaconRegions:regionsNearby];

    // Sort the regions according to the distance
    return regionsToMonitor;
}

- (NSArray *)regionsToNotMonitor:(CLBeaconRegion *)exitedRegion
{
    // Please note regionsNearby.count >= regionsToNotMonitor.count
    // because regions in regionsNearby could still be needed due to
    // other regions the visitor is currently at.
    NSArray *regionsNearby = @[exitedRegion];
    NSArray *regionsToNotMonitor = [self releaseBeaconRegions:regionsNearby];

    return regionsToNotMonitor;
}
@end
