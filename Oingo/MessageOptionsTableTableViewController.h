//
//  MessageOptionsTableTableViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 5/29/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageTableViewController.h"

@interface MessageOptionsTableTableViewController : UITableViewController
@property (nonatomic) NSArray *menuList;
@property (nonatomic) NSArray *messageOptionsList;
@property(nonatomic) NSMutableArray *messageOptionsListFiltered;
@property (nonatomic) NSString *category;
@property(nonatomic) MessageTableViewController *messageTableViewController;
@property(nonatomic) NSIndexPath *originIndexPath;
@property(nonatomic) NSNumber *originRowIndex;


@end
