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

@property(nonatomic) NSArray *messageListFromParse;
@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionToCategoryMap;
@property(nonatomic) MessageTableViewController *messageTableViewController;

-(void)getParseMessageData:(Campaign*)selectedCampaign;
-(void)prepSections:messageList;



@end
