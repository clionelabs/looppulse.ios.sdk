//
//  LPVisitor.m
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPVisitor.h"
#import "LPDataStore+LPVisitor.h"

@interface LPVisitor ()
@property (readonly, retain) LPDataStore *dataStore;
- (id)initWithDataStore:(LPDataStore *)dataStore;
@end

@implementation LPVisitor

- (id)initWithDataStore:(LPDataStore *)dataStore
{
    self = [super init];
    if (self) {
        _uuid = [[UIDevice currentDevice] identifierForVendor];
        _dataStore = dataStore;
        [self register];
    }
    return self;
}

- (void)register
{
    [self.dataStore registerVisitor:self.uuid];
}

- (void)identifyWithExternalID:(NSString *)externalID
{
    [self.dataStore identifyVisitor:self.uuid withExternalID:externalID];
}

@end
