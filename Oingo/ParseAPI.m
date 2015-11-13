//
//  ParseAPI.m
//  Oingo
//
//  Created by Matthew Acalin on 7/1/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "ParseAPI.h"
#import <Parse/Parse.h>
#import "Segment.h"
#import "MessageItem.h"
#import "CongressionalMessageItem.h"
#import "CongressFinderAPI.h"
#import "CongressPhotoFinderAPI.h"
#import "MarkSentMessageAPI.h"



@interface ParseAPI () <NSCoding>
-(id)copyWithZone:(NSZone *)zone;
@end

@implementation ParseAPI

BOOL isMenuWithCustomOrdering = NO;
BOOL isLocalRepMessageIncluded = NO;

BOOL isZipAvailable = NO;
BOOL isLatitude = NO;
BOOL isLongitude = NO;

BOOL isCoordinateInfoAvailable = NO;
BOOL isLocationInfoAvailable = NO;



-(id)copyWithZone:(NSZone *)zone
{
    NSMutableArray *tempArray= [[NSMutableArray allocWithZone:zone]init];
    
    return tempArray;
}


-(void)getParseMessageData:(Segment*)selectedSegment{  //get parse messge data for selectedSegment
    NSLog(@"Parse API");
    
    // Initialize bool values to NO
    isMenuWithCustomOrdering = NO;
    isLocalRepMessageIncluded = NO;
    isZipAvailable = NO;
    isLatitude = NO;
    isLongitude = NO;
    isLocationInfoAvailable = NO;
    isCoordinateInfoAvailable = NO;
    

    // Set bool values
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults valueForKey:@"latitude"] != nil) {
        isLatitude = YES;
    }
    
    if([defaults valueForKey:@"longitude"] != nil) {
        isLongitude = YES;
    }
    
    if([defaults valueForKey:@"zipCode"] != nil) {
        isZipAvailable = YES;
    }
    
    if(isLatitude && isLongitude) {
        isCoordinateInfoAvailable = YES;
    }
    
    if(isCoordinateInfoAvailable || isZipAvailable){
        isLocationInfoAvailable = YES;
    }
    

    NSLog(@"defaults zip:%@ lat:%@ long:%@",[defaults valueForKey:@"zipCode"],[defaults valueForKey:@"latitude"],[defaults valueForKey:@"longitude"]);
    NSLog(@"bool zip:%d lat:%d long:%d coordinate:%d location:%d", isZipAvailable ,isLatitude,isLongitude,isCoordinateInfoAvailable,isLocationInfoAvailable);
    

    
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"segmentID" equalTo:[selectedSegment valueForKey:@"segmentID"]];
    [query orderByDescending:@"messageCategory"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // 1)Grab results, and create deep copy of data
                self.messageListFromParseWithContacts = (NSMutableArray*)[self createDeepCopyOfData:objects];
                
                
////  TOGGLE ON FOR PRODUCTION:  --------------------------------------------------------------------------------------------
////  Toggle this code on for deployment builds so that new categories do not break the MessageTableViewController
//// COMMENT OUT DEEP COPY LINE DIRECTLY ABOVE IF ACTIVE - not a must, but more efficient to not make 2 deep copies
//*******************************************************************************************************************************
                // 1.5 Deletes any cells labeled as experimental so I don't break the current build on app store.
//                NSMutableArray *nonExperimentalMutableArray = [[NSMutableArray alloc] initWithCapacity:10];
//                for (NSDictionary *dictionary in objects){
//                    NSNumber *isExperimentalNumber = [dictionary valueForKey:@"isExperimental"];
//                    bool isExperimentalBool = [isExperimentalNumber boolValue];
//                    if(!isExperimentalBool) {
//                        [nonExperimentalMutableArray addObject:dictionary];
//                    } else {
//                        NSLog(@"Object is experimental, don't add: %@",dictionary);
//                    }
//                }
//                self.messageListFromParseWithContacts = (NSMutableArray*)[self createDeepCopyOfData:nonExperimentalMutableArray];
//*******************************************************************************************************************************
                
                
                // 2) Check for message cell for category = "Local Representative"
                isLocalRepMessageIncluded = [self isLocalRepIncluded];
                
                // 3) Choose load path
                if(!isLocalRepMessageIncluded){
                    [self prepSections:self.messageListFromParseWithContacts]; // Load with no rep data, b/c no local rep message
               
                } else {
                    if(!isLocationInfoAvailable){
                        [self addLocalRepLocationCaptureCell];
                        [self prepSections:self.messageListFromParseWithContacts];
                        
                    } else {
                        [self prepSections:self.messageListFromParseWithContacts]; //load so that the user sees something
                        [self updateMenuListWithCongressDataFromBestAvailableLocation];  //lazy update of congress people
                    }
                }

            });
        }
    }];
}


