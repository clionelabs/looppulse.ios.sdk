//
//  MBAppDelegate.m
//  MegaBox
//
//  Created by Simon Pang on 3/7/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LoopPulse/LoopPulse.h"
#import "MBAppDelegate.h"
#import "MBLogsViewController.h"
#import "MBCoreDataController.h"
#import "MBLogController.h"

@interface MBAppDelegate ()
@property (strong, nonatomic) LoopPulse *loopPulse;
@property (strong, strong, nonatomic) MBCoreDataController *coreDataController;
@property (strong, nonatomic) MBLogController *logController;
@end

@implementation MBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.coreDataController = [[MBCoreDataController alloc] init];

    // Initialize LoopPulse using debug option to change firebase URL
    self.loopPulse = [[LoopPulse alloc] initWithApplicationId:@"9ZFXQ2WXipQKWEP8h" withToken:@"QoLK2gs9LHL3yI4-BKQu"];
    [self.loopPulse authenticate:^(void) {
        [self.loopPulse startLocationMonitoring];
        [self.loopPulse registerForRemoteNotificationTypesForApplication:application];
    }];

    self.logController = [[MBLogController alloc] init];
    self.logController.loopPulse = self.loopPulse;
    self.logController.managedObjectContext = self.coreDataController.managedObjectContext;
    [self.logController startLogMonitoring];

    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    MBLogsViewController *controller = (MBLogsViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.coreDataController.managedObjectContext;

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self.loopPulse didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self.loopPulse didReceiveRemoteNotification:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.coreDataController saveContext];
}

@end