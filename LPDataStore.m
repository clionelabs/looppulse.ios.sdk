//
//  LPDataStore.m
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPDataStore.h"

@implementation LPDataStore

- (id)initWithToken:(NSString *)token
{
    self = [super init];
    if (self) {
        _token = token;
        _firebase = [[Firebase alloc] initWithUrl:@"https://looppulse-dev.firebaseio.com"];
    }
    return self;
}

@end
