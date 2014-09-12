//
//  MBAppDelegate.h
//  MegaBox
//
//  Created by Simon Pang on 3/7/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBCoreDataController, MBLogController, LoopPulse;

@interface MBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) MBCoreDataController *coreDataController;
@property (readonly, strong, nonatomic) MBLogController *logController;

@end
