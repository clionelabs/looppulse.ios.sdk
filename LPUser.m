//
//  LPUser.m
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPUser.h"

@interface LPUser ()
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSUUID *uuid;
@end

@implementation LPUser
- (id)initWithToken:(NSString *)token
{
    self = [super init];
    if (self) {
        self.token = token;
        self.uuid = [[UIDevice currentDevice] identifierForVendor];
    }
    return self;
}
@end
