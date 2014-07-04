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
#import <Parse/Parse.h>

@interface MBAppDelegate ()
@property (strong, nonatomic) LoopPulse *loopPulse;
@property (strong, strong, nonatomic) MBCoreDataController *coreDataController;
@property (strong, nonatomic) MBLogController *logController;
@end

@implementation MBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [Parse setApplicationId:@"dP9yJQI58giCirVVIYeVd1YobFbIujv5wDFWA8WX"
                  clientKey:@"hnz5gkWZ45cJkXf8yp2huHc89NG55O1ajjHSrwxh"];
    
    self.coreDataController = [[MBCoreDataController alloc] init];

    // Initialize LoopPulse using debug option to change firebase URL
    self.loopPulse = [[LoopPulse alloc] initWithToken:@"testing" options:@{@"baseUrl" : @"https://looppulse-megabox.firebaseio.com"}];
    [self.loopPulse startLocationMonitoringAndRanging];

    self.logController = [[MBLogController alloc] init];
    self.logController.loopPulse = self.loopPulse;
    self.logController.managedObjectContext = self.coreDataController.managedObjectContext;
    [self.logController startLogMonitoring];

    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    MBLogsViewController *controller = (MBLogsViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.coreDataController.managedObjectContext;
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"Register for device token succssed: %@ ", deviceToken);
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    NSString *visitorUUID = self.loopPulse.visitor.uuid.UUIDString;
    [currentInstallation addUniqueObject:visitorUUID forKey:@"channels"];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
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