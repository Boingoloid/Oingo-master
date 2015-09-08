//
//  ComposeViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 9/8/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "ComposeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "Segment.h"
#import "Program.h"

@interface ComposeViewController ()

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    // Format messageTextView field
    self.messageTextView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.messageTextView.layer.borderWidth = 1.0;
    self.messageTextView.clipsToBounds = YES;
    self.messageTextView.layer.cornerRadius = 3;
    self.messageTextView.text = [NSString stringWithFormat:@"%@: %@  @PushThought",[self.selectedProgram valueForKey:@"programTitle"],[self.selectedSegment valueForKey:@"segmentTitle"]];  // Everything is the same except for this line.

    
    
    // Format Cancel Button
    self.cancelButton.layer.borderColor = [[UIColor colorWithWhite:0.9f alpha:1] CGColor];
    self.cancelButton.layer.cornerRadius = 1;
    self.cancelButton.backgroundColor = [UIColor clearColor];
    
    // Format Send Button
    self.sendButton.layer.borderColor = [[UIColor colorWithWhite:0.9f alpha:1] CGColor];
    self.sendButton.layer.cornerRadius = 1;
    self.sendButton.backgroundColor = [UIColor clearColor];

    
    self.linkToContent.text = [self.selectedSegment valueForKey:@"linkToContent"];
    NSLog(@"linkToContent:%@",[self.selectedSegment valueForKey:@"linkToContent"]);
        NSLog(@"Selected Segment:%@",self.selectedSegment);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)send:(id)sender {
    
}

- (IBAction)cancel:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
    
// for modal, I think
// [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}
@end
