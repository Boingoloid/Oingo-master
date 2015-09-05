//
//  MessageTableViewCell.m
//  Oingo
//
//  Created by Matthew Acalin on 5/11/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "MessageTableViewCell.h"
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



@interface MessageTableViewCell () <UIGestureRecognizerDelegate>

@end


@implementation MessageTableViewCell

CongressPhotoFinderAPI *congressPhotoFinderAPI;



- (void) configMessageContactCell:messageItem indexPath:(NSIndexPath*)indexPath {
    
    //Assign message item
    self.messageItem = messageItem;
    
    
    
//    if([[self.messageItem valueForKey:@"isCollapsed"]  isEqual: @YES]){
//        
//        NSLog(@"isCollapsed contact cell:%@",[self.messageItem valueForKey:@"isCollapsed"]);
//        //hide everything bc row height is zero
//        self.targetName.hidden = YES;
//        self.targetTitleLabel.hidden = YES;
//        self.messageImage.hidden = YES;
//        self.sendCount.hidden = YES;
//        
//        self.tweetButton.hidden = YES;
//        self.tweetSuccessImageView.hidden = YES;
//        self.emailButton.hidden = YES;
//        self.phoneButton.hidden = YES;
//        self.webFormButton.hidden = YES;
//        
//        self.zipCodeButton.hidden = YES;
//        self.locationButton.hidden = YES;
//        self.zipLabel.hidden = YES;
//        
//    } else {
    
    
    
        //unhide fields
        self.targetName.hidden = NO;
        self.targetTitleLabel.hidden = NO;
        self.messageImage.hidden = NO;
        self.sendCount.hidden = NO;
        self.tweetButton.hidden = NO;
        
        //Hide fields
        self.zipCodeButton.hidden = YES;
        self.locationButton.hidden = YES;
        self.zipLabel.hidden = YES;

        self.emailButton.hidden = YES;
        self.phoneButton.hidden = YES;
        self.webFormButton.hidden = YES;
        self.tweetSuccessImageView.hidden = YES;
        self.emailSuccessImageView.hidden = YES;

    
    // Success fields
        //Twitter
        NSNumber *sendTweetNumberBool = [messageItem valueForKey:@"isTweetSent"];
        bool sendTweetBool = [sendTweetNumberBool boolValue];
        if(sendTweetBool) {
            self.tweetSuccessImageView.hidden = NO;
        } else {
            self.tweetSuccessImageView.hidden = YES;
        }
    
        //Email
        NSNumber *sendEmailNumberBool = [messageItem valueForKey:@"isEmailSent"];
        bool sendEmailBool = [sendEmailNumberBool boolValue];
        if(sendEmailBool) {
            self.emailSuccessImageView.hidden = NO;
        } else {
            self.emailSuccessImageView.hidden = YES;
        }
    
        //Phone call
        NSNumber *sendPhoneNumberBool = [messageItem valueForKey:@"isPhoneSent"];
        bool sendPhoneBool = [sendPhoneNumberBool boolValue];
        if(sendPhoneBool) {
            self.phoneSuccessImageView.hidden = NO;
        } else {
            self.phoneSuccessImageView.hidden = YES;
        }
    
        //add information
        self.targetName.text = [NSString stringWithFormat:@"%@ /",[messageItem valueForKey:@"targetName"]];
        self.targetTitleLabel.text = [messageItem valueForKey:@"targetTitle"];
        
        //load program image from Parse and format
        self.messageImage.image = [messageItem objectForKey:@"messageImage"];
        self.messageImage.layer.borderWidth = .5;
        self.messageImage.layer.borderColor = [[UIColor blackColor] CGColor];
        self.messageImage.layer.cornerRadius = 3.0;
        self.messageImage.clipsToBounds = YES;
    [self setNeedsDisplay];
//    }
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
