//
//  LocalRepActionTableViewCell.h
//  Oingo
//
//  Created by Matthew Acalin on 12/12/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalRepActionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *actionTitleLabel;
@property (nonatomic) NSString *actioniCategory;
@property (nonatomic) NSMutableArray *actionOptionsList;

-(LocalRepActionTableViewCell*) configLocalRepActionCell:(NSMutableDictionary*)actionDict;

@end
