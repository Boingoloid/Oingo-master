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
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SignUpViewController.h"
#import "MessageTableViewController.h"
#import "MarkSentMessageAPI.h"
#import "ComposeViewController.h"

@interface FacebookAPIPost ()

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
        NSLog(@"user account not linked to facebook");
        [self linkUserToFacebook:currentUser];
    } else {
        [self shareSegmentWithFacebookComposer];
    }
}

-(void)shareSegmentWithFacebookComposer{
    
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        [self.messageTableViewController performSegueWithIdentifier:@"showCompose" sender:self];
        //        [self publishFBPost]; //publish
    } else {
        NSLog(@"no publish permissions"); // no publish permissions so get them, then post
        
        
        [PFFacebookUtils linkUserInBackground:[PFUser currentUser]
                       withPublishPermissions:@[ @"publish_actions"]
                                        block:^(BOOL succeeded, NSError *error) {
                                            if (succeeded) {
                                                NSLog(@"User now has read and publish permissions!");
                                                [self.messageTableViewController performSegueWithIdentifier:@"showCompose" sender:self];

                                            }
        }];
    }
}

-(void) publishFBPostWithParameters:(NSDictionary*)parameters{

    
        [[[FBSDKGraphRequest alloc]
          initWithGraphPath:@"me/feed"
          parameters: parameters
          HTTPMethod:@"POST"]
         //list of parameters: https://developers.facebook.com/docs/graph-api/reference/
         //
         
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"Post id:%@", result[@"id"]);
                 [self saveSentMessageSegment:result[@"id"]];
                 [self.messageTableViewController.navigationController popViewControllerAnimated:YES];
             }
         }];
}



// Figure out how to get success message from facebook.  May have to use REST API.
//-(void) saveSentMessage{
//    
//    //  SAVING MESSAGE DATA TO PARSE
//    PFUser *currentUser = [PFUser currentUser];4
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

-(void) saveSentMessageSegment:(NSString*)postID{
    
    //  SAVING MESSAGE DATA TO PARSE
    PFUser *currentUser = [PFUser currentUser];
    PFObject *sentMessageItem = [PFObject objectWithClassName:@"sentMessages"];
    [sentMessageItem setObject:@"facebookSegmentOnly" forKey:@"messageType"];
    [sentMessageItem setObject:[self.selectedSegment valueForKey:@"segmentID"] forKey:@"segmentID"];
    [sentMessageItem setObject:[currentUser valueForKey:@"username"] forKey:@"username"];
    NSString *userObjectID = currentUser.objectId;
    [sentMessageItem setObject:userObjectID forKey:@"userObjectID"];
    [sentMessageItem setObject:postID forKey:@"facebookPostID"];
    
    [sentMessageItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //save sent message to parse
        if(error){
            NSLog(@"error, message not saved");
        }
        else {
            NSLog(@"no error, message saved");
            
            MarkSentMessageAPI *markSentMessagesAPI = [[MarkSentMessageAPI alloc]init];
            markSentMessagesAPI.messageTableViewController = self.messageTableViewController;
            [markSentMessagesAPI markSentMessages];
            
            
//            [self.messageTableViewController viewDidLoad];
        }
    }];
}

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
