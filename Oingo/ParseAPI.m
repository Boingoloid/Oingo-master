//
//  ParseAPI.m
//  Oingo
//
//  Created by Matthew Acalin on 7/1/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "ParseAPI.h"
#import <Parse/Parse.h>
#import "Campaign.h"
#import "MessageItem.h"
#import "CongressionalMessageItem.h"
#import "CongressFinderAPI.h"



@interface ParseAPI ()

@end

@implementation ParseAPI

BOOL isMenuWithCustomOrdering = NO;






-(void)getParseMessageData:(Campaign*)selectedCampaign{  //get parse messge data for selectedCampaign
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"campaignID" equalTo:[selectedCampaign valueForKey:@"campaignID"]];
    [query orderByDescending:@"messageCategory"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.messageListFromParseWithContacts = (NSMutableArray*)objects;  //messageList has everything ordered by category

            //Loads parse data.  If there location, it load congress by coordinates first, then its tries zipCode
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if(![defaults valueForKey:@"latitude"] && ![defaults valueForKey:@"zipCode"]) { //if no location info, then just prep and load it.
                NSLog(@"Loading parse data with no congress peoeple");
                [self prepSections:objects];
                
            } else {
                CongressFinderAPI *congressFinder = [[CongressFinderAPI alloc]init];
                congressFinder.messageTableViewController = self.messageTableViewController;
                congressFinder.parseAPI = self;
                if([defaults valueForKey:@"latitude"] && [defaults valueForKey:@"longitude"]) {
                    [congressFinder getCongressWithLatitude:[defaults doubleForKey:@"latitude"] andLongitude:[defaults doubleForKey:@"longitude"] addToMessageList:(NSMutableArray*)self.messageListFromParseWithContacts];
                } else {
                    [congressFinder getCongress:[defaults valueForKey:@"zipCode"] addToMessageList:self.messageListFromParseWithContacts];
                }
            }
        }
    }];
}

-(void) separateMessagesFromContacts:(NSMutableArray*)messageList {
    
    NSMutableArray *messageListWithContactsSorted = [self sortMessageListWithContacts:messageList];
    //now have sorted list
    //now separate them
    
    NSMutableArray *messageTextList = [[NSMutableArray alloc]init];
    NSMutableArray *contactList = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dictionary in messageListWithContactsSorted) {
        NSNumber *isMessageNumber = [dictionary valueForKey:@"isMessage"];
        bool isMessageBool = [isMessageNumber boolValue];
        if(isMessageBool) {
            [messageTextList addObject:dictionary];
        }else {
            [contactList addObject:dictionary];
        }
    }
    self.messageTextList = messageTextList;
    self.contactList = contactList;
    
    
    NSLog(@"contactlist:%@ messageList: %@",contactList,messageTextList);
    
}


-(void)createMenuList{
    
    if(self.menuList) {
        [self.menuList removeAllObjects];
    } else {
    self.menuList = [[NSMutableArray alloc]init];
    }

    NSString *category = @"";
    NSUInteger contactIndex = 0;
    for (NSDictionary *contactRow in self.contactList) {
        if(category != [contactRow valueForKey:@"messageCategory"]){
            category = [contactRow valueForKey:@"messageCategory"];
            
            NSUInteger index = [self.messageTextList indexOfObjectPassingTest:
                                ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                    return [[dict objectForKey:@"messageCategory"] isEqual:category];
                                }];
            
            NSLog(@"index:%lu",(unsigned long)index);
            NSLog(@"category:%@",category);
            MessageItem *messageToAdd = [self.messageTextList objectAtIndex:index];
            NSLog(@"message to add:%@",messageToAdd);
            [self.menuList addObject:messageToAdd];
            [self.menuList addObject:contactRow];
        } else {
            [self.menuList addObject:contactRow];
        }
        
    contactIndex++;
    }
    NSLog(@"menulist:%@",self.menuList);
}


-(void) addLocalRepLocationCaptureCell:menuList{
    
    
    
    
    //add local rep message and no zip cell b/c no contacts in list.
    NSUInteger index = [self.menuList indexOfObjectPassingTest:
                        ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                            return [[dict objectForKey:@"messageCategory"] isEqual:@"Local Representative"];
                        }];
    if(index == NSNotFound){
        //add location capture cell reference for the tableview

        NSMutableDictionary *noZipDictionary = [[NSMutableDictionary alloc]init];
        [noZipDictionary setValue:@"Local Representative" forKey:@"messageCategory"];
        [noZipDictionary setValue:@YES forKey:@"isGetLocationCell"];
        NSLog(@"dictionary value for isGetLocationCell %@",[noZipDictionary valueForKey:@"isGetLocationCell"]);
        [menuList addObject:noZipDictionary];
        
        
        
        NSUInteger indexLocalRepMessage = [self.messageTextList indexOfObjectPassingTest:
                                           ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                               return [[dict objectForKey:@"messageCategory"] isEqual:@"Local Representative"];
                                           }];
        [self.menuList addObject:[self.messageTextList objectAtIndex:indexLocalRepMessage]];
    }
}

