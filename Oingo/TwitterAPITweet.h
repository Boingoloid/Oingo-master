//
//  TwitterAPITweet.h
//  Oingo
//
//  Created by Matthew Acalin on 7/2/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageTableViewController.h"
#import "Program.h"
#import "Segment.h"
#import "MessageTableViewCell.h"

@interface TwitterAPITweet : NSObject
@property (nonatomic) MessageTableViewController *messageTableViewController;
@property (nonatomic) Segment *selectedSegment;
@property (nonatomic) Program *selectedProgram;
@property (nonatomic) NSString *messageText;
@property (nonatomic) NSString *tweetText;
@property (nonatomic) NSArray *menuList;
@property (nonatomic) NSDictionary *selectedContact;
@property (nonatomic) NSDictionary *selectedMessageDictionary;

-(void)shareSegmentTwitterAPI;
-(void)shareMessageTwitterAPI:(UITableViewCell*)cell;
//-(void)shareTwitterAPIForSegment:(Segment*)selectedSegment fromCell:(UITableViewCell*)cell;
@end
