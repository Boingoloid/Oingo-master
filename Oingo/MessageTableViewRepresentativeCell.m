//
//  MessageTableViewRepresentativeCell.m
//  Oingo
//
//  Created by Matthew Acalin on 6/29/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "MessageTableViewRepresentativeCell.h"
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MessageTableViewController.h"
#import "MessageItem.h"
#import <QuartzCore/QuartzCore.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <TwitterKit/TwitterKit.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "CongressionalMessageItem.h"
#import "CongressPhotoFinderAPI.h"


@interface MessageTableViewRepresentativeCell () <UIGestureRecognizerDelegate>

@end

@implementation MessageTableViewRepresentativeCell

CongressPhotoFinderAPI *congressPhotoFinderAPI;

- (void) configMessageCellLocalRep:congressionalMessageItem indexPath:(NSIndexPath*)indexPath {
    
    //Assign message item
    self.congressionalMessageItem = congressionalMessageItem;
    
    

    self.targetName.hidden = NO;
    self.targetTitleLabel.hidden = NO;
    self.tweetButton.hidden = NO;
    self.emailButton.hidden = NO;
    self.phoneButton.hidden = NO;
    self.webFormButton.hidden = NO;
    self.messageImage.hidden = NO;
    
    // Hide all other fields
    self.locationButton.hidden = YES;
    self.zipCodeButton.hidden = YES;
    self.zipLabel.hidden = YES;
    self.sendCount.hidden = YES;
    

    // Success fields
    NSNumber *sendTweetNumberBool = [congressionalMessageItem valueForKey:@"isTweetSent"];
    bool sendTweetBool = [sendTweetNumberBool boolValue];
    NSLog(@"is tweet sent:%@",[congressionalMessageItem valueForKey:@"isTweetSent"]);
    if(sendTweetBool) {
        self.tweetSuccessImageView.hidden = NO;
    } else {
        self.tweetSuccessImageView.hidden = YES;
    }
    
    // Add information from congressional message iterm to properties of cell
    self.targetName.text = [NSString stringWithFormat:@"%@ /",[congressionalMessageItem valueForKey:@"fullName"]];
    self.targetTitleLabel.text = [congressionalMessageItem valueForKey:@"title"];
    self.contantForm = [self.congressionalMessageItem valueForKey:@"contactForm"];
    self.phone = [self.congressionalMessageItem valueForKey:@"phone"];
    self.website = [self.congressionalMessageItem valueForKey:@"website"];
    self.openCongressEmail = [self.congressionalMessageItem valueForKey:@"openCongressEmail"];
    self.youtubeID = [self.congressionalMessageItem valueForKey:@"youtubeID"];
    self.facebookID = [self.congressionalMessageItem valueForKey:@"facebookID"];
    self.twitterID = [self.congressionalMessageItem valueForKey:@"twitterID"];
    self.inOffice = [self.congressionalMessageItem valueForKey:@"inOffice"];
    self.gender = [self.congressionalMessageItem valueForKey:@"gender"];
    self.birthday = [self.congressionalMessageItem valueForKey:@"birthday"];
    self.chamber = [self.congressionalMessageItem valueForKey:@"chamber"];
    self.district = [self.congressionalMessageItem valueForKey:@"district"];
    self.stateName = [self.congressionalMessageItem valueForKey:@"stateName"];
    self.state = [self.congressionalMessageItem valueForKey:@"state"];
    self.leadershipRole = [self.congressionalMessageItem valueForKey:@"twitterID"];
    
    //add image
    //    NSString *bioguideID = [congressionalMessageItem valueForKey:@"bioguide_id"];
    //    [congressPhotoFinderAPI getPhotos:bioguideID];
    //    congressPhotoFinderAPI.tableViewCell = self;
    
    NSString *imageString = [self.congressionalMessageItem valueForKey:@"messageImageString"];
    self.messageImage.image = [UIImage imageNamed:imageString];
    self.messageImage.layer.borderWidth = .5;
    self.messageImage.layer.borderColor = [[UIColor blackColor] CGColor];
    self.messageImage.clipsToBounds = YES;
    self.messageImage.layer.cornerRadius = 3;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame {
    int inset = 10;
    frame.origin.x += inset; //equal to saying originx = originx + inset
    frame.size.width -= 2 * inset; //mult by 2 b/c taking from both sides
    [super setFrame:frame];
    
}


@end
