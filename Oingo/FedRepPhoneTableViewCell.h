//
//  FedRepPhoneTableViewCell.h
//  Oingo
//
//  Created by Matthew Acalin on 1/19/16.
//  Copyright © 2016 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FedRepPhoneTableViewCell : UITableViewCell

// Controls
@property (weak, nonatomic) IBOutlet UIImageView *fedRepPortrait;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *phoneNumberDC;
@property (weak, nonatomic) IBOutlet UILabel *locationDCLabel;

@property (weak, nonatomic) IBOutlet UIImageView *phoneTouchArea;
@property (weak, nonatomic) IBOutlet UIImageView *phoneIcon;


-(FedRepPhoneTableViewCell*)configCell:(NSMutableDictionary*)dictionary;

@end
