//
//  LPBeaconRegionManager.m
//  LoopPulse
//
//  Created by Thomas Pun on 8/15/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPBeaconRegionManager.h"
#import "CLBeaconRegion+LoopPulseHelpers.h"
#import "LPInstallation.h"

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
    if (error) NSLog(@"readInstallationFile: error: %@", error);
    return json;
}

// Given current beacon region, return an array of possiblily overlapping regions
- (NSDictionary *)generateBeaconRegionsNearby
{
    NSMutableDictionary *regionsNearby = [NSMutableDictionary dictionary];
    NSDictionary *company = [self readInstallationFile];
    NSDictionary * locations = [company objectForKey:@"locations"];
    [locations enumerateKeysAndObjectsUsingBlock:^(id key, id location, BOOL *stop){
        NSDictionary *installations = [location objectForKey:@"installations"];
        NSDictionary *keyAndRegions = [self generateRegionKeyAndNearbyRegions:installations];
        [regionsNearby addEntriesFromDictionary:keyAndRegions];
    }];
    return regionsNearby;
}

- (NSArray *)mapDictionariesToInstallations:(NSDictionary *)installationsDicitionary
{
    NSMutableArray *installations = [NSMutableArray array];
    [installationsDicitionary enumerateKeysAndObjectsUsingBlock:^(id key, id dictionary, BOOL *stop){
        LPInstallation *installation = [[LPInstallation alloc] initWithDictionary:dictionary];
        [installations addObject:installation];
    }];
    return installations;
}

- (NSDictionary *)generateRegionKeyAndNearbyRegions:(NSDictionary *)installationsDictionary
{
    NSMutableDictionary *keyAndRegions = [NSMutableDictionary dictionary];
    NSArray *installations = [self mapDictionariesToInstallations:installationsDictionary];
    for (LPInstallation *installation in installations) {
        NSMutableArray *regionsNearby = [NSMutableArray array];
        for (LPInstallation *otherInstallation in installations) {
            if ([installation isEqual:otherInstallation]) {
                continue;
            }
            if ([installation isNearby:otherInstallation]) {
                [regionsNearby addObject:otherInstallation.beaconRegion];
            }
        }
        [keyAndRegions setObject:regionsNearby forKey:installation.key];
    }
    return keyAndRegions;
}

- (NSArray *)beaconRegionsNearby:(CLBeaconRegion *)currentRegion
{
    NSString *key = currentRegion.key;
    return [beaconRegionsNearby objectForKey:key];
}

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
    NSArray *regionsNearby = [self beaconRegionsNearby:enteredRegion];
    NSArray *regionsToMonitor = [self retainBeaconRegions:regionsNearby];

    // Sort the regions according to the distance
    return regionsToMonitor;
}

- (NSArray *)regionsToNotMonitor:(CLBeaconRegion *)exitedRegion
{
    // Please note regionsNearby.count >= regionsToNotMonitor.count
    // because regions in regionsNearby could still be needed due to
    // other regions the visitor is currently at.
    NSArray *regionsNearby = [self beaconRegionsNearby:exitedRegion];
    NSArray *regionsToNotMonitor = [self releaseBeaconRegions:regionsNearby];

    return regionsToNotMonitor;
}
@end
