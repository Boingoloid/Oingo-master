//
//  LongFormEmailViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 10/7/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "LongFormEmailViewController.h"
#import <MessageUI/MessageUI.h>
#import <Parse/Parse.h>
#import "CongressionalMessageItem.h"
#import "MessageItem.h"

@interface LongFormEmailViewController () <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, weak) IBOutlet UILabel *feedbackMsg;
@end

@implementation LongFormEmailViewController



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
- (void)showMailPicker{
    if ([MFMailComposeViewController canSendMail]){
        [self displayMailComposerSheet];
    } else {
        self.feedbackMsg.hidden = NO;
        self.feedbackMsg.text = @"Device not configured to send mail.";
    }
}


#pragma mark - Compose Mail/SMS

// -------------------------------------------------------------------------------
//  displayMailComposerSheet
//  Displays an email composition interface inside the application.
//  Populates all the Mail fields.
// -------------------------------------------------------------------------------
- (void)displayMailComposerSheet {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:self.emailSubject];
    
    PFUser *currentUser = [PFUser currentUser];
    NSString *userEmail = currentUser.email;
    NSLog(@"User email - long form email VC:%@",userEmail);
    NSArray *toRecipients = [NSArray arrayWithObject:userEmail];
    NSArray *bccRecipients = [self.emailRecipients componentsSeparatedByString:@","];
    //    NSArray *ccRecipients = [NSArray arrayWithObjects:@"", nil];

    
    [picker setToRecipients:toRecipients];
    [picker setBccRecipients:bccRecipients];
    //    [picker setCcRecipients:ccRecipients];

    
    // Attach an image to the email
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"jpg"];
    //    NSData *myData = [NSData dataWithContentsOfFile:path];
    //    [picker addAttachmentData:myData mimeType:@"image/jpeg" fileName:@"rainy"];
    
    // Fill out the email body text
    

    NSString *emailBody = self.emailBody;
    NSString *nameSignature = [NSString stringWithFormat:@"Sincerely,\n\n%@ %@",self.firstName,self.lastName];
    NSString *pushThoughtFooter = @"";
    NSString *fullEmailBodyText =[NSString stringWithFormat:@"%@\n\n%@\n\n%@",emailBody,nameSignature,pushThoughtFooter];
    [picker setMessageBody:fullEmailBodyText isHTML:NO];
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    //Assign text values (subject and body) for saving in sent messages
    
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
    NSLog(@"result from email%u",result);
    
    if(result == MFMailComposeResultCancelled){
        NSLog(@"true, cancelled:%u",result);
        
    }else if(result == MFMailComposeResultSaved) {
        NSLog(@"NOT cancelled:%u",result);
    }
    
    
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"compose cancelled");
            [self dismissViewControllerAnimated:YES completion:NULL];
            [self.navigationController popViewControllerAnimated:NO];
            NSLog(@"email canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"compose saved");
            //            self.feedbackMsg.text = @"Result: Mail saved";
            [self dismissViewControllerAnimated:YES completion:NULL];
            [self.navigationController popViewControllerAnimated:NO];
            NSLog(@"email saved");
            break;
        case MFMailComposeResultSent:{
            NSLog(@"compose sent");
            //            self.feedbackMsg.text = @"Result: Mail sent";
            [self dismissViewControllerAnimated:YES completion:NULL];
            [self.navigationController popViewControllerAnimated:NO];
            
            
            //  SAVING MESSAGE DATA TO PARSE
            PFUser *currentUser = [PFUser currentUser];
            NSLog(@"printing current user:%@",currentUser);
            
            PFObject *sentMessageItem = [PFObject objectWithClassName:@"sentMessages"];
            [sentMessageItem setObject:self.emailBody forKey:@"messageText"];
            [sentMessageItem setObject:self.emailRecipients forKey:@"emailRecipients"];
            [sentMessageItem setObject:@"Long Form Email" forKey:@"messageType"];
            [sentMessageItem setObject:[self.selectedSegment valueForKey:@"segmentID"] forKey:@"segmentID"];
            [sentMessageItem setObject:[currentUser valueForKey:@"username"] forKey:@"username"];
            NSString *userObjectID = currentUser.objectId;
            [sentMessageItem setObject:userObjectID forKey:@"userObjectID"];
            NSLog(@"printing save object:%@",sentMessageItem);
            
            
            // Save the sent email object
            [sentMessageItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //save message data to parse
                if(error){
                    NSLog(@"error, message not saved");
                }
                else {
                    NSLog(@"no error, message saved");
                }
            }];
            
             // update user with name information
            [currentUser setObject:self.firstName forKey:@"firstNameEmail"];
            [currentUser setObject:self.lastName forKey:@"lastNameEmail"];
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //save currentUser to parse disk
                if(error){
                    NSLog(@"error, user full name failed to update");
                }
                else {
                    NSLog(@"no error, full name was updated fine");
                }
            }];
            
            NSLog(@"Got here in the save 2:%@",sentMessageItem);
            [self.messageTableViewController viewDidLoad];
            break;
        }

        case MFMailComposeResultFailed:
            //self.feedbackMsg.text = @"Result: Mail sending failed";
            [self dismissViewControllerAnimated:YES completion:NULL];
            [self.navigationController popViewControllerAnimated:NO];
            break;
        default:
            //self.feedbackMsg.text = @"Result: Mail not sent";
            [self dismissViewControllerAnimated:YES completion:NULL];
            [self.navigationController popViewControllerAnimated:NO];
            break;
    }
    //    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

@end
