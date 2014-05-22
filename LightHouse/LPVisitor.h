//
//  LPVisitor.h
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPDataStore.h"

@interface LPVisitor : NSObject

- (id)initWithDataStore:(LPDataStore *)dataStore;
- (void)identifyWithExternalID:(NSString *)externalID;

@property (readonly, retain) NSUUID *uuid;
@end
