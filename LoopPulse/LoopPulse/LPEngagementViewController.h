//
//  LPEngagementViewController.h
//  LoopPulse
//
//  Created by Thomas Pun on 8/24/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPEngagement.h"

@interface LPEngagementViewController : UIViewController <UIWebViewDelegate>

- (id)initWithEngagement:(LPEngagement *)engagement;
- (void)presentEngagement;

@end
