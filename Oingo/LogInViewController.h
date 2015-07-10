//
//  LogInViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 6/5/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageTableViewController.h"
#import "UpdateDefaults.h"

@interface LogInViewController : UIViewController

@property(nonatomic) MessageTableViewController *messageTableViewController;
@property(nonatomic) UpdateDefaults *updateDefaults;


@end
