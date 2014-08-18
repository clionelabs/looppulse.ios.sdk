//
//  CLBeacon+LoopPulseHelpers.m
//  LoopPulse
//
//  Created by Thomas Pun on 8/15/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "CLBeacon+LoopPulseHelpers.h"

@implementation CLBeacon (LoopPulseHelpers)

- (CLBeaconRegion *)beaconRegion
{
    NSString *identifier = [NSString stringWithFormat:@"LoopPulse-%@:%@", self.major, self.minor];
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID
                                                                           major:[self.major integerValue]
                                                                           minor:[self.minor integerValue]
                                                                      identifier:identifier];
    return beaconRegion;
}

@end
