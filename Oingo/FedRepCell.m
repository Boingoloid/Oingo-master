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
    
    self.tableViewPrimaryLabel.text = [actionDict valueForKey:@"messageText"];
    //NSLog(@"action dict message:%@",[actionDict valueForKey:@"messageText"]);
    
    NSDictionary *sentMessage = (NSDictionary*)actionDict;
    NSNumber *numberCount = (NSNumber*)[sentMessage valueForKey:@"messageCount"];
    //NSLog(@"sentMessage count:%@ and class:%@",numberCount, [numberCount class]);
    
    int num = [numberCount intValue];
    
    if (num > 1) {
        self.tableViewSecondaryLabel.hidden = NO;
        self.tableViewSecondaryLabel.text = [NSString stringWithFormat:@"%d",num];
        //NSLog(@"YES");
    } else {
        self.tableViewSecondaryLabel.hidden = YES;
        //NSLog(@"NO");
    }

//    // TwitterID
//    NSString *twitterID = [actionDict valueForKey:@"twitter_id"];
//    self.twitterID.text = [NSString stringWithFormat:@"@%@",twitterID];
    
    return self;
}
@end
