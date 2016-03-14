//
//  ActionDashboardTableViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 12/11/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Segment.h"
#import "Program.h"
#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "UpdateDefaults.h"
#import "ProgramDetailTableViewController.h"
#import "FetchDataParse.h"

@interface ActionDashboardTableViewController : UITableViewController

// Data from MessageTVC
@property(nonatomic) Program *selectedProgram;
@property(nonatomic) Segment *selectedSegment;
@property(nonatomic) ProgramDetailTableViewController *programDetailTVC;

// Controls
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *programTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *tableFooterView;
@property (weak, nonatomic) IBOutlet UIView *playContentTouchArea;


// Variables
@property (weak, nonatomic) NSString *alertMessage;
@property (weak, nonatomic) NSString *zipCodeSubmission;


// Fetched Data
@property (nonatomic) NSArray *actionsForSegment;
@property (nonatomic) NSArray *sentActionsForSegment;

//Created
@property (nonatomic) NSMutableArray *actionOptionsArray;
@property (nonatomic) NSMutableDictionary *selectedActionDict;
@property (nonatomic) NSMutableArray *contacts;

@end
