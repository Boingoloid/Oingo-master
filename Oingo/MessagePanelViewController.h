//
//  MessagePanelViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 10/6/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageTableViewController.h"

@interface MessagePanelViewController : UIViewController
@property(nonatomic) MessageTableViewController *messageTableViewController;
@property (nonatomic) NSArray *messageOptionsList;
@property (weak, nonatomic) IBOutlet UITextView *linkToContent;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *loadMessageButton;
@property (weak, nonatomic) IBOutlet UISwitch *includeLinkToggle;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UILabel *charCountLabel;
@property (nonatomic) NSMutableArray *sentMessagesForSegment;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *tableData;
@property (nonatomic) NSMutableArray *hashtagList;
@property (nonatomic) NSMutableArray *tableSourceArray;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tableSegmentControl;



@property(nonatomic,copy) NSArray *menuList;
@property(nonatomic,copy) NSString *category;
@property (nonatomic) NSMutableDictionary *selectedMessageDictionary;


@property(nonatomic) Program *selectedProgram;
@property(nonatomic) Segment *selectedSegment;


@property(nonatomic) NSIndexPath *originIndexPath;
@property(nonatomic) NSNumber *originRowIndex;

- (IBAction)loadMessage:(id)sender;
- (IBAction)toggleIncludeLink:(id)sender;
- (IBAction)cancel:(id)sender;

- (IBAction)sendToSignIn:(id)sender;
- (IBAction)tableSegmentControlClick:(id)sender;

@end
