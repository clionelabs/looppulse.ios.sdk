//
//  LPDataStore.m
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPDataStore.h"

@interface LPDataStore ()
@property (readonly, retain) NSString *token;
@end

@implementation LPDataStore
- (id)initWithToken:(NSString *)token
{
    self = [super init];
    if (self) {
        _token = token;
    }
    return self;
}
@end
