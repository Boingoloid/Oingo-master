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
#import <Parse/Parse.h>


@interface ProgramDetailTableViewCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *purposeSummary;
@property (weak, nonatomic) NSURLRequest *urlRequest;


@end


@implementation ProgramDetailTableViewCell

- (void) configSegmentCell:segment {
    
    self.dateLabel = [segment valueForKey:@"date"];
    self.purposeSummary.text = [segment valueForKey:@"purposeSummary"];
    self.linkToContentButton.titleLabel.text = [segment valueForKey:@"linkToContent"];
    
    
    PFFile *theImage = [segment objectForKey:@"segmentImage"];
    NSData *imageData = [theImage getData];
    UIImage *image = [UIImage imageWithData:imageData];


    self.segmentImage.image = image;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
