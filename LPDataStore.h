//
//  LPDataStore.h
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>

@class LPVisitor;

@interface LPDataStore : NSObject

- (id)initWithToken:(NSString *)token;

@property (readonly, retain) NSString *token;
@property (readonly, retain) Firebase *firebase;
@property (nonatomic, retain) LPVisitor *visitor;

@end