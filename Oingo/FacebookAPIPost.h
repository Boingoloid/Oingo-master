//
//  FacebookAPIPost.h
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
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface FacebookAPIPost : UITableViewController
@property (nonatomic) MessageTableViewController *messageTableViewController;
@property (nonatomic) Segment *selectedSegment;
@property (nonatomic) Program *selectedProgram;
@property (nonatomic) NSDictionary *selectedContact;
@property (strong, nonatomic) FBSDKShareDialog *shareDialog;
-(void)shareSegmentFacebookAPI;
-(void)shareMessageFacebookAPI:(MessageTableViewCell*)cell;
@end
