//
//  LocalRepActionTableViewCell.m
//  Oingo
//
//  Created by Matthew Acalin on 12/12/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "LocalRepActionTableViewCell.h"

@implementation LocalRepActionTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(LocalRepActionTableViewCell*) configLocalRepActionCell:(NSMutableDictionary*)actionDict{
    NSString *actionString = [actionDict valueForKey:@"actionCategory"];
    self.actionTitleLabel.text = actionString;
    self.layer.backgroundColor = [[UIColor blueColor] CGColor];
    
    
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    int inset = 10;
    frame.origin.x += inset; //equal to saying originx = originx + inset
    frame.size.width -= 2 * inset; //mult by 2 b/c taking from both sides
    dispatch_async(dispatch_get_main_queue(), ^{
        [super setFrame:frame];
    });
}

@end
