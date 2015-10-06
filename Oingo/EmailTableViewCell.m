//
//  EmailTableViewCell.m
//  Oingo
//
//  Created by Matthew Acalin on 10/6/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "EmailTableViewCell.h"
#import <UIKit/UIKit.h>


@implementation EmailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
}
@end
