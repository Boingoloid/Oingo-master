//
//  MessagePanelViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 10/6/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "MessagePanelViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "Segment.h"
#import "Program.h"
#import <Parse/Parse.h>
#import "SignUpViewController.h"

@interface MessagePanelViewController () <UIGestureRecognizerDelegate,UITextViewDelegate,UITableViewDataSource, UITableViewDelegate>

@end

@implementation MessagePanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    PFUser *currentUser = [PFUser currentUser];
    
    if(!currentUser) {
        NSLog(@"No user signed in");
    } else {
        
        NSString *selectedSegmentID = [self.messageTableViewController.selectedSegment valueForKey:@"segmentID"];
        NSString *category = [self.selectedMessageDictionary valueForKey:@"messageCategory"];

        
        //get message data for segment menu
        PFQuery *query = [PFQuery queryWithClassName:@"sentMessages"];
        [query whereKey:@"segmentID" equalTo:selectedSegmentID];
        [query whereKey:@"messageType" equalTo:@"twitter"];
        [query whereKey:@"messageCategory" equalTo:category];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.sentMessagesForSegment = objects;
                    NSLog(@"loading data from sentMessagesList%@:",self.sentMessagesForSegment);
                    [self.tableView reloadData];
                });
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }

    
    
    
    // Assign Values
    self.messageTextView.text = [[self.menuList objectAtIndex:[self.originRowIndex intValue]] valueForKey:@"messageText"];
    
    [self.includeLinkToggle setOn:YES animated:NO];

    NSNumber *includeLinkNumber = [self.selectedMessageDictionary objectForKey:@"isLinkIncluded"];
    bool includeLinkBool = [includeLinkNumber boolValue];
    
    if(includeLinkBool){
    } else {
        [self.includeLinkToggle setOn:NO animated:YES];
    }
    
    // Format messageTextView field
    self.messageTextView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.messageTextView.layer.borderWidth = 0;
    self.messageTextView.layer.backgroundColor = [[UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1] CGColor];
    self.messageTextView.clipsToBounds = YES;
    self.messageTextView.layer.cornerRadius = 3;
    [self.messageTextView setKeyboardType:UIKeyboardTypeTwitter];
    self.messageTextView.delegate = self;
 
    
    // Format Cancel Button
    self.cancelButton.layer.borderColor = [[UIColor colorWithRed:13/255.0 green:81/255.0 blue:183/255.0 alpha:1] CGColor];
    self.cancelButton.layer.borderWidth = 1;
    self.cancelButton.layer.cornerRadius = 3;
    self.cancelButton.clipsToBounds = YES;
    self.cancelButton.backgroundColor = [UIColor clearColor];
    
    // Format loadMessage Button
    self.loadMessageButton.layer.borderColor = [[UIColor colorWithRed:13/255.0 green:81/255.0 blue:183/255.0 alpha:1] CGColor];
    self.loadMessageButton.layer.borderWidth = 1;
    self.loadMessageButton.layer.cornerRadius = 3;
    self.loadMessageButton.clipsToBounds = YES;
    self.loadMessageButton.backgroundColor = [UIColor clearColor];
    
    // Format linkToContent
    self.linkToContent.text = [self.selectedSegment valueForKey:@"linkToContent"];
    self.linkToContent.layer.borderWidth=0;
    self.linkToContent.layer.borderColor= [[UIColor lightGrayColor] CGColor];
//    NSLog(@"linkToContent:%@",[self.selectedSegment valueForKey:@"linkToContent"]);
//    NSLog(@"Selected Segment:%@",self.selectedSegment);
    [self.linkToContent scrollRangeToVisible:NSMakeRange(0, 0)];
    
    //    [self registerForKeyboardNotifications];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChangeNotification:) name:UITextViewTextDidChangeNotification object:self.messageTextView];

}



//- (void)registerForKeyboardNotifications
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWasShown:)
//                                                 name:UIKeyboardDidShowNotification object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillBeHidden:)
//                                                 name:UIKeyboardWillHideNotification object:nil];
//    
//}

// Called when the UIKeyboardDidShowNotification is sent.
//- (void)keyboardWasShown:(NSNotification*)aNotification
//{
//    NSDictionary* info = [aNotification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
//    self.scrollView.contentInset = contentInsets;
//    self.scrollView.scrollIndicatorInsets = contentInsets;
//    
//    // If active text field is hidden by keyboard, scroll it so it's visible
//    // Your app might not need or want this behavior.
//    CGRect aRect = self.view.frame;
//    aRect.size.height -= kbSize.height;
//    if (!CGRectContainsPoint(aRect, self.messageTextView.frame.origin) ) {
//        [self.scrollView scrollRectToVisible:self.messageTextView.frame animated:YES];
//    }
//}

