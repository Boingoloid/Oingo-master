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
//@property (weak, nonatomic) IBOutlet UILabel *targetName;
//@property (weak, nonatomic) IBOutlet UILabel *sendCount;
//@property (weak, nonatomic) IBOutlet UIImageView *messageImage;
//@property (weak, nonatomic) IBOutlet UILabel *targetTitleLabel;
//@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
//@property (weak, nonatomic) IBOutlet UIButton *postToFacebookButton;
//@property (weak, nonatomic) IBOutlet UIButton *emailButton;
//@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
//@property (weak, nonatomic) IBOutlet UIButton *webFormButton;


- (void) configMessageCell:messageItem indexPath:(NSIndexPath*)indexPath;
@end
