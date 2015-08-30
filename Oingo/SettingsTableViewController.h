//
//  SettingsTableViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 6/12/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UISwitch *linkTwitterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *linkFacebookSwitch;
- (IBAction)linktwitter:(id)sender;
- (IBAction)linkfacebook:(id)sender;
- (IBAction)logout:(id)sender;

@end
