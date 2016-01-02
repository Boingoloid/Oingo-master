//
//  FederalRepActionDashboardViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 12/17/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionDashboardTableViewController.h"



@interface FederalRepActionDashboardViewController : UIViewController

// Data from MessageTVC
@property(nonatomic) Program *selectedProgram;
@property(nonatomic) Segment *selectedSegment;
@property(nonatomic) NSMutableDictionary *selectedActionDict;
@property(nonatomic) ActionDashboardTableViewController *tableViewController;

// Controls
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *shortcutActionIconImageView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderTextLabel;
@property (weak, nonatomic) IBOutlet UITextView *pushthoughtTextView;
@property (weak, nonatomic) IBOutlet UILabel *otherOptionsLabel;

@property (weak, nonatomic) IBOutlet UIImageView *sendTweet;
@property (weak, nonatomic) IBOutlet UIButton *sendTweetIcon;
@property (weak, nonatomic) IBOutlet UILabel *sendTweetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *clearTouchAreaImageView;

// tableview
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *tableData;
@property (nonatomic) NSMutableArray *hashtagList;
@property (nonatomic) NSMutableArray *tableSourceArray;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tableSegmentControl;

@property (nonatomic) NSArray *actionsForSegment;
@property (nonatomic) NSArray *sentActionsForSegment;

// Created with Fetched Data
@property (nonatomic) NSMutableArray *fedRepList;
@property (nonatomic) NSMutableArray *sentMessagesForSegment;

@end
