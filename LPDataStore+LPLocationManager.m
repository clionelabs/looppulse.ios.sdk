//
//  LPDataStore+LPLocationManager.m
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPDataStore+LPLocationManager.h"
#import "CLBeacon+FirebaseDictionary.h"
#import "CLBeaconRegion+FirebaseDictionary.h"

@implementation LPDataStore (LPLocationManager)

- (void)logEvent:(NSString *)event withBeacon:(CLBeacon *)beacon atTime:(NSDate *)createdAt
{
    [self logEvent:event
         withDictionary:[beacon firebaseDictionary]
                 atTime:createdAt];
}

- (void)logEvent:(NSString *)event withBeaconRegion:(CLBeaconRegion *)region atTime:(NSDate *)createdAt
{
    [self logEvent:event
         withDictionary:[region firebaseDictionary]
                 atTime:createdAt];
}

- (void)logEvent:(NSString *)event withDictionary:(NSDictionary *)beaconInfo atTime:(NSDate *)createdAt
{
    NSString *uuid = [[beaconInfo valueForKey:@"proximityUUID"] description];
    NSString *major = [[beaconInfo valueForKey:@"major"] description];
    NSString *minor = [[beaconInfo valueForKey:@"minor"] description];
    NSNumber *priority = @([createdAt timeIntervalSince1970]);

    // TODO: Firebase cannot deal with NSDate object. They should call #description on input.
    NSMutableDictionary *beaconInfoAndEvent = [NSMutableDictionary dictionaryWithDictionary:beaconInfo];
    [beaconInfoAndEvent setValue:event forKey:@"event"];
    [beaconInfoAndEvent setValue:[createdAt description] forKey:@"createdAt"];

    // Watch out for allowable characters for a Firebase location
    // https://www.firebase.com/docs/creating-references.html
    NSString *beacon_id = [NSString stringWithFormat:@"%@:%@:%@", uuid, major, minor];

    // Write to /events/:id
    Firebase *event_ref = [[self.firebase childByAppendingPath:@"events"] childByAutoId];
    [event_ref setValue:beaconInfoAndEvent andPriority:priority];

    // Write to /beacons/:beacon_id/events/:event_id
    Firebase *beacon_ref = [[self.firebase childByAppendingPath:@"beacons"] childByAppendingPath:beacon_id];
    NSString *event_ref_id = [event_ref name];
    Firebase *beacon_event_ref = [[beacon_ref childByAppendingPath:@"events"] childByAppendingPath:event_ref_id];
    [beacon_event_ref setValue:@(true) andPriority:priority];
}

@end
