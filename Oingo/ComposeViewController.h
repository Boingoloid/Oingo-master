//
//  ComposeViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 9/8/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageTableViewController.h"

@interface ComposeViewController : UIViewController

@property(nonatomic) MessageTableViewController *messageTableViewController;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *linkToContent;
@property(nonatomic) Program *selectedProgram;
@property(nonatomic) Segment *selectedSegment;

- (IBAction)send:(id)sender;
- (IBAction)cancel:(id)sender;


@end
