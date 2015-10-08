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
@property (weak, nonatomic) IBOutlet UIButton *emailMyEmailButton; //might use later, fields hidden
@property (weak, nonatomic) IBOutlet UIButton *linkToEmailButton;
@property (weak, nonatomic) NSString *linkToEmail;

@property (weak, nonatomic) IBOutlet UITextView *emailSubjectTextView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextView *emailRecipientsTextView;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;

@property (weak, nonatomic) EmailItem *emailItem;

@property (weak, nonatomic) IBOutlet UIImageView *emailSuccessImageView;


- (void) configEmailCell:(EmailItem*)emailItem indexPath:(NSIndexPath*)indexPath;

@end