-(BOOL)isLocalRepIncluded{
    NSUInteger indexLocalRep = [self.messageListFromParseWithContacts indexOfObjectPassingTest:
                                ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                    return [[dict objectForKey:@"messageCategory"] isEqual:@"Local Representative"];
                                }];
    if (indexLocalRep == NSNotFound){
        return NO;
    } else {
        return YES;
    }
}



-(void) addLocalRepLocationCaptureCell{
    
    // Create NoZipCell - captures location (should be NoLocationInfoCell b/c more descriptive)
    if(isLocalRepMessageIncluded && !isLocationInfoAvailable){
        NSMutableDictionary *noZipDictionary = [[NSMutableDictionary alloc]init];
        [noZipDictionary setValue:@"Local Representative" forKey:@"messageCategory"];
        [noZipDictionary setValue:@YES forKey:@"isGetLocationCell"];
        // NSLog(@"dictionary value for isGetLocationCell %@",[noZipDictionary valueForKey:@"isGetLocationCell"]);
        [self.messageListFromParseWithContacts addObject:noZipDictionary];
    }
}
-(void) updateMenuListWithCongressDataFromBestAvailableLocation{
//Try 1)coordinates then 2) zipCode
// 1) Coordinates

    if(isCoordinateInfoAvailable) {
        
//        NSLog(@"updateMenuListWithBestAvailableLocation (parseAPI) %@:", self.messageOptionsList);
//        NSLog(@"updateMenuListWithBestAvailableLocation (parseAPI) %@:", self.messageTableViewController.messageOptionsList);
//        NSLog(@"updateMenuListWithBestAvailableLocation (parseAPI) %@:", self.messageListFromParseWithContacts);
//        NSLog(@"updateMenuListWithBestAvailableLocation (parseAPI) %@:", self.messageOptionsList);
//        NSLog(@"updateMenuListWithBestAvailableLocation (parseAPI) %@:", self.messageOptionsList);
//        NSLog(@"updateMenuListWithBestAvailableLocation (parseAPI) %@:", self.messageOptionsList);
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        CongressFinderAPI *congressFinder = [[CongressFinderAPI alloc]init];
        congressFinder.messageTableViewController = self.messageTableViewController;
        congressFinder.messageOptionsList = self.messageOptionsList;
        [congressFinder getCongressWithLatitude:[defaults doubleForKey:@"latitude"] andLongitude:[defaults doubleForKey:@"longitude"] addToMessageList:(NSMutableArray*)self.messageListFromParseWithContacts];
        
// 2) zipCode
    } else if (isZipAvailable){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //congressFinder with zipCode
        CongressFinderAPI *congressFinder = [[CongressFinderAPI alloc]init];
        congressFinder.messageTableViewController = self.messageTableViewController;
        [congressFinder getCongress:[defaults valueForKey:@"zipCode"] addToMessageList:self.messageListFromParseWithContacts];
    }
}



# pragma mark - Prep Sections

