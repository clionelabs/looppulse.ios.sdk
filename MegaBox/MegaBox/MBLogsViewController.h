//
//  MBLogsViewController.h
//  MegaBox
//
//  Created by Simon Pang on 3/7/14.
//  Copyright (c) 2014 Clione Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface MBLogsViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
