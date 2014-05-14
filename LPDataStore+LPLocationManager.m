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
#import "LPVisitor.h"

@implementation LPDataStore (LPLocationManager)

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
}

- (void)logEvent:(NSString *)eventType withDictionary:(NSDictionary *)beaconInfo atTime:(NSDate *)createdAt
{
    NSNumber *priority = @([createdAt timeIntervalSince1970]);
    NSDictionary *eventInfo = @{@"type": eventType,
                                @"visitor_uuid": [self.visitor.uuid UUIDString],
                                @"created_at": [createdAt description]};

    Firebase *beacon_event_ref = [[self.firebase childByAppendingPath:@"beacon_events"] childByAutoId];
    [beacon_event_ref setValue:eventInfo andPriority:priority];

    Firebase *beacon_ref = [beacon_event_ref childByAppendingPath:@"beacon"];
    [beacon_ref setValue:beaconInfo];
}


@end
