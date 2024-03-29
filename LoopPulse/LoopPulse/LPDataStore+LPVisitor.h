//
//  LPDataStore+LPVisitor.h
//  LightHouse
//
//  Created by Thomas Pun on 5/11/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPDataStore.h"

@interface LPDataStore (LPVisitor)

- (void)identifyVisitor:(NSUUID *)uuid withExternalID:(NSString *)externalID;
- (void)tagVisitor:(NSUUID *)uuid withProperties:(NSDictionary *)properties;
- (void)trackVisitor:(NSUUID *)uuid withEventName:(NSString *)eventName andProperties:(NSDictionary *)properties;

@end
