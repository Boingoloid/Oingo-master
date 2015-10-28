//
//  MessageTableViewMessageCell.h
//  Oingo
//
//  Created by Matthew Acalin on 7/3/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTableViewMessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageText;




- (void) configMessageCell:messageItem indexPath:(NSIndexPath*)indexPath;
@end
