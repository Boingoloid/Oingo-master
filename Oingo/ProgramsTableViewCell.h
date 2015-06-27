//
//  ProgramsTableViewCell.h
//  Oingo
//
//  Created by Matthew Acalin on 5/6/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ProgramsTableViewCell : UITableViewCell

- (void)configProgramCell:program indexPath:(NSIndexPath *)indexPath isFinished:(BOOL)isFinished;

@end
