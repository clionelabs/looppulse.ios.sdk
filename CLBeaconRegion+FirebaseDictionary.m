//
//  CLBeaconRegion+FirebaseDictionary.m
//  LightHouse
//
//  Created by Thomas Pun on 5/3/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "CLBeaconRegion+FirebaseDictionary.h"

@implementation CLBeaconRegion (FirebaseDictionary)
- (NSDictionary *)firebaseDictionary
{
    return @{@"uuid": [self.proximityUUID UUIDString],
             @"major": self.major,
             @"minor": self.minor};
}
@end
