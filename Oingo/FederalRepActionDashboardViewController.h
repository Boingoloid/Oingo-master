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
@property(nonatomic) ActionDashboardTableViewController *tableViewController;


// Controls
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderTextLabel;
@property (weak, nonatomic) IBOutlet UITextView *pushthoughtTextView;
@property (weak, nonatomic) IBOutlet UILabel *otherOptionsLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Created with Fetched Data
@property (nonatomic) NSMutableArray *fedRepList;




@end