-(void)prepSections:messageList {
    
    //NSLog(@"messageLst: %@",messageList);
    
    [self separateMessagesFromContacts:messageList]; //create self.messageList and self.contactList and other
    [self createMenuList]; //creates self.menuList - these are the grouopings for sections

    self.menuList = [self sortMessageListWithContacts:self.menuList];
    self.menuList = [self moveLocalRepsToTop:self.menuList];

    
        if(self.sections){
            [self.sections removeAllObjects];
            [self.sectionToCategoryMap removeAllObjects];
        }else {
            self.sections = [NSMutableDictionary dictionary];
            self.sectionToCategoryMap = [NSMutableDictionary dictionary];
        }
    //Loops through every Item in the messageList and creates 2 dictionaries with index values and categories.
    NSInteger section = 0;
    NSInteger rowIndex = 0; //now 1
    for (NSMutableDictionary *dictionaryItem in self.menuList) {
        NSString *category = [dictionaryItem valueForKey:@"messageCategory"]; //retrieves category for each message -1st regulator
        NSMutableArray *objectsInSection = [self.sections objectForKey:category]; //assigns objectsInSection value of sections for current category
        if (!objectsInSection) {
            objectsInSection = [NSMutableArray array];  //if new create array
            // this is the first time we see this category - increment the section index
            // sectionToCategoryM ap literally it ends up (Regulator = 0)
            [self.sectionToCategoryMap setObject:category forKey:[NSNumber numberWithInt:(int)section++]]; // zero
        }
        [objectsInSection addObject:[NSNumber numberWithInt:(int)rowIndex++]]; //adds index number to objectsInSection temp array.
        [self.sections setObject:objectsInSection forKey:category]; //overwrite 1st object with new objects (2 regulatory objects).
    }
    
    // Assign prep section variables back to view controller
    self.messageTableViewController.sections = (NSMutableDictionary*)self.sections;
    self.messageTableViewController.sectionToCategoryMap = (NSMutableDictionary*)self.sectionToCategoryMap;
    self.messageTableViewController.messageList = self.menuList;
    self.messageTableViewController.menuList = self.menuList;
    self.messageTableViewController.messageOptionsList = self.messageOptionsList;
    
    self.messageTableViewController.expandSectionsKeyList = self.expandSectionsKeyList;
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.messageTableViewController.tableView reloadData];
        NSLog(@"Prep Sections end: Reloading data from Prep Sections");
        

        if(self.isCongressLoaded) {
            //could make this async
            CongressPhotoFinderAPI *congressPhotoFinder = [[CongressPhotoFinderAPI alloc]init];
            congressPhotoFinder.messageTableViewController = self.messageTableViewController;
            [congressPhotoFinder getPhotos:self.messageTableViewController.congressMessageList];
        }

        if([PFUser currentUser]) {
            MarkSentMessageAPI *markSentMessagesAPI = [[MarkSentMessageAPI alloc]init];
            markSentMessagesAPI.messageTableViewController = self.messageTableViewController;
            [markSentMessagesAPI markSentMessages];
        }
        self.isCongressLoaded = NO;
    });
}

# pragma mark - Prep Sections Helper Methods

-(void) separateMessagesFromContacts:(NSMutableArray*)messageList {
    
    NSMutableArray *messageListWithContactsSorted = [self sortMessageListWithContacts:messageList];
    //now have sorted list
    //now separate them
    
    NSMutableArray *messageTextList = [[NSMutableArray alloc]init];
    NSMutableArray *contactList = [[NSMutableArray alloc]init];
    NSMutableArray *otherList = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dictionary in messageListWithContactsSorted) {
        //NSLog(@"[dictionary valueForKey:@messageCategory]:%@",[dictionary valueForKey:@"messageCategory"]);
        NSNumber *isMessageNumber = [dictionary valueForKey:@"isMessage"];
        bool isMessageBool = [isMessageNumber boolValue];
        if(isMessageBool) {
            // Add or set any defaults
            [dictionary setValue:@YES forKey:@"isLinkIncluded"];
            [messageTextList addObject:dictionary];
        } else if ([[dictionary valueForKey:@"messageCategory"] isEqualToString:@"Long Form Email"]){
            //NSLog(@"[dictionary valueForKey:@messageCategory]:%@",[dictionary valueForKey:@"messageCategory"]);
            [otherList addObject:dictionary];
        }else {
            [contactList addObject:dictionary];
        }
    }
    
    self.messageTextList = messageTextList;
    
    if(self.isCongressLoaded){
        self.messageOptionsList = (NSMutableArray*)[self createDeepCopyOfData:self.messageTextList];
    }
    
    self.contactList = contactList;
    self.otherList = otherList;
