//
//  MessageTableViewCell.h
//  Oingo
//
//  Created by Matthew Acalin on 5/11/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageItem.h"
#import "CongressionalMessageItem.h"

@interface MessageTableViewCell : UITableViewCell

@property (assign, nonatomic) NSInteger cellIndex;
@property(nonatomic) MessageItem *messageItem;
@property(nonatomic) CongressionalMessageItem *congressionalMessageItem;
@property(nonatomic) NSString *messageImageString;
@property(nonatomic) NSString *email;
@property (weak, nonatomic) IBOutlet UILabel *targetName;
@property (weak, nonatomic) IBOutlet UILabel *sendCount;
@property (weak, nonatomic) IBOutlet UIImageView *messageImage;
@property (weak, nonatomic) IBOutlet UILabel *targetTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
@property (weak, nonatomic) IBOutlet UIButton *postToFacebookButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UIButton *webFormButton;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *website;
@property (nonatomic, retain) NSString *openCongressEmail;
@property (nonatomic, retain) NSString *youtubeID;
@property (nonatomic, retain) NSString *facebookID;
@property (nonatomic, retain) NSString *twitterID;
@property(nonatomic) NSString *contactForm;
@property (nonatomic, retain) NSString *inOffice;
@property (nonatomic, retain) NSString *gender;
@property (nonatomic, retain) NSString *birthday;
@property (nonatomic, retain) NSString *chamber;
@property (nonatomic, retain) NSString *district;
@property (nonatomic, retain) NSString *stateName;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *leadershipRole;

//Success Fields
@property (weak, nonatomic) IBOutlet UIImageView *tweetSuccessImageView;
@property (weak, nonatomic) IBOutlet UIImageView *emailSuccessImageView;
@property (weak, nonatomic) IBOutlet UIImageView *phoneSuccessImageView;

// Location Capture
@property(nonatomic) UIButton *locationButton;
@property(nonatomic) UIButton *zipCodeButton;
@property(nonatomic) UILabel *zipLabel;


// Touch Capture
@property (weak, nonatomic) IBOutlet UIImageView *phoneTouchCaptureImageView;
@property (weak, nonatomic) IBOutlet UIImageView *emailTouchCaptureImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tweetTouchCaptureImageView;
@property (weak, nonatomic) IBOutlet UIImageView *webFormTouchCaptureImageView;


- (void) configMessageContactCell:messageItem indexPath:(NSIndexPath*)indexPath;

@end
