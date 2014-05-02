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
    return ([self.identifier hasPrefix:@"LoopPulse"] &&
            [self isKindOfClass:[CLBeaconRegion class]]);
}
@end
