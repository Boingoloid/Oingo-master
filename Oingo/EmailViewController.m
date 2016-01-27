//
//  EmailViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 1/24/16.
//  Copyright © 2016 Oingo Inc. All rights reserved.
//

#import "EmailViewController.h"
#import <MessageUI/MessageUI.h>
#import <ParseAPI.h>

@interface EmailViewController () <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>

@end

@implementation EmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showMailPickerWithAction:self.selectedAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Rotation

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
// -------------------------------------------------------------------------------
//  shouldAutorotateToInterfaceOrientation:
//  Disable rotation on iOS 5.x and earlier.  Note, for iOS 6.0 and later all you
//  need is "UISupportedInterfaceOrientations" defined in your Info.plist
// -------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#endif


#pragma mark - Actions

// -------------------------------------------------------------------------------
//  showMailPicker:
//  IBAction for the Compose Mail button.
// -------------------------------------------------------------------------------
- (void)showMailPickerWithAction:(NSMutableDictionary*)selectedAction {
    if ([MFMailComposeViewController canSendMail]){
        
        [self displayMailComposerSheet:(NSMutableDictionary*)selectedAction];
        
    } else {
       //display message
    }
}

#pragma mark - Compose Mail/SMS

// -------------------------------------------------------------------------------
//  displayMailComposerSheet
//  Displays an email composition interface inside the application.
//  Populates all the Mail fields.
// -------------------------------------------------------------------------------
- (void)displayMailComposerSheet:(NSMutableDictionary*)selectedAction
{
    
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    NSString *header;
    NSString *subject;
    
    if([[self.collectionData firstObject] valueForKey:@"bioguide_id"]){
    
        subject = [self.selectedAction valueForKey:@"emailSubject"];
        if([subject length]==0){
            subject = @"";
        }
        header = [NSString stringWithFormat:@"To those who represent me,"];
        NSString *body = [self.selectedAction valueForKey:@"emailMessageText"];
        if([body length]==0){
            body = @"";
        }
        NSString *linkToContent = [NSString stringWithFormat:@"Here is a link I found relevant: %@",[self.selectedSegment valueForKey:@"linkToContent"]];
        NSString *pushThoughtFooter = [NSString stringWithFormat:@"Sincerely,"];
        NSString *fullEmailBodyText =[NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n\n%@", header, body, linkToContent, pushThoughtFooter];

        // grab Recipients emails
        NSMutableArray *toRecipients = [[NSMutableArray alloc]init];
        for (NSMutableDictionary *dict in self.fedRepList){
            NSString *email = [dict objectForKey:@"oc_email"];
            [toRecipients addObject:email];
        }
        
        // Set values of picker
        [picker setToRecipients:toRecipients];
        //[picker setBccRecipients:toRecipients];
        [picker setSubject:subject];
        [picker setMessageBody:fullEmailBodyText isHTML:NO];
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:picker animated:YES completion:NULL];
        
        //Assign text values (subject and body) for saving in sent messages
        self.sentEmailSubject = subject;
        self.sentEmailBody = fullEmailBodyText;
        
    } else {
        subject = [self.selectedAction valueForKey:@"emailSubject"];
        if([subject length]==0){
            subject = @"";
        }
        header = [NSString stringWithFormat:@""];
        NSString *body = [self.selectedAction valueForKey:@"emailMessageText"];
        if([body length]==0){
            body = @"";
        }
        
        //NSString *linkToContent = [NSString stringWithFormat:@": %@",[self.selectedSegment valueForKey:@"linkToContent"]];
        NSString *pushThoughtFooter = [NSString stringWithFormat:@"Sincerely,"];
        NSString *fullEmailBodyText =[NSString stringWithFormat:@"%@\n\n%@\n\n\n%@", header, body, pushThoughtFooter];
        
        // grab Recipients emails
        NSMutableArray *toRecipients = [[NSMutableArray alloc]init];
        for (NSMutableDictionary *dict in self.collectionData){
            if([[dict valueForKey:@"isSelected"] intValue]){
                NSString *email = [dict objectForKey:@"email"];
                [toRecipients addObject:email];
            } else {
                // Do not add to recipients if not selected
            }
        }
        
        // Set values of picker
        [picker setToRecipients:toRecipients];
        //[picker setBccRecipients:toRecipients];
        [picker setSubject:subject];
        [picker setMessageBody:fullEmailBodyText isHTML:NO];
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:picker animated:YES completion:NULL];
        
        //Assign text values (subject and body) for saving in sent messages
        self.sentEmailSubject = subject;
        self.sentEmailBody = fullEmailBodyText;
    }
}


#pragma mark - Delegate Methods

// -------------------------------------------------------------------------------
//  mailComposeController:didFinishWithResult:
//  Dismisses the email composition interface when users tap Cancel or Send.
//  Proceeds to update the message field with the result of the operation.
// -------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: email canceled");
            [self dismissViewControllerAnimated:NO completion:nil];
            [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@NO afterDelay:0.0];
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: Mail saved");
            [self dismissViewControllerAnimated:NO completion:NULL];
            [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@NO afterDelay:0.0];
            break;
        case MFMailComposeResultSent:{
            NSLog(@"Result: Mail sent");
            
            //  SAVING MESSAGE DATA TO PARSE
            PFUser *currentUser = [PFUser currentUser];
            PFObject *sentMessageItem = [PFObject objectWithClassName:@"sentMessages"];
            [sentMessageItem setObject:self.sentEmailBody forKey:@"messageText"];
            [sentMessageItem setObject:@"email" forKey:@"messageType"];
            [sentMessageItem setObject:[self.selectedAction valueForKey:@"messageCategory"] forKey:@"messageCategory"];
            [sentMessageItem setObject:[self.selectedSegment valueForKey:@"objectId"] forKey:@"segmentObjectId"];
            
            if(currentUser){
                NSString *userObjectId = currentUser.objectId;
                [sentMessageItem setObject:userObjectId forKey:@"userObjectID"];
            }
            NSLog(@"printing current user:%@",currentUser);

            
            [sentMessageItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //save currentUser to parse disk
                if(error){
                    NSLog(@"error, message not saved");
                }
                else {
                    NSLog(@"no error, message saved");
                }
            }];
            [self dismissViewControllerAnimated:NO completion:NULL];
            [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@NO afterDelay:0.0];
            break;
        }
            
        case MFMailComposeResultFailed:
            NSLog(@"Result: Mail sending failed");
            [self dismissViewControllerAnimated:NO completion:NULL];
            [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@NO afterDelay:0.0];
            break;
        default:
            NSLog(@"Result: Mail not sent");
            [self dismissViewControllerAnimated:NO completion:NULL];
            [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@NO afterDelay:0.0];
            break;
    }

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
