//
//  LeaveFeedbackViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 9/24/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "LeaveFeedbackViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "Segment.h"
#import "Program.h"

@interface LeaveFeedbackViewController ()

@end

@implementation LeaveFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // Format messageTextView field
    self.messageTextView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.messageTextView.layer.borderWidth = 1.0;
    self.messageTextView.clipsToBounds = YES;
    self.messageTextView.layer.cornerRadius = 3;
    [self.messageTextView becomeFirstResponder];
    self.messageTextView.text = nil;
    //[NSString stringWithFormat:@"%@: %@  @PushThought",[self.selectedProgram valueForKey:@"programTitle"],[self.selectedSegment valueForKey:@"segmentTitle"]];  // Everything is the same except for this line.
    
    
    
    // Format Cancel Button
    self.cancelButton.layer.borderColor = [[UIColor colorWithWhite:0.9f alpha:1] CGColor];
    self.cancelButton.layer.cornerRadius = 1;
    self.cancelButton.backgroundColor = [UIColor clearColor];
    
    // Format Send Button
    self.sendButton.layer.borderColor = [[UIColor colorWithWhite:0.9f alpha:1] CGColor];
    self.sendButton.layer.cornerRadius = 1;
    self.sendButton.backgroundColor = [UIColor clearColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

    [self.view layoutIfNeeded];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    //hide the keyborad
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.messageTextView isFirstResponder] && [touch view] != self.messageTextView) {
        [self.messageTextView resignFirstResponder];
    }

}

- (IBAction)send:(id)sender {
    
    //get feedback message and user
    NSString *feedbackMessage = self.messageTextView.text;
    PFUser *currentUser = [PFUser currentUser];
    
    NSString *alertTitle = @"Sending Feedback";
    NSString *alertMessage = [NSString stringWithFormat:@"You are about to send feedback, are you sure?"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSLog(@"cancel action");
    }];
    [alertController addAction:cancelAction];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){

        //  SAVING MESSAGE DATA TO PARSE
        PFObject *feedbackMessageItem = [PFObject objectWithClassName:@"Feedback"];
        [feedbackMessageItem setObject:feedbackMessage forKey:@"feedbackMessage"];
        [feedbackMessageItem setObject:@"topOfSettings" forKey:@"feedbackOrigin"];
        [feedbackMessageItem setObject:[currentUser valueForKey:@"username"] forKey:@"username"];
        NSString *userObjectID = currentUser.objectId;
        [feedbackMessageItem setObject:userObjectID forKey:@"userObjectID"];
        [feedbackMessageItem setObject:currentUser.email forKey:@"email"];
        
        [feedbackMessageItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //save feedback to parse
            if(error){
                NSLog(@"error, feedback not saved");
            }
            else {
                NSLog(@"no error, feedback saved");
            }
        }];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    [alertController addAction:OKAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (IBAction)cancel:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
    // for modal, I think
    // [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
