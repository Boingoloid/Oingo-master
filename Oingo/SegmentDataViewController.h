//
//  SegmentDataViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 12/2/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageTableViewController.h"

@interface SegmentDataViewController : UIViewController
@property (nonatomic) MessageTableViewController *messageTableViewController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)segmentedControlClick:(id)sender;



@end
