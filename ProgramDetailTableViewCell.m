//
//  ProgramDetailTableViewCell.m
//  Oingo
//
//  Created by Matthew Acalin on 5/5/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "ProgramDetailTableViewCell.h"
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

@interface ProgramDetailTableViewCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *purposeSummary;
@property (weak, nonatomic) NSURLRequest *urlRequest;


@end


@implementation ProgramDetailTableViewCell

- (void) configCampaignCell:campaign {
    self.purposeSummary.text = [campaign valueForKey:@"purposeSummary"];
    self.linkToContentButton.titleLabel.text = [campaign valueForKey:@"linkToContent"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
