//
//  LPBeaconRegionManager.m
//  LoopPulse
//
//  Created by Thomas Pun on 8/15/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPBeaconRegionManager.h"

@implementation LPBeaconRegionManager {
    NSMutableDictionary *monitoredBeaconRegionsAndItsCount;
}

- (id)init
{
    self = [super init];
    if (self) {
        monitoredBeaconRegionsAndItsCount = [NSMutableDictionary new];
    }
    return self;
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
        NSString *beaconRegionKey = [NSString stringWithFormat:@"%@-%@-%@",
                                     [beaconRegion.proximityUUID UUIDString],
                                     beaconRegion.major,
                                     beaconRegion.minor];
        NSNumber *oldCount = [monitoredBeaconRegionsAndItsCount objectForKey:beaconRegionKey];
        NSInteger newCountInt = [oldCount integerValue] - 1;
        if (newCountInt <= 0) {
            [monitoredBeaconRegionsAndItsCount removeObjectForKey:beaconRegionKey];
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
