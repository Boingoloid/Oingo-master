//
//  MessageTableViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 5/11/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Campaign.h"
#import "Program.h"
#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface MessageTableViewController : UITableViewController

@property(nonatomic) Campaign *selectedCampaign;
@property(nonatomic) NSArray *messageList;
@property(nonatomic) NSMutableArray *messageListIncludingReps;
@property(nonatomic) NSString *selectedLink;
@property(nonatomic) Program *selectedProgram;
@property (weak, nonatomic) IBOutlet UILabel *tableHeaderLabel;
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
@property(nonatomic) PFUser *currentUser;
@property(nonatomic) NSString *zipCode;
@property(nonatomic) BOOL isRepsLoaded;
- (IBAction)shareSegmentTwitter:(id)sender;
- (IBAction)shareSegmentFacebook:(id)sender;
- (void)lookUpZip;
- (void)getUserLocation;

-(void)prepSections:array;
-(NSString *) categoryForSection:(NSInteger)section;
@end
