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
#import "LoopPulsePrivate.h"

@implementation LPDataStore (LPLocationManager)

- (Firebase *)beaconEventsRef
{
    return [self.firebases objectForKey:@"beacon_events"];
}

- (void)logEvent:(NSString *)eventType withBeacon:(CLBeacon *)beacon atTime:(NSDate *)createdAt
{
    [self logEvent:eventType
         withDictionary:[beacon firebaseDictionary]
                 atTime:createdAt];
}

- (void)logEvent:(NSString *)eventType withBeaconRegion:(CLBeaconRegion *)region atTime:(NSDate *)createdAt
{
    [self logEvent:eventType
         withDictionary:[region firebaseDictionary]
                 atTime:createdAt];

    [self postNotification:eventType withBeaconRegion:region];
}

- (void)logEvent:(NSString *)eventType withDictionary:(NSDictionary *)beaconInfo atTime:(NSDate *)createdAt
{
    NSUUID *visitorUUID = [[LoopPulse sharedInstance] visitorUUID];
    NSNumber *priority = @([createdAt timeIntervalSince1970]);
    NSDictionary *eventInfo = @{@"type": eventType,
                                @"session_id": [[LoopPulse sharedInstance] session],
                                @"visitor_uuid": [visitorUUID UUIDString],
                                @"created_at": [createdAt description]};
    NSMutableDictionary *beaconInfoAndEvent = [[NSMutableDictionary alloc] initWithDictionary:beaconInfo];
    [beaconInfoAndEvent addEntriesFromDictionary:eventInfo];

    Firebase *beacon_event_ref = [[self beaconEventsRef] childByAutoId];
    [beacon_event_ref setValue:beaconInfoAndEvent andPriority:priority];
}

- (void)postNotification:(NSString *)eventType withBeaconRegion:(CLBeaconRegion *)region
{
    NSString *notification = [self eventType2Notification:eventType];
    NSDictionary *userInfo = @{@"eventType": eventType,
                               @"beaconRegion": region};
    [LoopPulse postNotification:notification withUserInfo:userInfo];
}

// Only deal with enter and exit events for now.
- (NSString *)eventType2Notification:(NSString *)eventType
{
    if ([eventType isEqualToString:@"didEnterRegion"]) {
        return LoopPulseLocationDidEnterRegionNotification;
    } else if ([eventType isEqualToString:@"didEnterRegion"]) {
        return LoopPulseLocationDidExitRegionNotification;
    } else {
        return [NSString string];
    }
}

@end
