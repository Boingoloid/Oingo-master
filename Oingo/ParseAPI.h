//
//  ParseAPI.h
//  Oingo
//
//  Created by Matthew Acalin on 7/1/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageTableViewController.h"


@interface ParseAPI : NSObject

@property(nonatomic) NSMutableArray *messageListFromParseWithContacts;
@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionToCategoryMap;
@property (nonatomic, retain) NSMutableDictionary *noZipDictionary;
@property (nonatomic) NSMutableArray *contactList;
@property(nonatomic) NSArray *dataImmutable;
@property (nonatomic) NSMutableArray *menuList;
@property (nonatomic, retain) NSMutableArray *expandSectionsKeyList;
@property(nonatomic) MessageTableViewController *messageTableViewController;
@property(nonatomic) NSArray *messageOptionsList;
@property(nonatomic) NSArray *messageTextList;
@property(nonatomic) NSArray *tempArray;
@property(nonatomic) bool isCongressLoaded;


-(void)getParseMessageData:(Segment*)selectedSegment;
-(void)prepSections:messageList;



@end
