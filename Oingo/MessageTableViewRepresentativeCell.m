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
//#import <Crashlytics/Crashlytics.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "CongressionalMessageItem.h"
#import "CongressPhotoFinderAPI.h"


@interface MessageTableViewRepresentativeCell () <UIGestureRecognizerDelegate>

@end

@implementation MessageTableViewRepresentativeCell

- (void) configMessageCellLocalRep:congressionalMessageItem indexPath:(NSIndexPath*)indexPath {
    
    //Assign message item
    self.congressionalMessageItem = congressionalMessageItem;
    
    if([[self.congressionalMessageItem valueForKey:@"isCollapsed"]  isEqual: @YES]){
        
        NSLog(@"isCollapsed congress cell:%@",[self.congressionalMessageItem valueForKey:@"isCollapsed"]);
        //hide everything bc row height is zero
        self.targetName.hidden = YES;
        self.targetTitleLabel.hidden = YES;
        self.messageImage.hidden = YES;
        self.sendCount.hidden = YES;
        
        self.tweetButton.hidden = YES;
        self.tweetSuccessImageView.hidden = YES;
        self.emailButton.hidden = YES;
        self.emailSuccessImageView.hidden = YES;
        self.phoneButton.hidden = YES;
        self.webFormButton.hidden = YES;
        
        self.zipCodeButton.hidden = YES;
        self.locationButton.hidden = YES;
        self.zipLabel.hidden = YES;
    
    }else {

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
        //Email
        NSNumber *sendEmailNumberBool = [congressionalMessageItem valueForKey:@"isEmailSent"];
        bool sendEmailBool = [sendEmailNumberBool boolValue];
        if(sendEmailBool) {
            self.emailSuccessImageView.hidden = NO;
        } else {
            self.emailSuccessImageView.hidden = YES;
        }
        
        //Twitter
        NSNumber *sendTweetNumberBool = [congressionalMessageItem valueForKey:@"isTweetSent"];
        bool sendTweetBool = [sendTweetNumberBool boolValue];
        
        if(sendTweetBool) {
            self.tweetSuccessImageView.hidden = NO;
        } else {
            self.tweetSuccessImageView.hidden = YES;
        }
        
        //Phone call
        NSNumber *sendPhoneNumberBool = [congressionalMessageItem valueForKey:@"isPhoneSent"];
        //NSLog(@"mark phone triggered");
        bool sendPhoneBool = [sendPhoneNumberBool boolValue];
        if(sendPhoneBool) {
            self.phoneSuccessImageView.hidden = NO;
        } else {
            self.phoneSuccessImageView.hidden = YES;
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
        
        NSString *imageString = [self.congressionalMessageItem valueForKey:@"messageImageString"];
        self.messageImage.image = [UIImage imageNamed:imageString];
        self.messageImage.layer.borderWidth = .5;
        self.messageImage.layer.borderColor = [[UIColor blackColor] CGColor];
        self.messageImage.clipsToBounds = YES;
        self.messageImage.layer.cornerRadius = 3;
    }
        [self setNeedsDisplay];
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

//- (void)prepareForReuse {
//    [super prepareForReuse];
//    for(UIView *subview in [self.contentView subviews]) {
//        [subview removeFromSuperview];
//    }
//}


@end
