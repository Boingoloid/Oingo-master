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
        NSLog(@"segment index:%ld",self.messagePanelViewController.tableSegmentControl.selectedSegmentIndex);
        NSDictionary *sentMessage = (NSDictionary*)dataDict;
        self.messageTextLabel.text = [sentMessage valueForKey:@"messageText"];
        self.messageCountLabel.hidden = true;
        NSLog(@"FLAG METHOD");
    } else {
        NSDictionary *hashtag = (NSDictionary*)dataDict;
        self.messageTextLabel.text = [hashtag valueForKey:@"hashtag"];
        self.messageCountLabel.text = [NSString stringWithFormat:@"%@",[hashtag valueForKey:@"frequency"]];
        self.messageCountLabel.hidden = false;
        NSLog(@"hashtag list on cell:%@",self.hashtagList);
        NSLog(@"hashtag value:%@",[hashtag valueForKey:@"hashtag"]);
        
    }
    
    

}

@end
