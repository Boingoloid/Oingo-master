//
//  MarkSentMessageAPI.m
//  Oingo
//
//  Created by Matthew Acalin on 7/21/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "MarkSentMessageAPI.h"


@implementation MarkSentMessageAPI


-(void)markSentMessages{
    NSLog(@"Mark Sent Triggerd");
    PFUser *currentUser = [PFUser currentUser];
    
    if(!currentUser) {
        NSLog(@"No user signed in");
    } else {
        
        NSString *selectedSegmentID = [self.messageTableViewController.selectedSegment valueForKey:@"segmentID"];
        NSString *userObjectID = currentUser.objectId;
        
        
        //get message data for segment menu
        PFQuery *query = [PFQuery queryWithClassName:@"sentMessages"];
        [query whereKey:@"segmentID" equalTo:selectedSegmentID];

        [query whereKey:@"userObjectID" equalTo:userObjectID];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                self.sentMessagesForSegment = objects;
                    [self checkTwitterShareForSegment];
                    [self checkTwitterShareForContacts];
                    [self checkFacebookShareForSegment];
                    [self checkLongFormEmail];
                    [self checkEmail];
                    [self checkPhone];
                    NSLog(@"reloading data from MarkSentMessages");
                    [self.messageTableViewController.tableView reloadData];
                });
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}

-(void)checkTwitterShareForContacts {
    
    for (NSDictionary *dictionary in self.sentMessagesForSegment) {
        if ([[dictionary valueForKey:@"messageType"] isEqualToString:@"twitter"]){

            // if twitter I need to grab contact id and flag twitter icon on cell in menulist.
            NSString *contactID = [dictionary valueForKey:@"contactID"];
            NSArray *menuList = self.messageTableViewController.menuList;
            
            
            // find the index in menulist where contact is, change flag for twitter icon
            NSUInteger index = [menuList indexOfObjectPassingTest:
                                ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                    return [[dict valueForKey:@"contactID"] isEqualToString:contactID];  //but is it called contact id in menulist?
                                }];
            if(index == NSNotFound){
                //NSLog(@"no index sent found, contactID:%@ / messageType:%@",[dictionary valueForKey:@"contactName"],[dictionary valueForKey:@"messageType"]);
                // Do nothing
            } else {
                // Makes check mark visible on twitter message button
                //NSLog(@"found: marking index that is found, contactID:%@ / messageType:%@",[dictionary valueForKey:@"contactName"],[dictionary valueForKey:@"messageType"]);
                [[self.messageTableViewController.menuList objectAtIndex:index] setValue:@YES forKey:@"isTweetSent"];
            }
        }
    }
}

-(void)checkTwitterShareForSegment {
    NSUInteger index = [self.sentMessagesForSegment indexOfObjectPassingTest:
                            ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                return [[dict objectForKey:@"messageType"] isEqual:@"twitterSegmentOnly"];
                            }];
        if(index == NSNotFound){
            // Do nothing
        } else {
            // Makes check mark visible on twitter button
            //NSLog(@"INDEX FOUND, unhide segment tweet success");
            self.messageTableViewController.segmentTweetButtonSuccessImageView.hidden = NO;
        }
}

-(void)checkFacebookShareForSegment {
    NSUInteger index = [self.sentMessagesForSegment indexOfObjectPassingTest:
                        ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                            return [[dict objectForKey:@"messageType"] isEqual:@"facebookSegmentOnly"];
                        }];
    if(index == NSNotFound){
        // Do nothing
    } else {
        // Makes check mark visible on twitter button
        //NSLog(@"INDEX FOUND, unhide segment facebook success");
        self.messageTableViewController.segmentFacebookButtonSuccessImageView.hidden = NO;
    }
}

-(void)checkLongFormEmail {
    for (NSDictionary *dictionary in self.sentMessagesForSegment) {
        if ([[dictionary valueForKey:@"messageType"] isEqualToString:@"Long Form Email"]){
            
            // if long form email I need to grab contact id and email icon on cell in menulist.

            NSArray *menuList = self.messageTableViewController.menuList;            
            
            // find the index in menulist where contact is, change flag for twitter icon
            NSUInteger index = [menuList indexOfObjectPassingTest:
                                ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                    return [[dict valueForKey:@"messageCategory"] isEqualToString:@"Long Form Email"];  //but is it called contact id in menulist?
                                }];
            
            if(index == NSNotFound){
                //NSLog(@"no index sent found");
                // Do nothing
            } else {
                [[self.messageTableViewController.menuList objectAtIndex:index] setValue:@YES forKey:@"isLongFormEmailSent"];
            }
        }
    }

}

-(void)checkEmail{
    for (NSDictionary *dictionary in self.sentMessagesForSegment) {
        if ([[dictionary valueForKey:@"messageType"] isEqualToString:@"email"]){
            
            // if email I need to grab contact id and flag twitter icon on cell in menulist.
            NSString *contactID = [dictionary valueForKey:@"contactID"];
            NSArray *menuList = self.messageTableViewController.menuList;
            
            
            // find the index in menulist where contact is, change flag for twitter icon
            NSUInteger index = [menuList indexOfObjectPassingTest:
                                ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                    return [[dict valueForKey:@"contactID"] isEqualToString:contactID];  //but is it called contact id in menulist?
                                }];
            
            if(index == NSNotFound){
                //NSLog(@"no index sent found");
                // Do nothing
            } else {
                // Makes check mark visible on twitter message button
                //NSLog(@"found: marking index that is found %lu",(unsigned long)index);
                [[self.messageTableViewController.menuList objectAtIndex:index] setValue:@YES forKey:@"isEmailSent"];
            }
        }
    }
}

-(void)checkPhone{
    for (NSDictionary *dictionary in self.sentMessagesForSegment) {
        if ([[dictionary valueForKey:@"messageType"] isEqualToString:@"phoneCall"]){
            
            // if phone need to grab contact id and flag twitter icon on cell in menulist.
            NSString *contactID = [dictionary valueForKey:@"contactID"];
            NSArray *menuList = self.messageTableViewController.menuList;
            
            // find the index in menulist where contact is, change flag for twitter icon
            NSUInteger index = [menuList indexOfObjectPassingTest:
                                ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                    return [[dict valueForKey:@"contactID"] isEqualToString:contactID];  //but is it called contact id in menulist?
                                }];
            
            if(index == NSNotFound){
                //NSLog(@"no index sent found");
                // Do nothing
            } else {
                // Makes check mark visible on twitter message button
                //NSLog(@"found: marking index that is found %lu",(unsigned long)index);
                [[self.messageTableViewController.menuList objectAtIndex:index] setValue:@YES forKey:@"isPhoneSent"];
            }
        }
    }
}


@end
