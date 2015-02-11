//
//  MBAppDelegate.m
//  MegaBox
//
//  Created by Simon Pang on 3/7/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LoopPulse/LoopPulse.h"
#import <CoreLocation/CoreLocation.h>

#import "MBAppDelegate.h"
#import "MBLogsViewController.h"
#import "MBCoreDataController.h"
#import "MBLogController.h"

@interface MBAppDelegate ()
@property (strong, strong, nonatomic) MBCoreDataController *coreDataController;
@property (strong, nonatomic) MBLogController *logController;
@end

@implementation MBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.coreDataController = [[MBCoreDataController alloc] init];
    [LoopPulse setApplicationId:@"HHog73MZQh3Wb8hTJ" withToken:@"wefijoweifj"];

    if (![LoopPulse isAuthenticated]) {
        [LoopPulse authenticate:^(NSError *error) {
            if (error == nil) {
                NSString *alertMessage = @"Loop Pulse is authenticated.";
                [self postLocalNotification:alertMessage];

                int points = arc4random() % 2000;
                [LoopPulse tagVisitorWithProperities:@{@"membership": @{@"tier": @"gold", @"points": @(points)}}];
                [LoopPulse startLocationMonitoring];
            } else {
                NSString *alertMessage = [@"Loop Pulse failed to authenticate: " stringByAppendingString:error.description];
                [self postLocalNotification:alertMessage];
            }
        }];
    }

//    self.logController = [[MBLogController alloc] init];
//    self.logController.loopPulse = [LoopPulse sharedInstance];
//    self.logController.managedObjectContext = self.coreDataController.managedObjectContext;

    [self requestNotificationPermission];
    [self observeLoopPulse];

    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    MBLogsViewController *controller = (MBLogsViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.coreDataController.managedObjectContext;

    return YES;
}

- (void)requestNotificationPermission
{
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
}

- (void)observeLoopPulse
{
    // CoreLocation beacon events
    NSArray *regionNotifications = @[LoopPulseLocationDidEnterRegionNotification,
                                     LoopPulseLocationDidExitRegionNotification];
    for (NSString *name in regionNotifications) {
        [[NSNotificationCenter defaultCenter] addObserverForName:name
                                                          object:[LoopPulse sharedInstance]
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *notification){

                                                          NSDictionary *userInfo = notification.userInfo;
                                                          NSString *eventType = [userInfo objectForKey:@"eventType"];
                                                          CLBeaconRegion *region = [userInfo objectForKey:@"beaconRegion"];
                                                          NSString *eventShortForm = @"";
                                                          if ([eventType isEqualToString:@"didEnterRegion"]) {
                                                              eventShortForm = @"Enter";
                                                          } else if ([eventType isEqualToString:@"didExitRegion"]) {
                                                              eventShortForm = @"Exit";
                                                          }

                                                          NSString *alertMessage = [eventShortForm stringByAppendingFormat:@" %@", region.description];
                                                          [self postLocalNotification:alertMessage];
                                                          [self.logController addEventWithType:eventType andMsg:alertMessage];
                                                      }];
    }
}

- (void)postLocalNotification:(NSString *)alertMessage
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = alertMessage;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

// IOS >= 8
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [LoopPulse didRegisterUserNotificationSettings:notificationSettings withApplication:application];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [LoopPulse didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [LoopPulse didReceiveRemoteNotification:userInfo];
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