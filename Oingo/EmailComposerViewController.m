//
//  EmailComposerViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 6/26/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "EmailComposerViewController.h"
#import <MessageUI/MessageUI.h>
#import <Parse/Parse.h>
#import "CongressionalMessageItem.h"
#import "MessageItem.h"

@interface EmailComposerViewController ()<MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>
//MFMessageComposeViewControllerDelegate
// UILabel for displaying the result of the sending the message.
@property (nonatomic, weak) IBOutlet UILabel *feedbackMsg;
@end


@implementation EmailComposerViewController



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
- (void)showMailPicker:(NSString*)email withMessage:(NSString *)message {
    


    
    
    
    // You must check that the current device can send email messages before you
    // attempt to create an instance of MFMailComposeViewController.  If the
    // device can not send email messages,
    // [[MFMailComposeViewController alloc] init] will return nil.  Your app
    // will crash when it calls -presentViewController:animated:completion: with
    // a nil view controller.
    if ([MFMailComposeViewController canSendMail])
        // The device can send email.
    {
        [self displayMailComposerSheet:email withMessage:message];
    }
    else
        // The device can not send email.
    {
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
- (void)displayMailComposerSheet:email withMessage:message
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    


    NSString *subject = [NSString stringWithFormat:@"Message from local voter re: %@",[self.selectedSegment valueForKey:@"segmentTitle"]];
    [picker setSubject:subject];
    
    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:email];
//    NSArray *ccRecipients = [NSArray arrayWithObjects:@"", nil];
//    NSArray *bccRecipients = [NSArray arrayWithObject:@""];
    
    [picker setToRecipients:toRecipients];
//    [picker setCcRecipients:ccRecipients];
//    [picker setBccRecipients:bccRecipients];
    
    // Attach an image to the email
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"jpg"];
//    NSData *myData = [NSData dataWithContentsOfFile:path];
//    [picker addAttachmentData:myData mimeType:@"image/jpeg" fileName:@"rainy"];
    
    // Fill out the email body text

    
    NSString *pushThoughtFooter = @"Sent via PushThought App!";
    NSString *emailBody = message;
    NSString *fullEmailBodyText =[NSString stringWithFormat:@"%@\n\nPlease check out this segment for background:%@\n\n%@",emailBody, [self.selectedSegment valueForKey:@"linkToContent"],pushThoughtFooter];
    [picker setMessageBody:fullEmailBodyText isHTML:NO];
    
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
            [self dismissViewControllerAnimated:YES completion:NULL];
            [self dismissViewControllerAnimated:YES completion:NULL];
            NSLog(@"email canceled");
        case MFMailComposeResultSaved:
//            self.feedbackMsg.text = @"Result: Mail saved";
            [self dismissViewControllerAnimated:YES completion:NULL];
            [self dismissViewControllerAnimated:YES completion:NULL];
            NSLog(@"email saved");
        case MFMailComposeResultSent:{
//            self.feedbackMsg.text = @"Result: Mail sent";
            [self dismissViewControllerAnimated:YES completion:NULL];
            [self dismissViewControllerAnimated:YES completion:NULL];
            
            
            //  SAVING MESSAGE DATA TO PARSE
            PFUser *currentUser = [PFUser currentUser];
            NSLog(@"printing current user:%@",currentUser);
            
            PFObject *sentMessageItem = [PFObject objectWithClassName:@"sentMessages"];
            [sentMessageItem setObject:self.sentEmailBody forKey:@"messageText"];
            [sentMessageItem setObject:@"email" forKey:@"messageType"];
            [sentMessageItem setObject:[self.selectedSegment valueForKey:@"segmentID"] forKey:@"segmentID"];
            [sentMessageItem setObject:[currentUser valueForKey:@"username"] forKey:@"username"];
            NSString *userObjectID = currentUser.objectId;
            [sentMessageItem setObject:userObjectID forKey:@"userObjectID"];
            
            //if segment then skip, else don't
            
            if ([self.selectedContact isKindOfClass:[CongressionalMessageItem class]]) {
                NSLog(@"Congressional Message Item Class");
                NSString *bioguide_id = [self.selectedContact valueForKey:@"bioguide_id"];
                NSString *fullName = [self.selectedContact valueForKey:@"fullName"];
                [sentMessageItem setObject:bioguide_id forKey:@"contactID"];
                [sentMessageItem setObject:fullName forKey:@"contactName"];
            } else {
                NSLog(@"Regular Contact Item Class");
                NSString *contactID = [self.selectedContact valueForKey:@"contactID"];
                NSString *targetName = [self.selectedContact valueForKey:@"targetName"];
                [sentMessageItem setObject:contactID forKey:@"contactID"];
                [sentMessageItem setObject:targetName forKey:@"contactName"];
            }
            NSLog(@"printing save object:%@",sentMessageItem);
            
            [sentMessageItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //save currentUser to parse disk
                if(error){
                    NSLog(@"error, message not saved");
                }
                else {
                    NSLog(@"no error, message saved");
                }
            }];
            
            NSLog(@"Got here in the save 2:%@",sentMessageItem);
            [self.messageTableViewController viewDidLoad];
            
        }
//            break;
        case MFMailComposeResultFailed:
//            self.feedbackMsg.text = @"Result: Mail sending failed";
            [self dismissViewControllerAnimated:YES completion:NULL];
            [self dismissViewControllerAnimated:YES completion:NULL];
//            break;
        default:
//            self.feedbackMsg.text = @"Result: Mail not sent";
            [self dismissViewControllerAnimated:YES completion:NULL];
            [self dismissViewControllerAnimated:YES completion:NULL];
//            break;
    }
//    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)viewDidLoad {
    [super viewDidLoad];


    //Add label accompanying text entry
    //    self.feedbackMsg = [[UILabel alloc]initWithFrame:CGRectMake(159, 8, 150, 15)];
    //    self.zipLabel.text = @"or";
    //    self.zipLabel.font = [UIFont boldSystemFontOfSize:13];
    //    self.zipLabel.textColor = [UIColor blackColor];
    //    self.zipLabel.tag = 2222;
    //    [self.contentView addSubview:self.zipLabel];
    //    
    
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
