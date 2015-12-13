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
@property (weak, nonatomic) IBOutlet UITextView *purposeSummary;
@property (weak, nonatomic) NSURLRequest *urlRequest;
@property (weak, nonatomic) IBOutlet UIImageView *segmentTypeImage;
@property (weak, nonatomic) IBOutlet UILabel *segmentTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *altPathButton;
- (void)configSegmentCell:segment;

@end