-(void)prepSections:messageList {
    NSLog(@"Prep sections triggered");
    
    //add message to this list
    [self separateMessagesFromContacts:messageList]; //create self.messageList and self.contactList
    [self createMenuList]; //creates self.menuList
    [self addLocalRepLocationCaptureCell: self.menuList]; //edits self.menuList
    
    self.menuList = [self sortMessageListWithContacts:self.menuList];
    NSLog(@"menu right before prep sections%@",self.menuList);
    
        if(self.sections){
            [self.sections removeAllObjects];
            [self.sectionToCategoryMap removeAllObjects];
        }else {
            self.sections = [NSMutableDictionary dictionary];
            self.sectionToCategoryMap = [NSMutableDictionary dictionary];
        }
    //Loops through every messageItem in the messageList and creates 2 dictionaries with index values and categories.
    NSInteger section = 0;
    NSInteger rowIndex = 0; //now 1
    for (MessageItem  *messageItem in self.menuList) {
        NSString *category = [messageItem valueForKey:@"messageCategory"]; //retrieves category for each message -1st regulator
        NSMutableArray *objectsInSection = [self.sections objectForKey:category]; //assigns objectsInSection value of sections for current category
        if (!objectsInSection) {
            objectsInSection = [NSMutableArray array];  //if new create array
            // this is the first time we see this category - increment the section index
            // sectionToCategoryMap literally it ends up (Regulator = 0)
            [self.sectionToCategoryMap setObject:category forKey:[NSNumber numberWithInt:(int)section++]]; // zero
        }
        [objectsInSection addObject:[NSNumber numberWithInt:(int)rowIndex++]]; //adds index number to objectsInSection temp array.
        [self.sections setObject:objectsInSection forKey:category]; //overwrite 1st object with new objects (2 regulatory objects).
    }
    
    
    
    //assign prep section variables back to view controller
    self.messageTableViewController.sections = (NSMutableDictionary*)self.sections;
    self.messageTableViewController.sectionToCategoryMap = (NSMutableDictionary*)self.sectionToCategoryMap;
    self.messageTableViewController.messageList = self.menuList;
    
      NSLog(@"messageList right after sections are created%@",messageList);
      NSLog(@"sections right after sections are created%@",self.sections);
      NSLog(@"categorymap after before sections are created%@",self.sectionToCategoryMap);
    [self.messageTableViewController.tableView reloadData];
}

-(NSMutableArray*)sortMessageListWithContacts:(NSMutableArray*)messageListWithContacts {
    
    NSSortDescriptor *isMessage = [[NSSortDescriptor alloc] initWithKey:@"isMessage" ascending:NO];
    NSSortDescriptor *messageCategory = [[NSSortDescriptor alloc]initWithKey:@"messageCategory" ascending:NO];
    NSSortDescriptor *orderInCategory = [[NSSortDescriptor alloc]initWithKey:@"orderInCategory" ascending:YES];
    
    
    
    if([[messageListWithContacts firstObject] valueForKey:@"orderInCategory"]  ){
        isMenuWithCustomOrdering = YES;
        NSLog(@"custom ordering");
        NSArray *sortDescriptors = [NSArray arrayWithObjects:messageCategory, isMessage, orderInCategory, nil];
        NSArray *messageListWithContactsSorted = [messageListWithContacts sortedArrayUsingDescriptors:sortDescriptors];
        return (NSMutableArray*)messageListWithContactsSorted;
    } else {
        NSLog(@" NOT custom ordering");
        NSArray *sortDescriptors = [NSArray arrayWithObjects: messageCategory,isMessage, nil];
        NSArray *messageListWithContactsSorted = [messageListWithContacts sortedArrayUsingDescriptors:sortDescriptors];
        return (NSMutableArray*)messageListWithContactsSorted;
    }
}

//
//
//    //Find index of local rep menu item
//    NSUInteger indexLocalRep = [self.menuList indexOfObjectPassingTest:
//                        ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
//                            return [[dict objectForKey:@"messageCategory"] isEqual:@"Local Representative"];
//                        }];
//    if(indexLocalRep == NSNotFound){
//        NSLog(@"index NOT FOUND %lu",(unsigned long)indexLocalRep);
//
//        //add message and no location cell
//        [self addLocalRepLocationCaptureCells:self.menuList];
//
//    self.menuList = (NSMutableArray*)[self sortMessageListWithContacts:self.menuList];
//
//    } else {
//        NSLog(@"INDEX FOUND!!!!!!!");
//    }




//    NSUInteger index = [messageList indexOfObjectPassingTest:
//                        ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
//                            return [[dict objectForKey:@"messageCategory"] isEqual:@"Local Representative"];
//                        }];
//    self.messageTableViewController.repMessageText = [[messageList objectAtIndex:index] valueForKey:@"messageText"];
//    [messageList removeObjectAtIndex:index];


@end
