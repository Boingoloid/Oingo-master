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
#import "Campaign.h"
#import "MessageTableViewCell.h"

@interface FacebookAPIPost : NSObject
@property (nonatomic) MessageTableViewController *messageTableViewController;
@property (nonatomic) Campaign *selectedCampaign;
@property (nonatomic) Program *selectedProgram;
-(void)shareSegmentFacebookAPI;
-(void)shareMessageFacebookAPI:(MessageTableViewCell*)cell;
@end