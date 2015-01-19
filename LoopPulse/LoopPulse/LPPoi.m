//
//  LPPoi.m
//  LoopPulse
//
//  Created by HiuKim on 2015-01-08.
//  Copyright (c) 2015 Clione Labs. All rights reserved.
//

#import "LPPoi.h"
#import "CLBeaconRegion+LoopPulseHelpers.h"

@implementation LPPoi {
    NSDictionary *beacon;
}
@synthesize key = _key;
@synthesize beaconRegion = _beaconRegion;
@synthesize productName = _productName;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        beacon = [dictionary objectForKey:@"beacon"];
        _productName = [dictionary objectForKey:@"name"];
    }
    return self;
}

- (CLBeaconRegion *)beaconRegion
{
    if (!_beaconRegion) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[beacon objectForKey:@"uuid"]];
        NSNumber *major = [beacon objectForKey:@"major"];
        NSNumber *minor = [beacon objectForKey:@"minor"];
        _beaconRegion = [[CLBeaconRegion alloc] initSpecificWithProximityUUID:uuid
                                                                        major:[major integerValue]
                                                                        minor:[minor integerValue]];
    }
    return _beaconRegion;
}

- (NSString *)key
{
    if (!_key) {
        _key = [self.beaconRegion key];
    }
    return _key;
}

@end
