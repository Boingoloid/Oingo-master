//
//  MessageTableViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 5/11/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Segment.h"
#import "Program.h"
#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "UpdateDefaults.h"


@interface MessageTableViewController : UITableViewController

@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionToCategoryMap;
@property(nonatomic) Segment *selectedSegment;
@property(nonatomic,copy) NSMutableArray *messageList;
@property(nonatomic,copy) NSArray *menuList;
@property (nonatomic, retain) NSMutableArray *expandSectionsKeyList;
@property(nonatomic,copy) NSMutableArray *messageTextList;
@property (nonatomic,copy) NSArray *messageTextListNonMutable;
@property(nonatomic,copy) NSArray *messageOptionsList;
@property (nonatomic) NSArray *dataImmutable;
@property(nonatomic) NSMutableArray *messageListWithCongress;
@property(nonatomic) NSArray *congressMessageList;
@property(nonatomic) NSString *repMessageText;
@property(nonatomic) NSString *selectedLink;
@property(nonatomic) Program *selectedProgram;
@property(nonatomic) NSDictionary *selectedContact;
@property (weak, nonatomic) IBOutlet UILabel *tableHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *tableHeaderSubLabel;
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
@property(nonatomic) PFUser *currentUser;
@property(nonatomic) BOOL isCongressLoaded;
@property(nonatomic) UpdateDefaults *updateDefaults;
@property(nonatomic) BOOL isSentFromCongressFinderAPI;



// segment buttons
@property (weak, nonatomic) IBOutlet UIButton *segmentTweetButton;
@property (weak, nonatomic) IBOutlet UIButton *segmentFacebookButton;

// success images
@property (weak, nonatomic) IBOutlet UIImageView *segmentTweetButtonSuccessImageView;
@property (weak, nonatomic) IBOutlet UIImageView *segmentFacebookButtonSuccessImageView;

// Settings
- (IBAction)viewSettings:(id)sender;

//Segment share actions
- (IBAction)shareSegmentTwitter:(id)sender;
- (IBAction)shareSegmentFacebook:(id)sender;

//Location actions
- (void)lookUpZip;
- (void)getUserLocation;

- (IBAction)showCompose:(id)sender;

-(NSString *) categoryForSection:(NSInteger)section;
@end
