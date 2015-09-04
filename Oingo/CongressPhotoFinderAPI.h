//
//  CongressPhotoFinderAPI.h
//  Oingo
//
//  Created by Matthew Acalin on 6/24/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MessageTableViewController.h"
#import "MessageTableViewCell.h"

@interface CongressPhotoFinderAPI : NSObject

@property(nonatomic) MessageTableViewCell *tableViewCell;
@property(nonatomic) MessageTableViewController *messageTableViewController;

-(void)getPhotos:(NSArray*)congressMessageList;





@end
