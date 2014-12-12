//
//  LPInstallation.m
//  LoopPulse
//
//  Created by Thomas Pun on 8/16/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPInstallation.h"
#import "CLBeaconRegion+LoopPulseHelpers.h"

@interface LPInstallation ()
@property (readonly) NSNumber *x;
@property (readonly) NSNumber *y;
@property (readonly) NSNumber *z;
@property (nonatomic, retain) NSDictionary *dictionary;
@end

@implementation LPInstallation {
    NSDictionary *beacon;
    NSDictionary *coordinate; // local
}
@synthesize key = _key;
@synthesize beaconRegion = _beaconRegion;
@synthesize productName = _productName;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        beacon = [dictionary objectForKey:@"beacon"];
        coordinate = [dictionary objectForKey:@"coordinate"];
        _productName = [dictionary objectForKey:@"product"];
        self.dictionary = dictionary;
    }
    return self;
}

- (BOOL)isEqual:(LPInstallation *)other
{
    return [self.dictionary isEqual:other.dictionary];
}

// TODO: currently only use floor info for nearby detection
- (BOOL)isNearby:(LPInstallation *)otherInstallation
{
    BOOL sameFloor = [self.z isEqual:otherInstallation.z];
    if (!sameFloor) {
        return false;
    }
    return true;
}

- (CLBeaconRegion *)beaconRegion
{
    if (!_beaconRegion) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[beacon objectForKey:@"proximityUUID"]];
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

- (NSNumber *)x
{
    return [coordinate objectForKey:@"x"];
}

- (NSNumber *)y
{
    return [coordinate objectForKey:@"y"];
}

- (NSNumber *)z
{
    return [coordinate objectForKey:@"z"];
}

@end
