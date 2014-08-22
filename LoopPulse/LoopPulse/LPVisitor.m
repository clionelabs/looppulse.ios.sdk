//
//  LPVisitor.m
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPVisitor.h"
#import "LPDataStore+LPVisitor.h"
#import "LoopPulsePrivate.h"

@interface LPVisitor ()
@property (readonly, retain) LPDataStore *dataStore;
@end

@implementation LPVisitor

- (id)initWithDataStore:(LPDataStore *)dataStore
{
    self = [super init];
    if (self) {
        _uuid = [[UIDevice currentDevice] identifierForVendor];
        _dataStore = dataStore;
        [LoopPulse.defaults setObject:[_uuid UUIDString] forKey:@"visitorUUID"];
    }
    return self;
}

@end
