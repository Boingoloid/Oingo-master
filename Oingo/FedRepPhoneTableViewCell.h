//
//  FedRepPhoneTableViewCell.h
//  Oingo
//
//  Created by Matthew Acalin on 1/19/16.
//  Copyright © 2016 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FedRepPhoneTableViewController.h"

@interface FedRepPhoneTableViewCell : UITableViewCell

@property(nonatomic) FedRepPhoneTableViewController *viewController;

// Controls
@property (weak, nonatomic) IBOutlet UIImageView *fedRepPortrait;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *phoneNumberDC;
@property (weak, nonatomic) IBOutlet UILabel *locationDCLabel;

@property (weak, nonatomic) IBOutlet UIImageView *phoneTouchArea;
@property (weak, nonatomic) IBOutlet UIImageView *phoneIcon;
@property (weak, nonatomic) IBOutlet UIImageView *squareImageView;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkBox;

@property (nonatomic) BOOL isSelected;

-(FedRepPhoneTableViewCell*)configCell:(NSMutableDictionary*)dictionary;

@end
