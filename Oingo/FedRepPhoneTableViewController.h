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
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;

// Data from MessageTVC
@property(nonatomic) Program *selectedProgram;
@property(nonatomic) Segment *selectedSegment;
@property(nonatomic) NSMutableDictionary *selectedActionDict;
@property(nonatomic) FederalRepActionDashboardViewController *tableViewController;

@property (nonatomic) NSArray *actionsForSegment;
@property (nonatomic) NSArray *sentActionsForSegment;
@property (nonatomic) NSMutableArray *fedRepList;

- (IBAction)segmentedControlCommunicationTypeClick:(id)sender;


@end
