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
    self.actionTitleLabel.text = [actionDict valueForKey:@"actionCategory"];
    return self;
}

@end
