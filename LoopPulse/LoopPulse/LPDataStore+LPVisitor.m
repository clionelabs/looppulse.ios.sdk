//
//  LPDataStore+LPVisitor.m
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPDataStore+LPVisitor.h"

@implementation LPDataStore (LPVisitor)

- (Firebase *)visitorEventsRef
{
    return [self.firebases objectForKey:@"visitor_events"];
}

- (void)identifyVisitor:(NSUUID *)uuid withExternalID:(NSString *)externalID
{
    NSDate *createdAt = [NSDate date];
    NSNumber *priority = @([createdAt timeIntervalSince1970]);
    NSDictionary *eventInfo = @{@"type": @"setExternalId",
                                @"visitor_uuid": [uuid UUIDString],
                                @"external_id": externalID,
                                @"created_at": [createdAt description]};

    Firebase *visitor_event_ref = [[self visitorEventsRef] childByAutoId];
    [visitor_event_ref setValue:eventInfo andPriority:priority];
}

@end
