//
//  ProgramsTableViewCell.m
//  Oingo
//
//  Created by Matthew Acalin on 5/6/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "ProgramsTableViewCell.h"
#import "Program.h"
#import "ProgramsTableViewController.h"
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface ProgramsTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *programTitle;
@property (weak, nonatomic) IBOutlet UILabel *programDescription;
@property (weak, nonatomic) IBOutlet UIImageView *programImage;

@end

@implementation ProgramsTableViewCell


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configProgramCell:program indexPath:(NSIndexPath *)indexPath isFinished:(BOOL)isFinished{
    if (isFinished) {
        
        //load program image from Parse
        PFFile *theImage = [program objectForKey:@"programImage"];
        NSData *imageData = [theImage getData];
        UIImage *image = [UIImage imageWithData:imageData];
        self.programImage.image = image;

        //hacky way to add padding.  also assigning variables to controls
        NSString* padding = @" "; // # of spaces
        self.programTitle.text = [NSString stringWithFormat:@"%@%@%@", padding, [program valueForKey:@"programTitle"], padding];
        self.programDescription.text = [program valueForKey:@"programDescription"];
    }
    else {
        NSLog(@"in cell no option:%d",isFinished);
    }
}
@end
