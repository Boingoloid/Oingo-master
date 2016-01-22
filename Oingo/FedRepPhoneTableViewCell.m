//
//  FedRepPhoneTableViewCell.m
//  Oingo
//
//  Created by Matthew Acalin on 1/19/16.
//  Copyright © 2016 Oingo Inc. All rights reserved.
//

#import "FedRepPhoneTableViewCell.h"

@implementation FedRepPhoneTableViewCell


-(FedRepPhoneTableViewCell*)configCell:(NSMutableDictionary*)dictionary{
    //NSLog(@"dictionary printing FedRepPhone:%@",dictionary);
    
    // Full name
    NSString *nickName = [dictionary valueForKey:@"nickname"];
    NSString *firstName = [dictionary valueForKey:@"first_name"];
    NSString *lastName = [dictionary valueForKey:@"last_name"];
    NSString *fullName;
    
    // Substitute nickName if they have one
    if(nickName ==(id)[NSNull null] || nickName.length == 0){
        fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
    } else {
        fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
    }
    self.nameLabel.text = fullName;
    
    // Title and Placeholder Image load based on chamber
    NSString *chamber = [dictionary valueForKey:@"chamber"];
    NSString *state = [dictionary valueForKey:@"state"];
    NSString *district = [dictionary valueForKey:@"district"];
    if([chamber isEqualToString:@"senate"]) {
        self.titleLabel.text = [NSString stringWithFormat:@"Senator,%@",state];
        self.fedRepPortrait.image = [UIImage imageNamed:@"Seal_of_Senate_Cropped.png"];
    } else {
        self.titleLabel.text = [NSString stringWithFormat:@"Representative, %@ / d:%@",state,district];
        self.fedRepPortrait.image = [UIImage imageNamed:@"Seal_of_Congress_Cropped.png"];
    }
    
    // Load Rep Image - if available
    if([dictionary valueForKey:@"image"]){
        self.fedRepPortrait.image = [dictionary valueForKey:@"image"];
    }
    self.fedRepPortrait.layer.cornerRadius = 2;
    self.fedRepPortrait.clipsToBounds = YES;
    self.fedRepPortrait.layer.borderColor = [[UIColor blackColor]CGColor];
    self.fedRepPortrait.layer.borderWidth = 1;
    
    // Phone Number
    self.phoneNumberDC.text = [dictionary valueForKey:@"phone"];
    
    // Phone Touch Area
    self.phoneTouchArea.layer.cornerRadius = 2;
    self.phoneTouchArea.clipsToBounds = YES;
    self.phoneTouchArea.layer.borderColor = [[UIColor blackColor]CGColor];
    self.phoneTouchArea.layer.borderWidth = 1;
    
    // Content View
    self.contentView.layer.borderColor = [[UIColor blackColor]CGColor];
    self.contentView.layer.borderWidth = 0;
    self.contentView.layer.cornerRadius = 3;
    self.contentView.clipsToBounds = YES;
    self.layer.cornerRadius = 3;
    self.clipsToBounds = YES;
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
