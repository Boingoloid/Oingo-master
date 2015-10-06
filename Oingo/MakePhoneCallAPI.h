//
//  MakePhoneCallAPI.h
//  Oingo
//
//  Created by Matthew Acalin on 6/26/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageTableViewController.h"
#import "Program.h"
#import "Segment.h"

@interface MakePhoneCallAPI : NSObject
@property (nonatomic) Segment *selectedSegment;
@property (nonatomic) Program *selectedProgram;
@property(nonatomic) NSDictionary *selectedContact;
@property(nonatomic) MessageTableViewController *messageTableViewController;
-(void) dialPhoneNumber:(NSURL*)phoneUrl;

@end
