//
//  CongressFinderAPI.h
//  Oingo
//
//  Created by Matthew Acalin on 6/20/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageTableViewController.h"


@interface CongressFinderAPI : NSObject 
@property(nonatomic) NSMutableArray *messageList;
@property(nonatomic) NSMutableArray *messageListWithCongress;
@property(nonatomic) MessageTableViewController *messageTableViewController;
-(void)getCongress:zipCode addToMessageList:messageList;
-(void)getCongressWithLocation:location addToMessageList:(NSMutableArray*)messageList;

@end
