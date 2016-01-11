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
    
    NSString *actionCategory = [actionDict valueForKey:@"actionCategory"];
    
    // Format cell border/background
    //self.layer.backgroundColor = [[UIColor colorWithWhite:0.9f alpha:1] CGColor];
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.cornerRadius = 3;
    self.clipsToBounds = YES;
    self.layer.borderWidth = .5;
    
    // Format cell based on actionCategory ___________________________________
    NSString *actionString = [[NSString alloc]init];
    
    if ([actionCategory isEqualToString:@"Local Representative"]){
        actionString = [NSString stringWithFormat:@"Federal Representatives"];
        
    }else if ([actionCategory isEqualToString:@"Regulator"]){
        actionString = [NSString stringWithFormat:@"Regulators"];
        self.actionImageView.image = [UIImage imageNamed:@"regulator-flag-icon.png"];

        // Image formatting
        self.actionImageView.layer.borderWidth = .5;
        self.actionImageView.layer.borderColor = [[UIColor blackColor] CGColor];
        self.actionImageView.clipsToBounds = YES;
        self.actionImageView.layer.cornerRadius = 3;
    }else {
        actionString = [NSString stringWithFormat:@"Sign Petition"];
        self.actionImageView.image = [UIImage imageNamed:@"Message_chat_text_bubble_phone.png"];

        // Image formatting
        //self.actionImageView.layer.borderWidth = .5;
        //self.actionImageView.layer.borderColor = [[UIColor blackColor] CGColor];
        //self.actionImageView.clipsToBounds = YES;
        //self.actionImageView.layer.cornerRadius = 3;
        
    }
    self.actionTitleLabel.text = actionString;
    // _______________________________________________________
    
    
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
