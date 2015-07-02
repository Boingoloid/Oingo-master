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



-(void)getParseMessageData:(Campaign*)selectedCampaign{  //get parse messge data for selectedCampaign
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"campaignID" equalTo:[selectedCampaign valueForKey:@"campaignID"]];
    [query orderByDescending:@"messageCategory"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.messageListFromParse = (NSArray*)objects;  //messageList has everything ordered by category

            //Loads parse data.  If there location, it load congress by coordinates first, then its tries zipCode
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if(![defaults valueForKey:@"latitude"] && ![defaults valueForKey:@"zipCode"]) { //if no location info, then just prep and load it.
                [self prepSections:self.messageListFromParse];
            } else {
                CongressFinderAPI *congressFinder = [[CongressFinderAPI alloc]init];
                congressFinder.messageTableViewController = self.messageTableViewController;
                congressFinder.parseAPI = self;
                if([defaults valueForKey:@"latitude"] && [defaults valueForKey:@"longitude"]) {
                    [congressFinder getCongressWithLatitude:[defaults doubleForKey:@"latitude"] andLongitude:[defaults doubleForKey:@"longitude"] addToMessageList:(NSMutableArray*)self.messageListFromParse];
                } else {
                    [congressFinder getCongress:[defaults valueForKey:@"zipCode"] addToMessageList:self.messageListFromParse];
                }
            }
        }
    }];
}


-(void)prepSections:messageList {
    NSLog(@"Prep sections triggered");
    [self.sections removeAllObjects];
    [self.sectionToCategoryMap removeAllObjects];
    self.sections = [NSMutableDictionary dictionary];
    self.sectionToCategoryMap = [NSMutableDictionary dictionary];
    
    //Loops through every messageItem in the messageList and creates 2 dictionaries with index values and categories.
    NSInteger section = 0;
    NSInteger rowIndex = 0; //now 1
    for (MessageItem  *messageItem in messageList) {
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
    self.messageTableViewController.messageList = messageList;
    NSLog(@"sections reloading%@ %@",self.messageTableViewController.sections, self.sections);
    
    
    [self.messageTableViewController.tableView reloadData];


    
}

@end
