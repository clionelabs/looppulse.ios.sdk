//
//  CLDetailViewController.h
//  LightHouse
//
//  Created by Thomas Pun on 4/13/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
