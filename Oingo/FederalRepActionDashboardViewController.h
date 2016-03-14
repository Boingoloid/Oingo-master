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
@property(nonatomic) NSMutableArray *contacts;
@property(nonatomic) NSMutableArray *contactsForAction;
@property(nonatomic) ActionDashboardTableViewController *tableViewController;

// Controls
@property (weak, nonatomic) IBOutlet UILabel *breadcrumbsLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControlCommunicationType;
@property (weak, nonatomic) IBOutlet UIImageView *linkCheckbox;
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
@property (weak, nonatomic) IBOutlet UIImageView *buttonContainerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *textViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *characterCount;
@property (weak, nonatomic) IBOutlet UIImageView *linkTouchArea;
@property (nonatomic) int linkState;
@property (weak, nonatomic) IBOutlet UILabel *tableViewTitleLabel;


// tableview
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *tableData;
@property (nonatomic) NSMutableArray *collectionData;
@property (nonatomic) NSMutableArray *hashtagList;
@property (nonatomic) NSMutableArray *tableSourceArray;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControlTableView;
- (IBAction)segmentedControlTableViewClick:(id)sender;


@property (nonatomic) NSArray *actionsForSegment;
@property (nonatomic) NSArray *sentActionsForSegment;
@property (nonatomic) NSMutableArray *filteredActionsForSegment;
@property (nonatomic) NSMutableArray *filteredSentActionsForSegment;
@property (nonatomic) NSMutableArray *filteredSentActionsForSegmentWithCount;

// Created with Fetched Data
@property (nonatomic) NSMutableArray *fedRepList;
@property (nonatomic) NSMutableArray *sentMessagesForSegment;

- (void)textViewDidChange:(UITextView *)textView;
- (IBAction)segmentedControlCummunicationTypeClick:(id)sender;
-(void)formatSentMessageData;


@end
