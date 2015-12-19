//
//  FedRepCell.h
//  Oingo
//
//  Created by Matthew Acalin on 12/17/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FederalRepActionDashboardViewController.h"

@interface FedRepCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *twitterID;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
@property (weak, nonatomic) IBOutlet UIImageView *tweetTouchArea;
@property (weak, nonatomic) IBOutlet UIImageView *tweetSuccessImage;

@property (nonatomic) FederalRepActionDashboardViewController *viewController;

-(FedRepCell*)configCell:(NSMutableDictionary*)actionDict;
    
@end
