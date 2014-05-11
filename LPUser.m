//
//  LPUser.m
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPUser.h"

@interface LPUser ()
@property (readonly, retain) NSUUID *uuid;
@property (readonly, retain) LPDataStore *dataStore;
@end

@implementation LPUser
- (id)initWithDataStore:(LPDataStore *)dataStore
{
    self = [super init];
    if (self) {
        _uuid = [[UIDevice currentDevice] identifierForVendor];
        _dataStore = dataStore;
    }
    return self;
}
@end
