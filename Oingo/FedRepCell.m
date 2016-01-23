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
    self.tableViewPrimaryLabel.hidden = NO;
    self.tableViewSecondaryLabel.hidden = NO;
    self.tableViewNameLabel.hidden = NO;
    
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
        
        // set name label
        
        // if user default is set to hide
        // then height = 0
        // else if bool set to hide
        
        BOOL isHidden = [[actionDict objectForKey:@"isHidden"] boolValue];
        NSLog(@"isHiddenBool:%d WithMessage:%@",isHidden,[sentMessage valueForKey:@"messageText"]);
        int randomUserNumber = [self randomNumberBetween:10000000 maxNumber:99999999];
        
        if(!isHidden){
            //self.tableViewNameLabel.text = [actionDict valueForKey:@"twitterId"];
            self.tableViewNameLabel.text = [NSString stringWithFormat:@"user%d",randomUserNumber];
        } else {
            self.tableViewPrimaryLabel.hidden = YES;
            self.tableViewSecondaryLabel.hidden = YES;
            self.tableViewNameLabel.hidden = YES;
        }
    } else {
        NSDictionary *hashtag = (NSDictionary*)actionDict;
        self.tableViewPrimaryLabel.text = [hashtag valueForKey:@"hashtag"];
        self.tableViewSecondaryLabel.text = [NSString stringWithFormat:@"%@",[hashtag valueForKey:@"frequency"]];
        self.tableViewSecondaryLabel.hidden = NO;
        self.tableViewNameLabel.hidden = YES;
    }
//    // TwitterID
//    NSString *twitterID = [actionDict valueForKey:@"twitter_id"];
//    self.twitterID.text = [NSString stringWithFormat:@"@%@",twitterID];


    
    return self;
}

- (int)randomNumberBetween:(int)min maxNumber:(int)max
{
    return min + arc4random_uniform(max - min + 1);
}



@end
