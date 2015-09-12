//
//  MessageOptionsTableViewCell.h
//  Oingo
//
//  Created by Matthew Acalin on 5/29/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageOptionsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageOptionLabel;
-(void)configMessageOptionCell:(NSDictionary*)messageOption;
@end
