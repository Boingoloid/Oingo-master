//
//  SettingsTableViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 6/12/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageTableviewController.h"

@interface SettingsTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UISwitch *linkTwitterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *linkFacebookSwitch;
@property (weak, nonatomic) MessageTableViewController *messageTableViewController;
@property (weak, nonatomic) IBOutlet UIButton *enterZipButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *leaveFeedbackButton;
- (IBAction)linktwitter:(id)sender;
- (IBAction)linkfacebook:(id)sender;
- (IBAction)logout:(id)sender;

//Location actions, here as button actions
- (IBAction)getUserLocation:(id)sender;
- (IBAction)lookUpZip:(id)sender;

@end
