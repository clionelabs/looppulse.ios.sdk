//
//  CLRegion+LoopPulseHelpers.m
//  LightHouse
//
//  Created by Thomas Pun on 5/2/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "CLRegion+LoopPulseHelpers.h"

@implementation CLRegion (LoopPulseHelpers)

- (BOOL)isLoopPulseBeaconRegion
{
    return ([self.identifier hasPrefix:LP_REGION_IDENTIFIER_PREFIX] &&
            [self isKindOfClass:[CLBeaconRegion class]]);
}

- (BOOL)isLoopPulseSpecificBeaconRegion
{
    return ([self.identifier hasPrefix:LP_SPECIFIC_REGION_IDENTIFIER_PREFIX] &&
            [self isKindOfClass:[CLBeaconRegion class]]);
}

- (BOOL)isLoopPulseGenericBeaconRegion
{
    return ([self.identifier hasPrefix:LP_GENERIC_REGION_IDENTIFIER_PREFIX] &&
            [self isKindOfClass:[CLBeaconRegion class]]);
}
@end
