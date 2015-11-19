//
//  MessagePanelTableViewCell.m
//  Oingo
//
//  Created by Matthew Acalin on 11/13/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "MessagePanelTableViewCell.h"

@implementation MessagePanelTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(void)configureCellWithData:(NSDictionary*)dataDict {
    if(self.messagePanelViewController.tableSegmentControl.selectedSegmentIndex == 0){
        
        
        NSDictionary *sentMessage = (NSDictionary*)dataDict;
        self.messageTextLabel.text = [sentMessage valueForKey:@"messageText"];
        if([sentMessage valueForKey:@"messageCount"]){
            self.messageCountLabel.hidden = false;
        }else {
            self.messageCountLabel.hidden = true;
        }
    } else {
        NSDictionary *hashtag = (NSDictionary*)dataDict;
        self.messageTextLabel.text = [hashtag valueForKey:@"hashtag"];
        self.messageCountLabel.text = [NSString stringWithFormat:@"%@",[hashtag valueForKey:@"frequency"]];
        self.messageCountLabel.hidden = false;
    }
    
    

}

@end
