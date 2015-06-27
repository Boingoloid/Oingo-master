//
//  ProgramDetailTableViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 5/4/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Program.h"
#import "Campaign.h"

@interface ProgramDetailTableViewController : UITableViewController


@property (nonatomic,strong) Program *selectedProgram;
@property (nonatomic) NSArray *campaignList;
@property (nonatomic) Campaign *selectedCampaign;
@property (nonatomic) NSString *selectedLink;



@end
