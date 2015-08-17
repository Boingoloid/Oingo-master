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
                self.sentMessagesForSegment = objects;

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self checkTwitterShareForSegment];
                    [self checkTwitterShareForContacts];
                    NSLog(@"Mark sent is reloading tableview");
                    
                    
//                  [self.messageTableViewController.view setNeedsDisplay];
//                  [self.messageTableViewController.tableView reloadData];

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
                // Do nothing
            } else {
                // Makes check mark visible on twitter message button
                [[self.messageTableViewController.menuList objectAtIndex:index] setValue:@YES forKey:@"isTweetSent"];
            }
        }
        
    }
    [self.messageTableViewController.tableView reloadData];
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
            NSLog(@"INDEX FOUND, unhide segment tweet success");
            self.messageTableViewController.segmentTweetButtonSuccessImageView.hidden = NO;
            
            
        }

    
    
}

@end
