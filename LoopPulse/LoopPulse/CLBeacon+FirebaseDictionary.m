//
//  CLBeacon+FirebaseDictionary.m
//  LightHouse
//
//  Created by Thomas Pun on 5/3/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "CLBeacon+FirebaseDictionary.h"

@implementation CLBeacon (FirebaseDictionary)

- (NSDictionary *)firebaseDictionary
{
    NSDictionary *const CLProximityToNSString = @{@(CLProximityUnknown).stringValue: @"unknown",
                                                  @(CLProximityFar).stringValue: @"far",
                                                  @(CLProximityNear).stringValue: @"near",
                                                  @(CLProximityImmediate).stringValue: @"immediate"};
    
    return @{@"uuid": [self.proximityUUID UUIDString],
             @"major": self.major,
             @"minor": self.minor,
             @"proximity": CLProximityToNSString[@(self.proximity).stringValue],
             @"accuracy": @(self.accuracy),
             @"rssi": @(self.rssi)};
}
@end
