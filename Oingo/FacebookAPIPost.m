//
//  FacebookAPIPost.m
//  Oingo
//
//  Created by Matthew Acalin on 7/2/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "FacebookAPIPost.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "MessageItem.h"
#import "CongressionalMessageItem.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SignUpViewController.h"



#import "MessageTableViewController.h"

@interface FacebookAPIPost () <FBSDKSharingDelegate>

@end


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



-(void)shareMessageFacebookAPI:(MessageTableViewCell*)cell{
    //1) logged in?, if not send to sign up screen
    //2) else if logged in, link account to facebook account, then send post
    //3) else send post b/c signed up and linked already.
    //You cannot pre-populate on facebook so this is just like sharing the segment.
    PFUser *currentUser = [PFUser currentUser];
    if(!currentUser) {
        [self pushToSignIn];
    } else if(![PFFacebookUtils isLinkedWithUser:currentUser]){
        [self linkUserToFacebook:currentUser];
    } else {
        [self shareSegmentWithFacebookComposer];
    }
    
}

-(void)shareSegmentWithFacebookComposer{
    
//    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
//    
//    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
//    content.contentURL = [NSURL URLWithString:@"https://developers.facebook.com"];
//                          
//        [[[FBSDKGraphRequest alloc]
//          initWithGraphPath:@"me/feed"
//          parameters: @{ @"message" : @"hello world"}
//          HTTPMethod:@"POST"]
//         
//         
//         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//             if (!error) {
//                 NSLog(@"Post id:%@", result[@"id"]);
//             }
//         }];
//    }
    
    
    FBSDKShareLinkContent *content = [FBSDKShareLinkContent new];
    content.contentURL = [NSURL URLWithString:[self.selectedSegment valueForKey:@"linkToContent"]];
    content.contentTitle = [self.selectedProgram valueForKey:@"programTitle"];
    content.contentDescription = [self.selectedSegment valueForKey:@"purposeSummary"];
    
    FBSDKShareDialog *shareDialog = [FBSDKShareDialog new];
    [shareDialog setMode:FBSDKShareDialogModeAutomatic];
    [shareDialog setShareContent:content];
    [shareDialog setFromViewController:self.messageTableViewController];
    [shareDialog show];
    
    self.shareCodeDialog = [FBSDKShareDialog new];
    [self.shareCodeDialog setDelegate:(id)self];
    [self.shareCodeDialog setShareContent:content];
    [self.shareCodeDialog setFromViewController:self.messageTableViewController];
    [self.shareCodeDialog show];
}

-(void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    
        // Your delegate code
        NSLog(@"I'm going to go crazy if this doesn't work.");
    
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    NSLog(@"sharing error:%@", error);
    NSString *message = error.userInfo[FBSDKErrorLocalizedDescriptionKey] ?:
    @"There was a problem sharing, please try again later.";
    NSString *title = error.userInfo[FBSDKErrorLocalizedTitleKey] ?: @"Oops!";
    
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    NSLog(@"share cancelled");
}



// Figure out how to get success message from facebook.  May have to use REST API.
//-(void) saveSentMessage{
//    
//    //  SAVING MESSAGE DATA TO PARSE
//    PFUser *currentUser = [PFUser currentUser];
//    
//    PFObject *sentMessageItem = [PFObject objectWithClassName:@"sentMessages"];
//    [sentMessageItem setObject:@"facebookSegment" forKey:@"messageType"];
//    [sentMessageItem setObject:[self.selectedSegment valueForKey:@"segmentID"] forKey:@"segmentID"];
//    [sentMessageItem setObject:[currentUser valueForKey:@"username"] forKey:@"username"];
//    NSString *userObjectID = currentUser.objectId;
//    [sentMessageItem setObject:userObjectID forKey:@"userObjectID"];
//    
//    NSLog(@"Got here in the save, should have segmentID:%@",sentMessageItem);
//    
//    [sentMessageItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //save currentUser to parse disk
//        if(error){
//            NSLog(@"error, message not saved");
//        }
//        else {
//            NSLog(@"no error, message saved");
//        }
//    }];
//    
//    NSLog(@"Got here in the save 2:%@",sentMessageItem);
//}


-(void) pushToSignIn{
    SignUpViewController *signUpViewController = [self.messageTableViewController.storyboard instantiateViewControllerWithIdentifier:@"signInViewController"];
    signUpViewController.messageTableViewController = self.messageTableViewController;
    [self.messageTableViewController.navigationController pushViewController:signUpViewController animated:YES];
    NSLog(@"message view controller as signup pushed:%@ and %@",self.messageTableViewController,signUpViewController.messageTableViewController);

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

@end
