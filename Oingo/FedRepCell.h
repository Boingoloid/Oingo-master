//
//  FedRepCell.h
//  Oingo
//
//  Created by Matthew Acalin on 12/17/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FederalRepActionDashboardViewController.h"

@interface FedRepCell : UITableViewCell


@property (nonatomic) FederalRepActionDashboardViewController *viewController;
@property (weak, nonatomic) IBOutlet UILabel *tableViewPrimaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *tableViewSecondaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *tableViewNameLabel;

-(FedRepCell*)configCell:(NSMutableDictionary*)actionDict;
    
@end
