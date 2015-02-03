//
//  LoopPulsePrivate.h
//
//  Created by Thomas Pun on 8/22/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LoopPulse.h"

@interface LoopPulse ()

@property (readonly, nonatomic) NSString *captureId;
@property (readonly, nonatomic) BOOL isComponentsInitialized; // keep track of whether LP components (e.g. dataStore) has been initialized with server authenticated response

+ (NSUserDefaults *)defaults;
+ (void)postNotification:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
- (void)track:(NSString *)eventName withProperties:(NSDictionary *)properties;

@end
