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

- (NSArray *)poisJSON
{
    return [LoopPulse.defaults objectForKey:@"pois"];
}

- (NSArray *)generateGenericBeaconRegions
{
    NSArray *pois = [self poisJSON];
    NSMutableSet *genericRegionIdentifiers = [[NSMutableSet alloc] init];
    NSMutableArray *genericRegions = [[NSMutableArray alloc] init];
    for (NSDictionary *poi in pois) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[[poi objectForKey:@"beacon"] objectForKey:@"uuid"]];
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initGenericWithProximityUUID:uuid];
        if (![genericRegionIdentifiers containsObject:region.identifier]) {
            [genericRegions addObject:region];
            [genericRegionIdentifiers addObject:region.identifier];
        }
    }
    return genericRegions;
}

- (void)saveProductNames {
    NSUserDefaults *defaults = [LoopPulse defaults];
    NSArray *poisJSON = [self poisJSON];
    NSMutableDictionary *keyToName = [[NSMutableDictionary alloc] initWithCapacity:poisJSON.count];
    for (NSDictionary *poiJSON in poisJSON) {
        LPPoi *poi = [[LPPoi alloc] initWithDictionary:poiJSON];
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
