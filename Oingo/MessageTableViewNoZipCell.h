//
//  MessageTableViewNoZipCell.h
//  Oingo
//
//  Created by Matthew Acalin on 8/28/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTableViewNoZipCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *zipCodeButton;

@property (weak, nonatomic) IBOutlet UIButton *postToFacebookButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UIButton *webFormButton;
@property (weak, nonatomic) IBOutlet UILabel *targetName;
@property (weak, nonatomic) IBOutlet UILabel *sendCount;
@property (weak, nonatomic) IBOutlet UIImageView *messageImage;
@property (weak, nonatomic) IBOutlet UILabel *targetTitleLabel;

// Touch Capture
@property (weak, nonatomic) IBOutlet UIImageView *emailTouchCaptureImageView;
@property (weak, nonatomic) IBOutlet UIImageView *phoneTouchCaptureImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tweetTouchCaptureImageView;
@property (weak, nonatomic) IBOutlet UIImageView *webFormTouchCaptureImageView;

- (void) configMessageCellNoZip:(NSIndexPath*)indexPath;

@end