//- (void)keyboardWasShown:(NSNotification*)aNotification {
//    NSDictionary* info = [aNotification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    CGRect bkgndRect = self.view.superview.frame;
//    bkgndRect.size.height += kbSize.height;
//    [self.view.superview setFrame:bkgndRect];
//    [self.scrollView setContentOffset:CGPointMake(0.0, self.messageTextView.frame.origin.y-kbSize.height) animated:YES];
//}
//
//// Called when the UIKeyboardWillHideNotification is sent
//- (void)keyboardWillBeHidden:(NSNotification*)aNotification
//{
//    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
//    self.scrollView.contentInset = contentInsets;
//    self.scrollView.scrollIndicatorInsets = contentInsets;
//}

//-(void)viewWillDisappear:(BOOL)animated{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
//
//}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.view setNeedsDisplay];
    [self.view layoutIfNeeded];
    //    [self.tableView setNeedsLayout];
    //    [self.view layoutSubviews];
    //    [self.tableView layoutSubviews];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)textViewDidChange:(UITextView *)textView {
    // Update the character count
    long characterCount = [[textView text] length];
    [self.charCountLabel setText:[NSString stringWithFormat:@"%ld", characterCount]];
    
    // Check if the count is over the limit
    if(characterCount > 140) {
        // Change the color to red
        [self.charCountLabel setTextColor:[UIColor redColor]];
    }
    else if(characterCount < 140) {
        // Change the color to white
        [self.charCountLabel setTextColor:[UIColor whiteColor]];
    }
    else {
        // Set normal color to white
        [self.charCountLabel setTextColor:[UIColor whiteColor]];
    }
}

-(void)viewWillAppear:(BOOL)animated{

    //This button covers the entire text view. Sends to sign in if not a user.
    if([PFUser currentUser]){
        self.signInButton.hidden = YES;
    } else {
        self.signInButton.hidden = NO;
    }
    [self textViewDidChange:self.messageTextView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //hide the keyborad
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    NSLog(@"touch.view:%@", touch.view);
    
    if ([self.messageTextView isFirstResponder] && [touch view] != self.messageTextView) {
        [self.messageTextView resignFirstResponder];
    }
}


-(void) pushToSignIn {
    SignUpViewController *signUpViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"signInViewController"];
    signUpViewController.messageTableViewController = self.messageTableViewController;
    [self.navigationController pushViewController:signUpViewController animated:YES];
    
}



/*
#pragma mark - Navigation

 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loadMessage:(id)sender {
//    NSString *postMessage = self.messageTextView.text; 
//    NSString *linkName = [NSString stringWithFormat:@"%@: %@",[self.selectedProgram valueForKey:@"programTitle"],[self.selectedSegment valueForKey:@"segmentTitle"]];  // Everything is the same except for this line.
//    NSString *linkToContent =[[NSString alloc]initWithString:[self.selectedSegment valueForKey:@"linkToContent"]];
//    
//    NSDictionary *parameters = @{@"message" : postMessage,
//                                 @"link" : linkToContent,
//                                 @"name" : linkName
//                                 };
//    //list of parameters: https://developers.facebook.com/docs/graph-api/reference/
//    
//    [self.facebookAPIPost publishFBPostWithParameters:parameters];
    
    [[self.messageTableViewController.menuList objectAtIndex:[self.originRowIndex intValue]] setValue:self.messageTextView.text  forKey:@"messageText"];
    
    [self.messageTableViewController.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}
    
- (IBAction)toggleIncludeLink:(id)sender {
    if([self.includeLinkToggle isOn]){
        [[self.messageTableViewController.menuList objectAtIndex:[self.originRowIndex intValue]] setValue:@YES  forKey:@"isLinkIncluded"];
    }else {
        [[self.messageTableViewController.menuList objectAtIndex:[self.originRowIndex intValue]] setValue:@NO  forKey:@"isLinkIncluded"];
        NSLog(@"Link will not be included");
    }
}
- (IBAction)sendToSignIn:(id)sender {
    [self pushToSignIn];
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of time zones in the region for the specified section.

    return [self.sentMessagesForSegment count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.

    return [NSString stringWithFormat:@"Latest Tweets in (%@)",[self.selectedMessageDictionary valueForKey:@"messageCategory"]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *sentMessage = (NSDictionary*)[self.sentMessagesForSegment objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    // Configure the cell...
    if (cell == nil){
        NSLog(@"cell was nil");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
    }
    NSLog(@"sent message to put in this cell:%@",[sentMessage valueForKey:@"messageText"]);
    cell.textLabel.text = [sentMessage valueForKey:@"messageText"];
    
    //    NSLog(@"messageOption calling config cell%@",messageOption);
    //    [cell configMessageOptionCell:(NSDictionary*)messageOption];
    [cell layoutIfNeeded];
    
    //    NSString *messageText = [[self.messageOptionsListFiltered objectAtIndex:[indexPath row]] valueForKey:@"messageText"];
    //    cell.textLabel.text = messageText;
    //    [cell.textLabel sizeToFit];
    //    cell.textLabel.preferredMaxLayoutWidth = self.view.bounds.size.width;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.messageTextView.text =   cell.textLabel.text;

}





@end
