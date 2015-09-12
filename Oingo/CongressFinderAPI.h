//
//  CongressFinderAPI.h
//  Oingo
//
//  Created by Matthew Acalin on 6/20/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageTableViewController.h"
#import "ParseAPI.h"


@interface CongressFinderAPI : NSObject 
@property(nonatomic) NSMutableArray *messageList;
@property(nonatomic) NSMutableArray *messageListWithCongress;
@property(nonatomic) MessageTableViewController *messageTableViewController;
@property(nonatomic) NSMutableArray *messageOptionsList;
@property(nonatomic) bool isCongressLoaded;

-(void)getCongress:zipCode addToMessageList:messageList;
-(void)getCongressWithLatitude:(double)latitude andLongitude:(double)longitude addToMessageList:(NSMutableArray*)messageList;

@end
