//
//  CLBeacon+LoopPulseHelpers.m
//  LoopPulse
//
//  Created by Thomas Pun on 8/15/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "CLBeacon+LoopPulseHelpers.h"
#import "CLBeaconRegion+LoopPulseHelpers.h"

@implementation CLBeacon (LoopPulseHelpers)

- (CLBeaconRegion *)beaconRegion
{
    return [[CLBeaconRegion alloc] initSpecificWithProximityUUID:self.proximityUUID major:[self.major integerValue] minor:[self.minor integerValue]];
}
@end
