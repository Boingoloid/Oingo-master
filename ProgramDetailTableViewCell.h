//
//  ProgramDetailTableViewCell.h
//  Oingo
//
//  Created by Matthew Acalin on 5/5/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ProgramDetailTableViewCell : UITableViewCell

@property (nonatomic) IBOutlet UIButton *linkToContentButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *segmentImage;

- (void)configSegmentCell:segment;

@end
