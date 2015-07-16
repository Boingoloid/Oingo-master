//
//  ProgramDetailTableViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 5/4/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Program.h"
#import "Segment.h"

@interface ProgramDetailTableViewController : UITableViewController


@property (nonatomic,strong) Program *selectedProgram;
@property (nonatomic) NSArray *segmentList;
@property (nonatomic) Segment *selectedSegment;
@property (nonatomic) NSString *selectedLink;
@property (nonatomic) NSIndexPath *indexPath;



@end
