//
//  MessageTableViewMessageCell.m
//  Oingo
//
//  Created by Matthew Acalin on 7/3/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "MessageTableViewMessageCell.h"

@implementation MessageTableViewMessageCell


- (void) configMessageCell:messageItem indexPath:(NSIndexPath*)indexPath{
    
    
    self.locationButton.hidden = YES;
    self.zipCodeButton.hidden = YES;
    self.zipLabel.hidden = YES;
    
    NSString *messageText = [NSString stringWithFormat:@"\"%@\"",[messageItem valueForKey:@"messageText"]];
    self.messageText.text = messageText;
    self.messageText.preferredMaxLayoutWidth = 300;
    [self setNeedsDisplay];
    
    

    
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setFrame:(CGRect)frame {
    int inset = 10;
    frame.origin.x += inset; //equal to saying originx = originx + inset
    frame.size.width -= 2 * inset; //mult by 2 b/c taking from both sides
    [super setFrame:frame];
    
}

//- (void)prepareForReuse {
//    [super prepareForReuse];
//    for(UIView *subview in [self.contentView subviews]) {
//        [subview removeFromSuperview];
//    }
//}

@end
