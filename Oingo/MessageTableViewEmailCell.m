//
//  MessageTableViewEmail.m
//  Oingo
//
//  Created by Matthew Acalin on 10/6/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "MessageTableViewEmailCell.h"
#import <UIKit/UIKit.h>
#import "WebViewController.h"
#import <Parse/Parse.h>


@implementation MessageTableViewEmailCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void) configEmailCell:(EmailItem*)emailItem indexPath:(NSIndexPath*)indexPath{
    
    PFUser *currentUser = [PFUser currentUser];
    
    if([currentUser valueForKey:@"firstNameEmail"]){
        self.firstName.text = [currentUser valueForKey:@"firstNameEmail"];
    }
    if([currentUser valueForKey:@"lastNameEmail"]){
        self.lastName.text = [currentUser valueForKey:@"lastNameEmail"];
    }
    
    //add information
    NSLog(@"Configuring email cell");
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // Assign values
    self.emailItem = emailItem;
    self.messageTextView.text = [NSString stringWithFormat:@"%@",[emailItem valueForKey:@"messageText"]];
    self.emailSubjectTextView.text = [NSString stringWithFormat:@"%@",[emailItem valueForKey:@"emailSubject"]];
    self.emailRecipientsTextView.text = [emailItem valueForKey:@"emailRecipients"];
    self.linkToEmail = [emailItem valueForKey:@"linkToEmail"];


    // Formatting
    self.emailSubjectTextView.layer.borderWidth = .5;
    self.emailSubjectTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.emailSubjectTextView.layer.cornerRadius = 3.0;
    self.emailSubjectTextView.clipsToBounds = YES;
    [self.emailSubjectTextView scrollRangeToVisible:NSMakeRange(0, 0)];
    
    self.emailRecipientsTextView.layer.borderWidth = .5;
    self.emailRecipientsTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.emailRecipientsTextView.layer.cornerRadius = 3.0;
    self.emailRecipientsTextView.clipsToBounds = YES;
    [self.emailRecipientsTextView scrollRangeToVisible:NSMakeRange(0, 0)];
    
    self.messageTextView.layer.borderWidth = .5;
    self.messageTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.messageTextView.layer.cornerRadius = 3.0;
    self.messageTextView.clipsToBounds = YES;
    [self.messageTextView scrollRangeToVisible:NSMakeRange(0, 0)];
    
    self.emailRecipientsButton.layer.borderWidth = .5;
    self.emailRecipientsButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.emailRecipientsButton.layer.cornerRadius = 3.0;
    self.emailRecipientsButton.clipsToBounds = YES;
    
    self.emailMyEmailButton.layer.borderWidth = .5;
    self.emailMyEmailButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.emailMyEmailButton.layer.cornerRadius = 3.0;
    self.emailMyEmailButton.clipsToBounds = YES;
    
    // Hide success fields
    self.emailSuccessImageView.hidden = YES;
    
    // Mark and show Success fields
    NSNumber *sendEmailNumberBool = [emailItem valueForKey:@"isLongFormEmailSent"];
    bool sendEmailBool = [sendEmailNumberBool boolValue];
    if(sendEmailBool) {
        self.emailSuccessImageView.hidden = NO;
    } else {
        self.emailSuccessImageView.hidden = YES;
    }
    

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //hide the keyborad
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.messageTextView isFirstResponder] && [touch view] != self.messageTextView) {
        [self.messageTextView resignFirstResponder];
    } else  if ([self.emailSubjectTextView isFirstResponder] && [touch view] != self.emailSubjectTextView) {
        [self.emailSubjectTextView resignFirstResponder];
    } else  if ([self.emailRecipientsTextView isFirstResponder] && [touch view] != self.emailRecipientsTextView) {
        [self.emailRecipientsTextView resignFirstResponder];
    } else  if ([self.firstName isFirstResponder] && [touch view] != self.firstName) {
        [self.firstName resignFirstResponder];
    } else  if ([self.lastName isFirstResponder] && [touch view] != self.lastName) {
        [self.lastName resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
}

//- (IBAction)storeText:(id)sender {
//    NSString *copyStringverse = self.messageTextView.text;
//    UIPasteboard *pb = [UIPasteboard generalPasteboard];
//    [pb setString:copyStringverse];
////    http://stackoverflow.com/questions/8869569/copy-functionality-in-ios-by-using-uipasteboard
//}
//
//- (IBAction)storeRecipients:(id)sender {
//    NSString *copyStringverse = self.emailRecipientsTextView.text;
//    UIPasteboard *pb = [UIPasteboard generalPasteboard];
//    [pb setString:copyStringverse];
//}

- (void)setFrame:(CGRect)frame {
    int inset = 10;
    frame.origin.x += inset; //equal to saying originx = originx + inset
    frame.size.width -= 2 * inset; //mult by 2 b/c taking from both sides
    
    dispatch_async(dispatch_get_main_queue(), ^{
    [super setFrame:frame];
    });
}
@end
