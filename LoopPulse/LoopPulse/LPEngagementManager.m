//
//  LPEngagementManager.m
//  LoopPulse
//
//  Created by Thomas Pun on 8/7/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import "LPEngagementManager.h"
#import <Parse/Parse.h>

@interface LPEngagementManager ()
@property (nonatomic, retain) LPVisitor *visitor;
@property (readonly, weak) UIApplication *application;
@end

@implementation LPEngagementManager

- (id)initWithVisitor:(LPVisitor *)visitor andApplication:(UIApplication *)application
{
    self = [super init];
    if (self) {
        _visitor = visitor;
        _application = application;
    }
    return self;
}

- (void)registerForRemoteNotificationTypes
{
    [self.application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound];
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"Register for device token succssed: %@ ", deviceToken);
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    NSString *visitorUUID = [@"VisitorUUID_" stringByAppendingString:self.visitor.uuid.UUIDString];
    [currentInstallation addUniqueObject:visitorUUID forKey:@"channels"];
    [currentInstallation saveInBackground];
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}
@end
