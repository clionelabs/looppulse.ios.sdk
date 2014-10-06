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
#import "LoopPulsePrivate.h"

@implementation LPBeaconRegionManager {
    NSMutableDictionary *monitoredBeaconRegionKeysAndCounts;
    NSDictionary *beaconRegionsNearby;
}

@synthesize genericRegionsToMonitor = _genericRegionsToMonitor;

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
    NSURL *configurationJSON = [LoopPulse.defaults URLForKey:@"configurationJSON"];
    NSData *data = [NSData dataWithContentsOfURL:configurationJSON];
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingAllowFragments
                                                           error:&error];
    if (error) NSLog(@"readInstallationFile: error: %@", error);
    return json;
}

- (NSDictionary *)locationsJSON
{
    return [LoopPulse.defaults objectForKey:@"locations"];
}

// Given current beacon region, return an array of possiblily overlapping regions
- (NSDictionary *)generateBeaconRegionsNearby
{
    NSMutableDictionary *regionsNearby = [NSMutableDictionary dictionary];
    NSDictionary * locations = [self locationsJSON];
    [locations enumerateKeysAndObjectsUsingBlock:^(id key, id location, BOOL *stop){
        NSDictionary *installationsDictionary = [location objectForKey:@"installations"];
        NSArray *installations = [self mapDictionariesToInstallations:installationsDictionary];

        NSDictionary *keyAndRegions = [self generateRegionKeyAndNearbyRegions:installations];
        [regionsNearby addEntriesFromDictionary:keyAndRegions];

        // TODO: refactor this out of this method
        [self saveProductNames:installations];
    }];
    return regionsNearby;
}

- (void)saveProductNames:(NSArray *)installations
{
    NSUserDefaults *defaults = [LoopPulse defaults];
    NSMutableDictionary *keyToName = [[NSMutableDictionary alloc] initWithCapacity:installations.count];
    for (LPInstallation *installation in installations) {
        CLBeaconRegion *beaconRegion = installation.beaconRegion;
        [keyToName setObject:installation.productName forKey:beaconRegion.key];
    }
    [defaults setObject:keyToName forKey:@"beaconRegionKeyToProductName"];
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

- (NSDictionary *)generateRegionKeyAndNearbyRegions:(NSArray *)installations
{
    NSMutableDictionary *keyAndRegions = [NSMutableDictionary dictionary];
    for (LPInstallation *installation in installations) {
        NSMutableArray *regionsNearby = [NSMutableArray array];
        for (LPInstallation *otherInstallation in installations) {
            if ([installation isNearby:otherInstallation]) {
                [regionsNearby addObject:otherInstallation.beaconRegion];
            }
        }
        [keyAndRegions setObject:regionsNearby forKey:installation.key];
    }
    return keyAndRegions;
}

- (NSArray *)genericRegionsToMonitor
{
    if (!_genericRegionsToMonitor) {
        // TODO: This is inefficient. We should gather all the UUIDs in mapDictionariesToInstallations
        NSMutableSet *uuids = [NSMutableSet set];
        [beaconRegionsNearby enumerateKeysAndObjectsUsingBlock:^(id key, id regionsNearby, BOOL *stop){
            for (CLBeaconRegion *beaconRegion in regionsNearby) {
                [uuids addObject:beaconRegion.proximityUUID];
            }
        }];

        // Create regions based on these unique UUIDs.
        NSArray *uuidsArray = [NSArray arrayWithArray:[uuids allObjects]];
        NSMutableArray *regions = [NSMutableArray arrayWithCapacity:[uuids count]];
        [uuidsArray enumerateObjectsUsingBlock:^(NSUUID * uuid, NSUInteger index, BOOL *stop) {
            NSString *identifier = [NSString stringWithFormat:@"LoopPulse-Generic-%d", (unsigned int)index];
            CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:identifier];
            [regions addObject:region];
        }];
        _genericRegionsToMonitor = regions;
    }
    return _genericRegionsToMonitor;
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
