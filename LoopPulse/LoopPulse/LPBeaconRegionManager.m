//
//  LPBeaconRegionManager.m
//  LoopPulse
//
//  Created by Thomas Pun on 8/15/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPBeaconRegionManager.h"
#import "CLBeaconRegion+LoopPulseHelpers.h"
#import "LoopPulsePrivate.h"
#import "LPPoi.h"

@implementation LPBeaconRegionManager

@synthesize genericRegionsToMonitor = _genericRegionsToMonitor;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSArray *)pois
{
    NSArray *poisJSON = [LoopPulse.defaults objectForKey:@"pois"];
    NSMutableArray *pois = [[NSMutableArray alloc] initWithCapacity:poisJSON.count];
    for (NSDictionary *poiJSON in poisJSON) {
        [pois addObject:[[LPPoi alloc] initWithDictionary:poiJSON]];
    }
    return pois;
}

- (NSArray *)generateGenericBeaconRegions
{
    NSArray *pois = [self pois];
    NSMutableSet *genericRegionIdentifiers = [[NSMutableSet alloc] init];
    NSMutableArray *genericRegions = [[NSMutableArray alloc] init];
    for (LPPoi *poi in pois) {
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initGenericWithProximityUUID:[[poi beaconRegion] proximityUUID]];
        if (![genericRegionIdentifiers containsObject:region.identifier]) {
            [genericRegions addObject:region];
            [genericRegionIdentifiers addObject:region.identifier];
        }
    }
    return genericRegions;
}

- (void)saveProductNames {
    NSUserDefaults *defaults = [LoopPulse defaults];
    NSArray *pois = [self pois];
    NSMutableDictionary *keyToName = [[NSMutableDictionary alloc] initWithCapacity:pois.count];
    for (LPPoi *poi in pois) {
        [keyToName setObject:poi.productName forKey:poi.beaconRegion.key];
    }
    [defaults setObject:keyToName forKey:@"beaconRegionKeyToProductName"];
}

- (NSArray *)genericRegionsToMonitor
{
    if (!_genericRegionsToMonitor) {
        [self saveProductNames];
        _genericRegionsToMonitor = [self generateGenericBeaconRegions];
    }
    return _genericRegionsToMonitor;
}
@end
