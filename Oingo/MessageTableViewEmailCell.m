//
//  MessageTableViewEmail.m
//  Oingo
//
//  Created by Matthew Acalin on 10/6/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "MessageTableViewEmailCell.h"
#import <UIKit/UIKit.h>


@implementation MessageTableViewEmailCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void) configEmailCell:(EmailItem*)emailItem indexPath:(NSIndexPath*)indexPath{
    //add information
    NSLog(@"Configuring email cell");
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    self.emailItem = emailItem;
    self.messageTextView.text = [NSString stringWithFormat:@"%@ /",[emailItem valueForKey:@"messageText"]];
    self.emailRecipients = [emailItem valueForKey:@"emailRecipients"];

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

    self.emailBlankButton.layer.borderWidth = .5;
    self.emailBlankButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.emailBlankButton.layer.cornerRadius = 3.0;
    self.emailBlankButton.clipsToBounds = YES;

    self.storeTextInClipboardButton.layer.borderWidth = .5;
    self.storeTextInClipboardButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.storeTextInClipboardButton.layer.cornerRadius = 3.0;
    self.storeTextInClipboardButton.clipsToBounds = YES;

    self.storeRecipientsInClipboard.layer.borderWidth = .5;
    self.storeRecipientsInClipboard.layer.borderColor = [[UIColor blackColor] CGColor];
    self.storeRecipientsInClipboard.layer.cornerRadius = 3.0;
    self.storeRecipientsInClipboard.clipsToBounds = YES;


}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //hide the keyborad
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.messageTextView isFirstResponder] && [touch view] != self.messageTextView) {
        [self.messageTextView resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)emailRecipients:(id)sender {
    
}

- (IBAction)emailMyEmail:(id)sender {
    
}

- (IBAction)emailBlank:(id)sender {
    
}

- (IBAction)storeText:(id)sender {
    NSString *copyStringverse = self.messageTextView.text;
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:copyStringverse];
//    http://stackoverflow.com/questions/8869569/copy-functionality-in-ios-by-using-uipasteboard
}

- (IBAction)storeRecipients:(id)sender {
    NSString *copyStringverse = self.emailRecipients;
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:copyStringverse];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    int inset = 10;
    frame.origin.x += inset; //equal to saying originx = originx + inset
    frame.size.width -= 2 * inset; //mult by 2 b/c taking from both sides

    
}
@end