//    NSLog(@"contactlist:%@ messageList: %@",contactList,messageTextList);
//    NSLog(@"other :%@",otherList);
}


-(void)createMenuList{
    
    // 1) Sep up objects
    if(self.menuList) {
        [self.menuList removeAllObjects];
    } else {
        self.menuList = [[NSMutableArray alloc]init];
    }
    
//
//    if(self.expandSectionsKeyList) {
//        [self.expandSectionsKeyList removeAllObjects];
//    } else {
//        self.expandSectionsKeyList = [[NSMutableArray alloc]init];
//    }
    
    NSString *category = @"";
    NSUInteger contactIndex = 0;
    
    // 2) For every section grabs 1 message, then fills in contacts beneath, adds others to end
    for (NSMutableDictionary *contactRow in self.contactList) {
        
        //add "success" bools
        //[contactRow setValue:@NO forKey:@"isTweetSent"];
        
        
        if(category != [contactRow valueForKey:@"messageCategory"]){
            category = [contactRow valueForKey:@"messageCategory"];
            //NSLog(@"category not equal (new one) :%@",category);
            
            
            NSUInteger index = [self.messageTextList indexOfObjectPassingTest:
                                ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                    return [[dict objectForKey:@"messageCategory"] isEqual:category];
                                }];
            NSMutableDictionary *messageToAdd = [self.messageTextList objectAtIndex:index];
            //NSLog(@"mesage to add%@:", messageToAdd);
            [self.menuList addObject:messageToAdd];
            //[contactRow setValue:@NO forKey:@"isCollapsed"]; // makes sure at least one contact is expanded
            [self.menuList addObject:contactRow];
            
            // create another array to dictate whether they are all showing
            //add when new category and set to not expanded
            //NSMutableDictionary *expandSectionTempDictionary = [[NSMutableDictionary alloc]init];
            //[expandSectionTempDictionary setValue:category forKey:@"Category"];
            //[expandSectionTempDictionary setValue:@YES forKey:@"isSectionExpanded"];
            //[self.expandSectionsKeyList addObject:expandSectionTempDictionary];
        } else {
            [self.menuList addObject:contactRow];
        }
        contactIndex++;
    }
    [self.menuList addObjectsFromArray:self.otherList];
//    NSLog(@"self.otherList:%@",self.otherList);
//    NSLog(@"self.contactList:%@",self.contactList);
//    NSLog(@"self.messageList:%@",self.messageTextList);
}


# pragma mark - Helper Methods like sorting

-(NSMutableArray*)sortMessageListWithContacts:(NSMutableArray*)messageListWithContacts {
    
    NSSortDescriptor *isMessage = [[NSSortDescriptor alloc] initWithKey:@"isMessage" ascending:NO];
    NSSortDescriptor *messageCategory = [[NSSortDescriptor alloc]initWithKey:@"messageCategory" ascending:NO];
    NSSortDescriptor *orderInCategory = [[NSSortDescriptor alloc]initWithKey:@"orderInCategory" ascending:YES];
    
    if([[messageListWithContacts firstObject] valueForKey:@"orderInCategory"]  ){
        isMenuWithCustomOrdering = YES;
        //NSLog(@"custom ordering");
        NSArray *sortDescriptors = [NSArray arrayWithObjects:messageCategory, isMessage, orderInCategory, nil];
        NSArray *messageListWithContactsSorted = [messageListWithContacts sortedArrayUsingDescriptors:sortDescriptors];
        return (NSMutableArray*)messageListWithContactsSorted;
    } else {
        //NSLog(@" NOT custom ordering");
        NSArray *sortDescriptors = [NSArray arrayWithObjects: messageCategory,isMessage, nil];
        NSArray *messageListWithContactsSorted = [messageListWithContacts sortedArrayUsingDescriptors:sortDescriptors];
        return (NSMutableArray*)messageListWithContactsSorted;
    }
}

