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
    
    subject = [self.selectedAction valueForKey:@"emailSubject"];
    header = [NSString stringWithFormat:@"To those who represent me,"];
    
    NSString *body = [self.selectedAction valueForKey:@"emailMessageText"];
    
    NSString *linkToContent = [NSString stringWithFormat:@"Here is a link to some content I found interesting: %@",[self.selectedSegment valueForKey:@"linkToContent"]];
    
    //NSNumber *isLinkIncludedNumber = [self.selectedMessageDictionary valueForKey:@"isLinkIncluded"];
//    bool isLinkIncludedBool = [isLinkIncludedNumber boolValue];
//    if(isLinkIncludedBool == 0){
//        linkToContent = @"";
//    } else {
//        linkToContent = [NSString stringWithFormat:@"When you have a moment, please take a look at this segment: %@",[self.selectedSegment valueForKey:@"linkToContent"]];
//    }
    
    NSString *pushThoughtFooter = [NSString stringWithFormat:@"Sincerely,"];
    
    // Get the isLinkIncluded bool to see if user wants to include link
    
    NSString *fullEmailBodyText =[NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n\n%@", header, body, linkToContent, pushThoughtFooter];
    
    // Next step would be to build changes if Local Rep
    
    
    // grab Recipients emails
    NSMutableArray *toRecipients = [[NSMutableArray alloc]init];
    for (NSMutableDictionary *dict in self.fedRepList){
        NSString *email = [dict objectForKey:@"oc_email"];
        [toRecipients addObject:email];
    }
    
    //CYCLE TO LIST AND PULL EMAILS
    
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
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: Mail saved");
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
            break;
        }
            
        case MFMailComposeResultFailed:
            NSLog(@"Result: Mail sending failed");
            break;
        default:
            NSLog(@"Result: Mail not sent");
            break;
    }
        [self dismissViewControllerAnimated:NO completion:NULL];
        [self.navigationController popViewControllerAnimated:NO];
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
