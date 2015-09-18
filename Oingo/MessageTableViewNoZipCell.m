//
//  MessageTableViewNoZipCell.m
//  Oingo
//
//  Created by Matthew Acalin on 8/28/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "MessageTableViewNoZipCell.h"

@implementation MessageTableViewNoZipCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configMessageCellNoZip:(NSIndexPath*)indexPath {
    NSLog(@"no zip cell");
    
    if(self.zipCodeButton == nil){
        NSLog(@"nil!!!");
    }
    
    //Format button to look up local representatives
    self.zipCodeButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.zipCodeButton.layer.borderWidth = .5;
    self.zipCodeButton.layer.cornerRadius = 8;
    self.zipCodeButton.clipsToBounds = YES;
//    [self.contentView layoutIfNeeded];
//    [self.contentView setNeedsDisplay];
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
