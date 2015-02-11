//
//  CLBeaconRegion+LoopPulseHelpers.m
//  LoopPulse
//
//  Created by Thomas Pun on 8/13/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "CLBeaconRegion+LoopPulseHelpers.h"
#import "CLRegion+LoopPulseHelpers.h"
#import "LoopPulsePrivate.h"

@implementation CLBeaconRegion (LoopPulseHelpers)

- (instancetype)initGenericWithProximityUUID:(NSUUID *)proximityUUID
{
    NSString *identifier = [NSString stringWithFormat:@"%@:%@", LP_GENERIC_REGION_IDENTIFIER_PREFIX, [proximityUUID UUIDString]];
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:identifier];
    return beaconRegion;
}

- (instancetype)initSpecificWithProximityUUID:(NSUUID *)proximityUUID major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor
{
    NSString *identifier = [NSString stringWithFormat:@"%@:%@:%d:%d", LP_SPECIFIC_REGION_IDENTIFIER_PREFIX, [proximityUUID UUIDString], major, minor];
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
                                                                           major:major
                                                                           minor:minor identifier:identifier];
    return beaconRegion;
}

- (NSString *)key
{
    return [NSString stringWithFormat:@"%@-%@-%@",[self.proximityUUID UUIDString], self.major, self.minor];
}

- (NSString *)description
{
    NSDictionary *beaconRegionKeyToProductName = [[LoopPulse defaults] objectForKey:@"beaconRegionKeyToProductName"];
    NSString *productName = [beaconRegionKeyToProductName objectForKey:self.key];
    return productName;
//    return [NSString stringWithFormat:@"%@, %@:%@:%@", productName, [self.proximityUUID UUIDString], self.major, self.minor];
}
@end
