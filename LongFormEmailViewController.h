//
//  LongFormEmailViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 10/7/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Segment.h"
#import "MessageTableViewController.h"

@interface LongFormEmailViewController : UIViewController
@property (nonatomic) MessageTableViewController *messageTableViewController;
@property (nonatomic) Segment *selectedSegment;

@property (nonatomic) NSString *emailSubject;
@property (nonatomic) NSString *emailBody;
@property (nonatomic) NSString *emailRecipients;

@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;

- (void)showMailPicker;
@end
