//
//  LoopPulsePrivate.h
//
//  Created by Thomas Pun on 8/22/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LoopPulse.h"

@interface LoopPulse ()

@property (readonly, nonatomic) NSString *captureId;

+ (NSUserDefaults *)defaults;
+ (void)postNotification:(NSString *)name withUserInfo:(NSDictionary *)userInfo;

@end
