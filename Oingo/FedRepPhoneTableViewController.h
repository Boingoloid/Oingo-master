//
//  FedRepPhoneTableViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 1/19/16.
//  Copyright © 2016 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FederalRepActionDashboardViewController.h"


@interface FedRepPhoneTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControlCommunicationType;
@property (weak, nonatomic) IBOutlet UIView *promptView;
@property (nonatomic) NSString *promptText;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UIButton *openEmailDraftButton;
- (IBAction)openEmailDraftClick:(id)sender;

// Data from MessageTVC
@property(nonatomic) Program *selectedProgram;
@property(nonatomic) Segment *selectedSegment;
@property(nonatomic) NSMutableDictionary *selectedActionDict;
@property(nonatomic) FederalRepActionDashboardViewController *tableViewController;

@property (nonatomic) NSArray *actionsForSegment;
@property (nonatomic) NSArray *sentActionsForSegment;
@property (nonatomic) NSMutableArray *fedRepList;
@property (nonatomic) NSMutableArray *collectionData;
@property (nonatomic) int segmentedControlValue;

// Tableview
@property (nonatomic) NSMutableArray *tableViewData;


- (IBAction)segmentedControlCommunicationTypeClick:(id)sender;


@end
