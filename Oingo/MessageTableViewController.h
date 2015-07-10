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

@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionToCategoryMap;
@property(nonatomic) Campaign *selectedCampaign;
@property(nonatomic,copy) NSMutableArray *messageList;
@property(nonatomic,copy) NSArray *menuList;
@property(nonatomic,copy) NSMutableArray *messageTextList;
@property (nonatomic,copy) NSArray *messageTextListNonMutable;
@property(nonatomic,copy) NSArray *messageOptionsList;
@property (nonatomic) NSArray *dataImmutable;
@property(nonatomic) NSMutableArray *messageListIncludingReps;
@property(nonatomic) NSString *repMessageText;
@property(nonatomic) NSString *selectedLink;
@property(nonatomic) Program *selectedProgram;
@property (weak, nonatomic) IBOutlet UILabel *tableHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *tableHeaderSubLabel;
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
@property(nonatomic) PFUser *currentUser;
@property(nonatomic) BOOL isRepsLoaded;
- (IBAction)shareSegmentTwitter:(id)sender;
- (IBAction)shareSegmentFacebook:(id)sender;
- (void)lookUpZip;
- (void)getUserLocation;


-(NSString *) categoryForSection:(NSInteger)section;
@end
