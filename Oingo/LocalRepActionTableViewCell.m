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
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.cornerRadius = 3;
    self.clipsToBounds = YES;
    self.layer.borderWidth = .5;
    
    // Format cell based on actionCategory ___________________________________
    NSString *actionString = [[NSString alloc]init];
    
    if ([actionCategory isEqualToString:@"Local Representative"]){
        actionString = [NSString stringWithFormat:@"Federal Representatives"];
        self.actionImageView.image = [UIImage imageNamed:@"regulator-flag-icon.png"];
        
    }else if ([actionCategory isEqualToString:@"Other Relevant Rep"]){
        actionString = [NSString stringWithFormat:@"Other Relevant Reps"];
        self.actionImageView.image = [UIImage imageNamed:@"regulator-flag-icon.png"];
        
    }else if ([actionCategory isEqualToString:@"Regulator"]){
        actionString = [NSString stringWithFormat:@"Regulators"];
        self.actionImageView.image = [UIImage imageNamed:@"scales.png"];

    }else if ([actionCategory isEqualToString:@"Corporation"]){
        actionString = [NSString stringWithFormat:@"Corporations"];
        self.actionImageView.image = [UIImage imageNamed:@"corporationIcon.png"];
    
    }else if ([actionCategory isEqualToString:@"Organization"]){
        actionString = [NSString stringWithFormat:@"Organizations"];
        self.actionImageView.image = [UIImage imageNamed:@"corporationIcon.png"];

    }else if ([actionCategory isEqualToString:@"Petition"]){
        actionString = [NSString stringWithFormat:@"Change.org Petition"];
        self.actionImageView.image = [UIImage imageNamed:@"changeOrgLogoSquare.png"];
        // Image formatting
        self.actionImageView.layer.borderWidth = .5;
        self.actionImageView.layer.borderColor = [[UIColor blackColor] CGColor];
        self.actionImageView.clipsToBounds = YES;
        self.actionImageView.layer.cornerRadius = 3;
    }else {
        actionString = [NSString stringWithFormat:@"Other Actions"];
        self.actionImageView.image = [UIImage imageNamed:@"Message_chat_text_bubble_phone.png"];
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
