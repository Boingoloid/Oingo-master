//
//  SessionDefaults.h
//  Oingo
//
//  Created by Matthew Acalin on 7/1/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageTableViewController.h"

@interface SessionDefaults : NSObject

@property(nonatomic) MessageTableViewController *messageTableViewController;

-(void)loadLocationDefaults:(NSUserDefaults*)defaults fromUser:(PFUser*)currentUser;
-(void)loadLocationDefaults:(NSUserDefaults*)defaults;
//+(void)loadLocationDefaultsFromUser;

@end
