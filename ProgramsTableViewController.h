//
//  ProgramsTableViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 4/25/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Program.h"


@interface ProgramsTableViewController : UITableViewController
@property (nonatomic) NSArray *programList;
@property (nonatomic) NSArray *programListFromDatabase;
@property (nonatomic,strong) Program *selectedProgram;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray *filteredList;


@end
