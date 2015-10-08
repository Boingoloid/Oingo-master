//
//  MessageTableViewEmailCell.h
//  Oingo
//
//  Created by Matthew Acalin on 10/6/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmailItem.h"

@interface MessageTableViewEmailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *emailRecipientsButton;
@property (weak, nonatomic) IBOutlet UIButton *emailMyEmailButton;
@property (weak, nonatomic) IBOutlet UIButton *emailBlankButton;
@property (weak, nonatomic) IBOutlet UIButton *storeTextInClipboardButton;
@property (weak, nonatomic) IBOutlet UIButton *storeRecipientsInClipboardButton;
@property (weak, nonatomic) IBOutlet UIButton *linkToEmailButton;
@property (weak, nonatomic) NSString *linkToEmail;

@property (weak, nonatomic) IBOutlet UITextView *emailSubjectTextView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextView *emailRecipientsTextView;

@property (weak, nonatomic) IBOutlet EmailItem *emailItem;



- (IBAction)emailRecipients:(id)sender;
- (IBAction)emailMyEmail:(id)sender;
- (IBAction)emailBlank:(id)sender;
- (IBAction)storeText:(id)sender;
- (IBAction)storeRecipients:(id)sender;

- (void) configEmailCell:(EmailItem*)emailItem indexPath:(NSIndexPath*)indexPath;

@end
