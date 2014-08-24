//
//  LPEngagementViewController.h
//  LoopPulse
//
//  Created by Thomas Pun on 8/24/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPEngagementViewController : UIViewController <UIWebViewDelegate>

- (id)initWithEngagement:(NSDictionary *)engagementInfo;
- (void)presentEngagement;

@end
