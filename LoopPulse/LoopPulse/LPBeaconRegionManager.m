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

//- (NSDictionary *)readInstallationFile
//{
//    NSURL *configurationJSON = [LoopPulse.defaults URLForKey:@"configurationJSON"];
//    NSData *data = [NSData dataWithContentsOfURL:configurationJSON];
//    NSError *error = nil;
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
//                                                         options:NSJSONReadingAllowFragments
//                                                           error:&error];
//    if (error) NSLog(@"readInstallationFile: error: %@", error);
//    return json;
//}

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

//- (NSDictionary *)locationsJSON
//{
//    return [LoopPulse.defaults objectForKey:@"locations"];
//}
//
//// Return a list of generic regions, using all installations' beacons
//// Each unique UUID is a generic region
//- (NSArray *)generateGenericBeaconRegions
//{
//    NSDictionary * locations = [self locationsJSON];
//    NSMutableSet *genericRegionIdentifiers = [[NSMutableSet alloc] init];
//    NSMutableArray *genericRegions = [[NSMutableArray alloc] init];
//    [locations enumerateKeysAndObjectsUsingBlock:^(id key, id location, BOOL *stop){
//        NSDictionary *installationsDictionary = [location objectForKey:@"installations"];
//        [installationsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id dictionary, BOOL *stop){
//            LPInstallation *installation = [[LPInstallation alloc] initWithDictionary:dictionary];
//            CLBeaconRegion *region = [[CLBeaconRegion alloc] initGenericWithProximityUUID:installation.beaconRegion.proximityUUID];
//            if (![genericRegionIdentifiers containsObject:region.identifier]) {
//                [genericRegions addObject:region];
//                [genericRegionIdentifiers addObject:region.identifier];
//            }
//        }];
//    }];
//    return genericRegions;
//}

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

//- (void)saveProductNames {
//    NSDictionary * locations = [self locationsJSON];
//    [locations enumerateKeysAndObjectsUsingBlock:^(id key, id location, BOOL *stop){
//        NSDictionary *installationsDictionary = [location objectForKey:@"installations"];
//        NSArray *installations = [self mapDictionariesToInstallations:installationsDictionary];
//        // TODO: refactor this out of this method
//        [self saveProductNames:installations];
//    }];
//}
//
//- (void)saveProductNames:(NSArray *)installations
//{
//    NSUserDefaults *defaults = [LoopPulse defaults];
//    NSMutableDictionary *keyToName = [[NSMutableDictionary alloc] initWithCapacity:installations.count];
//    for (LPInstallation *installation in installations) {
//        CLBeaconRegion *beaconRegion = installation.beaconRegion;
//        [keyToName setObject:installation.productName forKey:beaconRegion.key];
//    }
//    [defaults setObject:keyToName forKey:@"beaconRegionKeyToProductName"];
//}
//
//- (NSArray *)mapDictionariesToInstallations:(NSDictionary *)installationsDicitionary
//{
//    NSMutableArray *installations = [NSMutableArray array];
//    [installationsDicitionary enumerateKeysAndObjectsUsingBlock:^(id key, id dictionary, BOOL *stop){
//        LPInstallation *installation = [[LPInstallation alloc] initWithDictionary:dictionary];
//        [installations addObject:installation];
//    }];
//    return installations;
//}

- (NSArray *)genericRegionsToMonitor
{
    if (!_genericRegionsToMonitor) {
        [self saveProductNames];
        _genericRegionsToMonitor = [self generateGenericBeaconRegions];
    }
    return _genericRegionsToMonitor;
}
@end
