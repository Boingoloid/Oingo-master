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
#import "SignUpViewController.h"
#import "LogInViewController.h"
#import "CongressionalMessageItem.h"

@implementation TwitterAPITweet

bool isUserLinkedToTwitter;

-(void)shareSegmentTwitterAPI {

    
    NSLog(@"Messageview controller share segment twitter api:%@",self.messageTableViewController);
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
    NSString *tweetText = [NSString stringWithFormat:@"%@: %@",[self.selectedProgram valueForKey:@"programTitle"],[self.selectedSegment valueForKey:@"segmentTitle"]];  // Everything is the same except for this line.
    NSURL *tweetURL = [NSURL URLWithString:[self.selectedSegment valueForKey:@"linkToContent"]];
    PFFile *theImage = [self.selectedSegment valueForKey:@"segmentImage"];
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
            NSLog(@"Tweet is sent, segment only.");
            [self saveSentMessageSegment];
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

    NSLog(@"selected contact print out:%@",self.selectedContact);
    NSString *twitterId = [self.selectedContact valueForKey:@"twitterID"];
    
    NSString *tweetText = [NSString stringWithFormat:@"@%@, %@ #pushthought",twitterId,self.messageText];
    NSURL *tweetURL = [NSURL URLWithString:[self.selectedSegment valueForKey:@"linkToContent"]];
    PFFile *theImage = [self.selectedSegment valueForKey:@"segmentImage"];
    NSData *imageData = [theImage getData];
    UIImage *image = [UIImage imageWithData:imageData];
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    [composer setText:tweetText];
    [composer setURL:tweetURL];
    [composer setImage:image];
    [composer showFromViewController:self.messageTableViewController completion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Tweet composition cancelled");
        } else {
            NSLog(@"Tweet is sent.");
            [self saveSentMessage];
            //Need to save tweet result ID in callBack
        }
    }];
}


-(void) saveSentMessageSegment{
    //  SAVING MESSAGE DATA TO PARSE
    PFUser *currentUser = [PFUser currentUser];
    PFObject *sentMessageItem = [PFObject objectWithClassName:@"sentMessages"];
    [sentMessageItem setObject:@"twitterSegmentOnly" forKey:@"messageType"];
    [sentMessageItem setObject:[self.selectedSegment valueForKey:@"segmentID"] forKey:@"segmentID"];
    [sentMessageItem setObject:[currentUser valueForKey:@"username"] forKey:@"username"];
    NSString *userObjectID = currentUser.objectId;
    [sentMessageItem setObject:userObjectID forKey:@"userObjectID"];
    
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


-(void) saveSentMessage{
    
//  SAVING MESSAGE DATA TO PARSE
    PFUser *currentUser = [PFUser currentUser];
    
    PFObject *sentMessageItem = [PFObject objectWithClassName:@"sentMessages"];
    [sentMessageItem setObject:self.messageText forKey:@"messageText"];
    [sentMessageItem setObject:@"twitter" forKey:@"messageType"];
    [sentMessageItem setObject:[self.selectedSegment valueForKey:@"segmentID"] forKey:@"segmentID"];
    [sentMessageItem setObject:[currentUser valueForKey:@"username"] forKey:@"username"];
        NSString *userObjectID = currentUser.objectId;
    [sentMessageItem setObject:userObjectID forKey:@"userObjectID"];
    
    //if segment then skip, else don't
    
    if ([self.selectedContact isKindOfClass:[CongressionalMessageItem class]]) {
        NSLog(@"Congressional Message Item Class");
        NSString *bioguide_id = [self.selectedContact valueForKey:@"bioguide_id"];
        NSString *fullName = [self.selectedContact valueForKey:@"fullName"];
        [sentMessageItem setObject:bioguide_id forKey:@"contactID"];
        [sentMessageItem setObject:fullName forKey:@"contactName"];
    } else {
        NSLog(@"Regular Contact Item Class");
        NSString *contactID = [self.selectedContact valueForKey:@"contactID"];
        NSString *targetName = [self.selectedContact valueForKey:@"targetName"];
        [sentMessageItem setObject:contactID forKey:@"contactID"];
        [sentMessageItem setObject:targetName forKey:@"contactName"];
    }
    
    [sentMessageItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //save currentUser to parse disk
        if(error){
            NSLog(@"error, message not saved");
        }
        else {
            NSLog(@"no error, message saved");
        }
    }];
    
    NSLog(@"Got here in the save 2:%@",sentMessageItem);
    [self.messageTableViewController viewDidLoad];
}


-(void) pushToSignIn {
    SignUpViewController *signUpViewController = [self.messageTableViewController.storyboard instantiateViewControllerWithIdentifier:@"signInViewController"];
    signUpViewController.messageTableViewController = self.messageTableViewController;
    [self.messageTableViewController.navigationController pushViewController:signUpViewController animated:YES];
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


// This is code from my attempt to refactor.  Put on hold.
//-(void)shareTwitterAPIForSegment:(Segment*)selectedSegment fromCell:(UITableViewCell*)cell {
//    
//    [self checkIfUserLoggedInAndLinkedToTwitter];
//    
//    if(!isUserLinkedToTwitter){
//        NSLog(@"There was an issue linking your twitter account. Please try again.");
//    } else {
//        [self shareMessageWithTwitterComposer];
//    }
//}
//
//
//- (void)checkIfUserLoggedInAndLinkedToTwitter {
//    //if statement below
//    //1) logged in?, if not send to sign up screen
//    //2) else if logged in, link account to twitter account, then send tweet
//    //3) else send tweet b/c signed up and linked already.
//    PFUser *currentUser = [PFUser currentUser];
//    if(!currentUser) {
//        [self pushToSignIn];
//    } else if(![PFTwitterUtils isLinkedWithUser:currentUser]){
//        [PFTwitterUtils linkUser:currentUser block:^(BOOL succeeded, NSError *error) {
//            if(error){
//                NSLog(@"There was an issue linking your twitter account. Please try again.");
//            }
//            else {
//                NSLog(@"twitter account is linked");
//                isUserLinkedToTwitter = YES;
//            }
//        }];
//        // User is logged in and linked
//    } else {
//        isUserLinkedToTwitter = YES;
//    }
//}

@end
