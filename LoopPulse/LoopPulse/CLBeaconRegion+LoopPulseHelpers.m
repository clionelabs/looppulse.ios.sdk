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
- (BOOL)isLoopPulseSpecificBeaconRegion
{
    BOOL specific = self.major && self.minor;
    return [self isLoopPulseBeaconRegion] && specific;
}

- (NSString *)key
{
    return [NSString stringWithFormat:@"%@-%@-%@",[self.proximityUUID UUIDString], self.major, self.minor];
}

- (NSString *)description
{
    NSString *productName = [[LoopPulse defaults] objectForKey:self.key];
    return [NSString stringWithFormat:@"%@, %@:%@:%@", productName, [self.proximityUUID UUIDString], self.major, self.minor];
}
@end
