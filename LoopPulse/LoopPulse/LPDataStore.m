//
//  LPDataStore.m
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPDataStore.h"
#import "LPVisitor.h"

@interface LPDataStore ()
@property (readonly, retain) NSString *token;
@property (nonatomic, retain) LPVisitor *visitor;
@end

@implementation LPDataStore

- (id)initWithToken:(NSString *)token baseUrl:(NSString *)baseUrl andVisitor:(LPVisitor *)visitor
{
    self = [super init];
    if (self) {
        _token = token;
        _firebase = [[Firebase alloc] initWithUrl:baseUrl];
        _visitor = visitor;
    }
    return self;
}

- (NSUUID *)visitorUUID
{
    return self.visitor.uuid;
}

@end
