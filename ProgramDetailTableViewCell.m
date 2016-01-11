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





@end


@implementation ProgramDetailTableViewCell

- (void) configSegmentCell:segment {
    
    //    // Design Helpers: Borders to see placement
    //    self.segmentTitleLabel.layer.borderWidth = 1;
    //    self.segmentTitleLabel.layer.borderColor = [[UIColor blackColor] CGColor];
    //    self.dateLabel.layer.borderWidth = 1;
    //    self.dateLabel.layer.borderColor = [[UIColor blackColor] CGColor];
    
    // Format contentView
//    self.contentView.layer.borderColor = [[UIColor blackColor] CGColor];
//    self.contentView.layer.borderWidth = .5;
    self.contentView.layer.cornerRadius = 3;
    self.contentView.clipsToBounds = YES;
    
    
    // Assign values
    self.segmentTitleLabel.text = [segment valueForKey:@"segmentTitle"];
    self.purposeSummary.text = [segment valueForKey:@"purposeSummary"];
    [self.linkToContentButton setTitle:[segment valueForKey:@"linkToContent"] forState:UIControlStateNormal];
    
    // Get the date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSDate *date =[segment valueForKey:@"dateReleased"];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
//    NSLog(@"formattedDateString: %@", formattedDateString);
//    [dateFormatter setDateFormat:@"EE MMM, dd"];
//    NSString *todayString = [dateFormatter stringFromDate:today];

    self.dateLabel.text = formattedDateString;
    
    // Get the image
    PFFile *theImage = [segment objectForKey:@"segmentImage"];
    NSData *imageData = [theImage getData];
    UIImage *image = [UIImage imageWithData:imageData];
    self.segmentImage.image = image;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}
- (void)setFrame:(CGRect)frame {
    int inset = 10;
    frame.origin.x += inset; //equal to saying originx = originx + inset
    frame.size.width -= 2 * inset; //mult by 2 b/c taking from both sides
    [super setFrame:frame];
}




@end
