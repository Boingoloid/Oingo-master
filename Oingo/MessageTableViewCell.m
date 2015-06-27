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

- (void) configMessageCellLocalRep:congressionalMessageItem indexPath:(NSIndexPath*)indexPath {
        NSLog(@"rep cell");
    
    //Assign message item
    self.congressionalMessageItem = congressionalMessageItem;
    
    //Hide all other fields
    self.locationButton.hidden = YES;
    self.zipCodeButton.hidden = YES;
    self.zipLabel.hidden = YES;
    
    self.messageText.hidden = NO;
    self.targetName.hidden = NO;
    self.targetTitleLabel.hidden = NO;
    self.messageImage.hidden = NO;
    self.sendCount.hidden = YES;
    self.tweetButton.hidden = NO;
    
    self.emailButton.hidden = NO;
    self.phoneButton.hidden = NO;
    self.webFormButton.hidden = NO;
    
    //add information
    self.messageText.text = [congressionalMessageItem valueForKey:@"messageText"];
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
    NSString *fileString = [NSString stringWithFormat:@"pelosi.png"];
    NSString *imageString = self.congressionalMessageItem.messageImageString;
    NSLog(@"imagestring::%@",imageString);
    self.messageImage.image = [UIImage imageNamed:imageString];
    NSLog(@"messageImagestring:%@",fileString);
}


- (void) configMessageCell:messageItem indexPath:(NSIndexPath*)indexPath {
    NSLog(@"normal cell");
    
    //Assign message item
    self.messageItem = messageItem;
    
    //Hide fields
    self.zipCodeButton.hidden = YES;
    self.emailButton.hidden = YES;
    self.phoneButton.hidden = YES;
    self.webFormButton.hidden = YES;
    
    //add information
    self.messageText.text = [messageItem valueForKey:@"messageText"];
    self.targetName.text = [NSString stringWithFormat:@"%@ /",[messageItem valueForKey:@"targetName"]];
    self.targetTitleLabel.text = [messageItem valueForKey:@"targetTitle"];
    
    //load program image from Parse and format
    PFFile *theImage = [messageItem objectForKey:@"messageImage"];
    NSData *imageData = [theImage getData];
    UIImage *image = [UIImage imageWithData:imageData];
    self.messageImage.image = image;
    self.messageImage.layer.borderWidth = 1.0;
    self.messageImage.layer.borderColor = [[UIColor blackColor] CGColor];
    self.messageImage.layer.cornerRadius = 3.0;
    self.messageImage.clipsToBounds = YES;
}

- (void) configMessageCellNoZip:(NSIndexPath*)indexPath {
    NSLog(@"no zip cell");
    self.zipCodeButton.hidden = NO;
    
    //Hide all other fields
    self.messageText.hidden = YES;
    self.targetName.hidden = YES;
    self.targetTitleLabel.hidden = YES;
    self.messageImage.hidden = YES;
    self.sendCount.hidden = YES;
    self.tweetButton.hidden = YES;
    self.emailButton.hidden = YES;
    self.phoneButton.hidden = YES;
    self.webFormButton.hidden = YES;
    
    //Create Zip look up UI
    //Add current location look up button
    self.locationButton = [[UIButton alloc]initWithFrame:CGRectMake(110, 5, 20, 20)];
    [self.locationButton setBackgroundImage:[UIImage imageNamed:@"location-gray.png"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.locationButton];
    
    //Add label accompanying text entry
    self.zipLabel = [[UILabel alloc]initWithFrame:CGRectMake(159, 8, 150, 15)];
    self.zipLabel.text = @"or";
    self.zipLabel.font = [UIFont boldSystemFontOfSize:13];
    self.zipLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.zipLabel];
    
    //Add button to look up local representatives
    self.zipCodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];  //must have! or won't show
    self.zipCodeButton.frame = CGRectMake(200, 5, 63, 20);
    self.zipCodeButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.zipCodeButton.layer.borderWidth = .5;
    self.zipCodeButton.layer.cornerRadius = 8;
    self.zipCodeButton.clipsToBounds = YES;
    [self.zipCodeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.zipCodeButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0]];
    [self.zipCodeButton setBackgroundImage:[UIImage imageNamed:@"lightGrayButtonBackground.png"] forState:UIControlStateNormal];
    [self.zipCodeButton setTitle:@"Look up" forState:UIControlStateNormal];
    [self.contentView addSubview:self.zipCodeButton];
    
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
