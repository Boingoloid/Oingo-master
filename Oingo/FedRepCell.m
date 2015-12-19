//
//  FedRepCell.m
//  Oingo
//
//  Created by Matthew Acalin on 12/17/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "FedRepCell.h"

@implementation FedRepCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(FedRepCell*)configCell:(NSMutableDictionary*)actionDict{
    //NSString *actionCategory = [actionDict valueForKey:@"actionCategory"];
    //NSLog(@"actionDic:%@",actionDict);
    // Name, full name, nickname, use nickname for firstname if available.

    
    // Full name
    NSString *nickName = [actionDict valueForKey:@"nickname"];
    NSString *firstName = [actionDict valueForKey:@"first_name"];
    NSString *lastName = [actionDict valueForKey:@"last_name"];
    NSString *fullName;
    NSLog(@"%@ %@ %@ %@",nickName,firstName,lastName,fullName);
    if(![actionDict valueForKey:@"nickName"]){
        fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
    } else {
        fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
    }
    self.name.text = [NSString stringWithFormat:@"%@ /",fullName];
    
    // Title, load based on chamber
    NSString *chamber = [actionDict valueForKey:@"chamber"];
    NSString *state = [actionDict valueForKey:@"state"];
    NSString *district = [actionDict valueForKey:@"district"];
    if([chamber isEqualToString:@"senate"]) {
        self.title.text = [NSString stringWithFormat:@"Senator,%@",state];
        self.imageView.image = [UIImage imageNamed:@"Seal_of_Senate_Cropped.png"];
    } else {
        self.title.text = [NSString stringWithFormat:@"Rep, %@ / d:%@",state,district];
        self.imageView.image = [UIImage imageNamed:@"Seal_of_Congress_Cropped.png"];
    }
    
    // TwitterID
    NSString *twitterID = [actionDict valueForKey:@"twitter_id"];
    self.twitterID.text = [NSString stringWithFormat:@"@%@",twitterID];
    
    return self;
}
@end
