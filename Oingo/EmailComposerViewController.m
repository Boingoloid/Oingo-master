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
    if ([MFMailComposeViewController canSendMail]){

        [self displayMailComposerSheet:email withMessage:message];

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
- (void)displayMailComposerSheet:email withMessage:message
{

    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    NSLog(@"selected contact value:%@",[self.selectedContact valueForKey:@"chamber"]);
        NSLog(@"selected contact value:%@",[self.selectedContact valueForKey:@"chamber"]);
    
    
    NSString *header;
    NSString *subject;
    if([[self.selectedContact valueForKey:@"messageCategory"] isEqualToString:@"Local Representative"]){
        
        if([[self.selectedContact valueForKey:@"chamber"] isEqualToString:@"Senator"]){
            header = [NSString stringWithFormat:@"Senator %@,",[self.selectedContact valueForKey:@"lastName"]];
        } else{
            header = [NSString stringWithFormat:@"Representative %@,",[self.selectedContact valueForKey:@"lastName"]];
        }
        subject = [NSString stringWithFormat:@"Thought to share from local voter"];
    } else {
        header = [NSString stringWithFormat:@"%@,",[self.selectedContact valueForKey:@"targetName"]];
        subject = [NSString stringWithFormat:@"Thought I'd like to share"];
    }
    
    NSString *body = message;
    
    NSString *linkToContent;
    NSNumber *isLinkIncludedNumber = [self.selectedMessageDictionary valueForKey:@"isLinkIncluded"];
    bool isLinkIncludedBool = [isLinkIncludedNumber boolValue];
    if(isLinkIncludedBool == 0){
        linkToContent = @"";
    } else {
        linkToContent = [NSString stringWithFormat:@"When you have a moment, please take a look at this segment: %@",[self.selectedSegment valueForKey:@"linkToContent"]];
    }
    
    NSString *pushThoughtFooter = @"sent via pushthought";
    
    // Get the isLinkIncluded bool to see if user wants to include link

    
    
    

    
    NSString *fullEmailBodyText =[NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n\n%@", header, body, linkToContent, pushThoughtFooter];
    
    // Next step would be to build changes if Local Rep
    
    
    // grab Recipients emails
    NSArray *toRecipients = [NSArray arrayWithObject:email];
    
    // Set values of picker
    [picker setToRecipients:toRecipients];
    [picker setSubject:subject];
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
            [self.navigationController popViewControllerAnimated:YES];
            NSLog(@"email canceled");
            break;
        case MFMailComposeResultSaved:
//            self.feedbackMsg.text = @"Result: Mail saved";
            [self dismissViewControllerAnimated:NO completion:NULL];
            [self.navigationController popViewControllerAnimated:YES];
            NSLog(@"email saved");
            break;
        case MFMailComposeResultSent:{
//            self.feedbackMsg.text = @"Result: Mail sent";
            [self dismissViewControllerAnimated:NO completion:NULL];
            [self.navigationController popViewControllerAnimated:YES];
            
            
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
            
            //if segment then skip
            
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
        break;
        }
            
        case MFMailComposeResultFailed:
//            self.feedbackMsg.text = @"Result: Mail sending failed";
            [self dismissViewControllerAnimated:NO completion:NULL];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        default:
//            self.feedbackMsg.text = @"Result: Mail not sent";
            [self dismissViewControllerAnimated:NO completion:NULL];
            [self.navigationController popViewControllerAnimated:YES];
            break;
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
