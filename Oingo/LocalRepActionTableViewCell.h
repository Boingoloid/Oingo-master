//
//  LocalRepActionTableViewCell.h
//  Oingo
//
//  Created by Matthew Acalin on 12/12/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalRepActionTableViewCell : UITableViewCell

// Controls
@property (weak, nonatomic) IBOutlet UILabel *actionTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *actionImageView;
@property (nonatomic) NSMutableArray *actionOptionsList;

-(LocalRepActionTableViewCell*) configLocalRepActionCell:(NSMutableDictionary*)actionDict;

@end
