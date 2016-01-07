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
    
    if(self.viewController.segmentedControlTableView.selectedSegmentIndex == 0){
        
        self.tableViewPrimaryLabel.text = [actionDict valueForKey:@"messageText"];
        
        NSDictionary *sentMessage = (NSDictionary*)actionDict;
        NSNumber *numberCount = (NSNumber*)[sentMessage valueForKey:@"messageCount"];

        int num = [numberCount intValue];
        
        if (num > 1) {
            self.tableViewSecondaryLabel.hidden = NO;
            self.tableViewSecondaryLabel.text = [NSString stringWithFormat:@"%d",num];
            //NSLog(@"YES");
        } else {
            self.tableViewSecondaryLabel.hidden = YES;
            //NSLog(@"NO");
        }
    } else {
        NSDictionary *hashtag = (NSDictionary*)actionDict;
        self.tableViewPrimaryLabel.text = [hashtag valueForKey:@"hashtag"];
        self.tableViewSecondaryLabel.text = [NSString stringWithFormat:@"%@",[hashtag valueForKey:@"frequency"]];
        self.tableViewSecondaryLabel.hidden = NO;
    }
//    // TwitterID
//    NSString *twitterID = [actionDict valueForKey:@"twitter_id"];
//    self.twitterID.text = [NSString stringWithFormat:@"@%@",twitterID];


    
    return self;
}





@end
