//
//  EmailComposerViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 6/26/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Segment.h"
#import "MessageTableViewController.h"

@interface EmailComposerViewController : UIViewController
@property (nonatomic) Segment *selectedSegment;
@property (nonatomic) NSString *sentEmailSubject;
@property (nonatomic) NSString *sentEmailBody;
@property (nonatomic) NSDictionary *selectedContact;
@property (nonatomic) MessageTableViewController *messageTableViewController;
- (void)showMailPicker:(NSString*)email withMessage:(NSString*)message;
@end
