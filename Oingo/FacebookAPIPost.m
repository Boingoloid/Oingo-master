//
//  FacebookAPIPost.m
//  Oingo
//
//  Created by Matthew Acalin on 7/2/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "FacebookAPIPost.h"
#import <Accounts/Accounts.h>
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "MessageItem.h"
#import "CongressionalMessageItem.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


#import "MessageTableViewController.h"


@implementation FacebookAPIPost


-(void)shareSegmentFacebookAPI {    //if statement below
    //1) logged in?, if not send to sign up screen
    //2) else if logged in, link account to facebook account, then send post
    //3) else send post b/c signed up and linked already.
    PFUser *currentUser = [PFUser currentUser];
    if(!currentUser) {
        [self pushToSignIn];
    } else if(![PFFacebookUtils isLinkedWithUser:currentUser]){
        [self linkUserToFacebook:currentUser];
        NSLog(@"user account not linked to facebook");
    } else {
        [self shareSegmentWithFacebookComposer];
    }
}

-(void) pushToSignIn{
    UIViewController *controller = [self.messageTableViewController.storyboard instantiateViewControllerWithIdentifier:@"signInViewController"];
    [self.messageTableViewController.navigationController pushViewController:controller animated:YES];
}

-(void)linkUserToFacebook:currentUser{
    
    [PFFacebookUtils linkUserInBackground:currentUser withPublishPermissions:@[@"publish_actions"] block:^(BOOL succeeded, NSError *error) {
        if(error){
            NSLog(@"There was an issue linking your facebook account. Please try again.");
        }
        else {
            NSLog(@"facebook account is linked");
            //Send the facebook status update
            [self shareSegmentWithFacebookComposer];
        }
    }];
}

-(void)shareSegmentWithFacebookComposer{
    
    FBSDKShareLinkContent *content = [FBSDKShareLinkContent new];
    content.contentURL = [NSURL URLWithString:[self.selectedCampaign valueForKey:@"linkToContent"]];
    content.contentTitle = [self.selectedProgram valueForKey:@"programTitle"];
    content.contentDescription = [self.selectedCampaign valueForKey:@"purposeSummary"];
    FBSDKShareDialog *shareDialog = [FBSDKShareDialog new];
    [shareDialog setMode:FBSDKShareDialogModeAutomatic];
    [shareDialog setShareContent:content];
    [shareDialog setFromViewController:self.messageTableViewController];
    [shareDialog show];
    
}

-(void)shareMessageFacebookAPI:(MessageTableViewCell*)cell{
    //1) logged in?, if not send to sign up screen
    //2) else if logged in, link account to facebook account, then send post
    //3) else send post b/c signed up and linked already.
    PFUser *currentUser = [PFUser currentUser];
    if(!currentUser) {
        [self pushToSignIn];
    } else if(![PFFacebookUtils isLinkedWithUser:currentUser]){
        [self linkUserToFacebook:currentUser];
    } else {
        [self shareSegmentWithFacebookComposer];
    }

}




@end
