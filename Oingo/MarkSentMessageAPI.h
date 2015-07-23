//
//  MarkSentMessageAPI.h
//  Oingo
//
//  Created by Matthew Acalin on 7/21/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageTableViewController.h"
#import "ParseAPI.h"

@interface MarkSentMessageAPI : NSObject
@property(nonatomic) MessageTableViewController *messageTableViewController;
@property(nonatomic) ParseAPI *parseAPI;
@property(nonatomic) NSArray *sentMessagesForSegment;

-(void)markSentMessages;

@end
