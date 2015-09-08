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

@interface FacebookAPIPost () //<FBSDKSharingDelegate>

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
        [self publishFBPost]; //publish
    } else {
        NSLog(@"no publish permissions"); // no publish permissions so get them, then post
        
        
        [PFFacebookUtils linkUserInBackground:[PFUser currentUser]
                       withPublishPermissions:@[ @"publish_actions"]
                                        block:^(BOOL succeeded, NSError *error) {
                                            if (succeeded) {
                                                NSLog(@"User now has read and publish permissions!");
                                                [self publishFBPost];
                                            }
        }];

        
//        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
//        [loginManager logInWithPublishPermissions:@[@"publish_actions"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//            if(error){
//                NSLog(@"publish permissions not working, not active");
//            } else {
//                NSLog(@"publish permissions now active");
//                
//                //save new permissions to parse
//                
//
//            }
//        }];
    }
}

-(void) publishFBPost{
//    FBSDKShareLinkContent *content = [FBSDKShareLinkContent new];
//    content.contentURL = [NSURL URLWithString:[self.selectedSegment valueForKey:@"linkToContent"]];
//    content.contentTitle = [self.selectedProgram valueForKey:@"programTitle"];
//    content.contentDescription = [self.selectedSegment valueForKey:@"purposeSummary"];
//    
//    PFFile *theImage = [self.selectedSegment valueForKey:@"segmentImage"];
//    NSString *urlString = theImage.url;
//    NSURL *url = [NSURL URLWithString:urlString];
//    content.imageURL = url;
//    
//    FBSDKShareDialog *shareDialog = [FBSDKShareDialog new];
//    
//    [shareDialog setMode:FBSDKShareDialogModeAutomatic];
////    [FBSDKShareDialog showFromViewController:self.messageTableViewController withContent:content delegate:self];
//    [shareDialog setShareContent:content];
//    [shareDialog setDelegate:self];
//    [shareDialog setFromViewController:self.messageTableViewController];
//    [shareDialog show];


//
//    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
//    content.contentURL = [NSURL URLWithString:@"https://developers.facebook.com"];
    
//        PFFile *segmentImage = [self.selectedSegment objectForKey:@"segmentImage"];
//        NSString *segmentImageUrlString = segmentImage.url;
//
//    PFFile *theImage = self.selectedSegment.linkToContent;
//    NSData *imageData = [theImage getData];
//    UIImage *image = [UIImage imageWithData:imageData];
    
    
    NSString *postText = [NSString stringWithFormat:@"%@: %@",[self.selectedProgram valueForKey:@"programTitle"],[self.selectedSegment valueForKey:@"segmentTitle"]];  // Everything is the same except for this line.

//    PFFile *theImage = [self.selectedSegment valueForKey:@"segmentImage"];
//    NSString *segmentImageString =  theImage.name;
    
    NSString *linkToContent =[[NSString alloc]initWithString:[self.selectedSegment valueForKey:@"linkToContent"]];

    NSDictionary *parameters = @{//@"message" : postText,
                                 @"link" : linkToContent,
                                 @"name" : postText
                                 };
        [[[FBSDKGraphRequest alloc]
          initWithGraphPath:@"me/feed"
          parameters: parameters
          HTTPMethod:@"POST"]
         //list of parameters: https://developers.facebook.com/docs/graph-api/reference/
         //
         
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"Post id:%@", result[@"id"]);
             }
         }];
}

//#pragma mark - delegate methods
//
//- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
////    if ([sharer isEqual:self.shareDialog]) {
//    NSString *facebookPostID = [results valueForKey:@"ID"];
//    [self saveSentMessageSegment:facebookPostID];
//    NSLog(@"facebook post successful%@",results);
//        
//        // Your delegate code
////    }
//}
//
//- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
//{
//    NSLog(@"sharing error:%@", error);
//    NSString *message = error.userInfo[FBSDKErrorLocalizedDescriptionKey] ?:
//    @"There was a problem sharing, please try again later.";
//    NSString *title = error.userInfo[FBSDKErrorLocalizedTitleKey] ?: @"Oops!";
//    
//    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//}
//
//- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
//{
//    NSLog(@"share cancelled");
//}



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
            [self.messageTableViewController viewDidLoad];
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