-(NSMutableArray*)moveLocalRepsToTop:(NSMutableArray*)messageListWithContactsSorted {
    
    
    NSMutableArray *localRepArray = [[NSMutableArray alloc]init];
    NSMutableArray *nonLocalRepArray = [[NSMutableArray alloc]init];

    
    for (NSDictionary *dictionary in messageListWithContactsSorted) {

        NSString *category = [dictionary valueForKey:@"messageCategory"];
        
        if([category isEqualToString:@"Local Representative"]){
            [localRepArray addObject:dictionary];
        } else {
            [nonLocalRepArray addObject:dictionary];
        }
    }
    
    NSMutableArray *messageListWithRepsFirst = [[NSMutableArray alloc]initWithCapacity:20];

    
    [messageListWithRepsFirst addObjectsFromArray:localRepArray];
    [messageListWithRepsFirst addObjectsFromArray:nonLocalRepArray];
    
    return messageListWithRepsFirst;
}


# pragma mark - Deep Copy Helpers

-(NSArray*)createDeepCopyOfData:objects {
    
    // Separate messages out into tempArrays
    NSMutableArray *messagesTempArray = [[NSMutableArray alloc]init];
    NSMutableArray *contactsTempArray = [[NSMutableArray alloc]init];
    NSMutableArray *allDataTempArray = [[NSMutableArray alloc]init];
    
    // Cycle through objects, create 3 temp arrays initialized above (Message Only, Contact Only, Both("allDataTempArray"))
    for (NSDictionary *dictionary in objects) {
        
        // In every case
        NSDictionary *tempDicToAddFull = dictionary;
        NSMutableArray *allKeys = (NSMutableArray*)[tempDicToAddFull allKeys];
        int count = (int)[[tempDicToAddFull allKeys]count];
        
        NSMutableDictionary *dictionaryToAddAggregator = [[NSMutableDictionary alloc]init];
        for (int i=0; i<count; i++){
            NSString *keyString = [allKeys objectAtIndex:i];
            
            NSObject *getObject = [tempDicToAddFull objectForKey:keyString];
            
            
            NSMutableDictionary *insertDicTemp = [[NSMutableDictionary alloc]initWithObjects:@[getObject] forKeys:@[keyString]];
            
            // Change PFFile to image file
            if([keyString isEqualToString:@"messageImage"]) {
                PFFile *theImage = [insertDicTemp objectForKey:@"messageImage"];
                NSData *imageData = [theImage getData];
                UIImage *image = [UIImage imageWithData:imageData];
                [insertDicTemp setObject:image forKey:@"messageImage"];
            }
            
            [dictionaryToAddAggregator addEntriesFromDictionary:insertDicTemp];
        }
        
        NSNumber *isMessageNumber = [dictionaryToAddAggregator valueForKey:@"isMessage"];
        bool isMessageBool = [isMessageNumber boolValue];
        
        // If it's a message, add to messagesTempArray
        if (isMessageBool) {
            [messagesTempArray addObject:(NSDictionary*)dictionaryToAddAggregator];
        } else {
            // If it's NOT a message, add to contactsTempArray
            [contactsTempArray addObject:(NSDictionary*)dictionaryToAddAggregator];
        }
        [allDataTempArray addObject:(NSDictionary*)dictionaryToAddAggregator];
    }
    
    NSMutableArray* messagesDeepCopyArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:messagesTempArray]];
    NSMutableArray* allDataDeepCopyArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:allDataTempArray]];
    
    self.messageOptionsList = messagesDeepCopyArray;
    self.messageTableViewController.messageOptionsList = self.messageOptionsList;
//    NSLog(@"deep copy of messageOptionsList (deep copy):%@",[self.messageOptionsList firstObject]);
//        NSLog(@"self.messagetableviewcontroller.messageOptionsList last object(deep copy):%@",[self.messageTableViewController.messageOptionsList lastObject]);
    
    return allDataDeepCopyArray;
    
    
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    NSLog(@"encode is firing");
    [coder encodeObject:self.messageOptionsList];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.messageOptionsList = [coder decodeObjectForKey:@"messageOptionList"];
        NSLog(@"initwithcoder firing");
    }
    return self;
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
