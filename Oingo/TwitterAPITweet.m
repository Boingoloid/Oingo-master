//
//  TwitterAPITweet.m
//  Oingo
//
//  Created by Matthew Acalin on 7/2/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "TwitterAPITweet.h"
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import <TwitterKit/TwitterKit.h>
#import <Fabric/Fabric.h>
#import "PFTwitterUtils+NativeTwitter.h"
#import <Accounts/Accounts.h>

@implementation TwitterAPITweet

-(void)shareSegmentTwitterAPI {
    //if statement below
    //1) logged in?, if not send to sign up screen
    //2) else if logged in, link account to twitter account, then send tweet
    //3) else send tweet b/c signed up and linked already.
    PFUser *currentUser = [PFUser currentUser];
    if(!currentUser) {
        [self pushToSignIn];
    } else if(![PFTwitterUtils isLinkedWithUser:currentUser]){
        NSLog(@"user account not linked to twitter");
        [self linkUserToTwitter:currentUser];
    } else {
        [self shareSegmentWithTwitterComposer];
    }
}

-(void)shareSegmentWithTwitterComposer{
    NSString *tweetText = [NSString stringWithFormat:@"%@: %@",[self.selectedProgram valueForKey:@"programTitle"],[self.selectedCampaign valueForKey:@"topicTitle"]];
    NSURL *tweetURL = [NSURL URLWithString:[self.selectedCampaign valueForKey:@"linkToContent"]];
    PFFile *theImage = [self.selectedCampaign valueForKey:@"campaignImage"];
    NSData *imageData = [theImage getData];
    UIImage *image = [UIImage imageWithData:imageData];
    
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    [composer setText:tweetText];
    [composer setURL:tweetURL];
    [composer setImage:image];
    [composer showWithCompletion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Tweet composition cancelled");
        } else {
            NSLog(@"Tweet is sent.");
        }
    }];
}


-(void) pushToSignIn {
    UIViewController *controller = [self.messageTableViewController.storyboard instantiateViewControllerWithIdentifier:@"signInViewController"];
    [self.messageTableViewController.navigationController pushViewController:controller animated:YES];
    
}

-(void)linkUserToTwitter:currentUser{
    [PFTwitterUtils linkUser:currentUser block:^(BOOL succeeded, NSError *error) {
        if(error){
            NSLog(@"There was an issue linking your twitter account. Please try again.");
        }
        else {
            [self shareSegmentWithTwitterComposer];
            
        }
    }];
}


- (void)shareMessageTwitterAPI:(MessageTableViewCell *)cell {
    //Check if user logged in
    PFUser *currentUser = [PFUser currentUser];
    if(!currentUser) {  //if user not logged in, then go to signUpInScreen
        [self pushToSignIn];
        
        //if logged in but not linked
    } else if(![PFTwitterUtils isLinkedWithUser:currentUser]){
        NSLog(@"user account not linked to twitter");
        [PFTwitterUtils linkUser:currentUser block:^(BOOL succeeded, NSError *error) {
            if(error){
                NSLog(@"There was an issue linking your twitter account. Please try again.");
            }
            else {
                NSLog(@"twitter account is linked");
                [self shareMessageWithTwitterComposer];
            }
        }];
    } else {
        //Send the tweet
        [self shareMessageWithTwitterComposer];
    }
}


-(void)shareMessageWithTwitterComposer {
    //Send the tweet
    NSString *tweetText = [NSString stringWithFormat:@"%@: %@",[self.selectedProgram valueForKey:@"programTitle"],[self.selectedCampaign valueForKey:@"topicTitle"]]; //This needs to CHANGE TO READ MESSAGE!!
    NSURL *tweetURL = [NSURL URLWithString:[self.selectedCampaign valueForKey:@"linkToContent"]];
    PFFile *theImage = [self.selectedCampaign valueForKey:@"campaignImage"];
    NSData *imageData = [theImage getData];
    UIImage *image = [UIImage imageWithData:imageData];
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    [composer setText:tweetText];
    [composer setURL:tweetURL];
    [composer setImage:image];
    [composer showWithCompletion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Tweet composition cancelled");
        } else {
            NSLog(@"Tweet is sent.");
        }
    }];
    
    
}


@end
