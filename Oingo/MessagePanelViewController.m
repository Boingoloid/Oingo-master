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
#import "MessagePanelTableViewCell.h"

@interface MessagePanelViewController () <UIGestureRecognizerDelegate,UITextViewDelegate,UITableViewDataSource, UITableViewDelegate, UITextInputDelegate>

@end

@implementation MessagePanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableSegmentControl.selectedSegmentIndex = 0;
    
//    PFUser *currentUser = [PFUser currentUser];
    
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
                self.sentMessagesForSegment = (NSMutableArray*)objects;
                // create two arrays, add them.
                
                // Get default message from messageOptionsList
                NSString *category = [self.selectedMessageDictionary valueForKey:@"messageCategory"];
                NSUInteger indexDefaultMessage = [self.messageOptionsList indexOfObjectPassingTest:
                                                  ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                                      return [[dict objectForKey:@"messageCategory"] isEqual:category];
                                                  }];
                if (indexDefaultMessage == NSNotFound){
                    NSLog(@"index not found");
                } else {
                    NSLog(@"found and working!!");
                    NSString *defaultMessage =[[self.messageOptionsList objectAtIndex:indexDefaultMessage] valueForKey:@"messageText"];
                    
                    NSMutableDictionary *defaultMessageDictionary = [[NSMutableDictionary alloc]initWithObjectsAndKeys:defaultMessage, @"messageText", 0, @"messageCount", nil];
                
                    NSMutableArray *messageArray= [[NSMutableArray alloc]init];
                    
                    for(NSDictionary *sentMessageDict in objects){
                        if([sentMessageDict valueForKey:@"isDefaultMessage"]){
                            int newCount = [[defaultMessageDictionary valueForKey:@"messageCount"]intValue] +1;
                            [defaultMessageDictionary setObject:[NSNumber numberWithInt:newCount] forKey:@"messageCount"];
                        } else {
                            [messageArray addObject:sentMessageDict];
                        }
                    }
                    
                    NSMutableArray *tableDataArray = [[NSMutableArray alloc]init];
                    [tableDataArray addObject:defaultMessageDictionary];
                    [tableDataArray addObjectsFromArray:messageArray];
                    self.sentMessagesForSegment = tableDataArray;
                
                    
                    NSLog(@"default:%@",defaultMessageDictionary);
                    NSLog(@"default:%@",tableDataArray);
                    
                    self.tableData = self.sentMessagesForSegment;
                    
                    [self getHashtagData];
                }
            });
        }
        }];
    
    // Assign Values
    self.messageTextView.text = [[self.menuList objectAtIndex:[self.originRowIndex intValue]] valueForKey:@"messageText"];
    [self.includeLinkToggle setOn:YES animated:NO];
    NSNumber *includeLinkNumber = [self.selectedMessageDictionary objectForKey:@"isLinkIncluded"];
    bool includeLinkBool = [includeLinkNumber boolValue];
    if(includeLinkBool){
    } else {
        [self.includeLinkToggle setOn:NO animated:YES];
    }
    
    
    //Format Tableview
    self.tableView.layer.borderColor = [[UIColor colorWithRed:13/255.0 green:81/255.0 blue:183/255.0 alpha:1] CGColor];
    self.tableView.layer.borderWidth = 1.0f;
    self.tableView.layer.cornerRadius = 3;
    self.tableView.clipsToBounds = YES;
    
    
    // Format messageTextView field
    self.messageTextView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.messageTextView.layer.borderWidth = 0;
    //self.messageTextView.layer.backgroundColor = [[UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1] CGColor];
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
    [self.linkToContent scrollRangeToVisible:NSMakeRange(0, 0)];
    
    //    [self registerForKeyboardNotifications];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChangeNotification:) name:UITextViewTextDidChangeNotification object:self.messageTextView];
    [self.tableView reloadData];
}


-(void) getHashtagData{
    
    //**************  This should  be moved to Cloud Code at some point.  Pointless to do all this work as the UI is loading when I just need the grouped/summed table
    //get message data for segment menu
    NSString *selectedSegmentID = [self.messageTableViewController.selectedSegment valueForKey:@"segmentID"];
    PFQuery *queryHashtags = [PFQuery queryWithClassName:@"Hashtags"];
    [queryHashtags whereKey:@"segmentID" equalTo:selectedSegmentID];
    [queryHashtags orderByAscending:@"hashtag"];
    [queryHashtags findObjectsInBackgroundWithBlock:^(NSArray *objectsHash, NSError *error) {
        if (!error) {
            
            NSString *hashtag = @"";
            NSMutableArray *hashtagGroupedArray = [[NSMutableArray alloc]init];
            
            for(NSDictionary *hashtagDict in objectsHash){
                //NSLog(@"hashtag:%@",hashtag);
                //NSLog(@"hashtagDict hashtag:%@",[[hashtagDict valueForKey:@"hashtag"] lowercaseString]);

                if([hashtag caseInsensitiveCompare:[hashtagDict valueForKey:@"hashtag"]]){
                    //NSLog(@"different"); //add new item to list
                    hashtag = [hashtagDict valueForKey:@"hashtag"];
                    int frequency = [[hashtagDict valueForKey:@"frequency"]intValue];
                    //NSLog(@"frequency from parse %d",frequency);
                    NSMutableDictionary *hashtagInsertDictionary = [[NSMutableDictionary alloc]init];
                    [hashtagInsertDictionary setValue:hashtag forKey:@"hashtag"];
                    [hashtagInsertDictionary setValue:[NSNumber numberWithInt:frequency] forKey:@"frequency"];
                    [hashtagGroupedArray addObject:hashtagInsertDictionary];
                   
                } else {
                    //NSLog(@"same, increment 1"); //no add, just increment 1
                    
                    int frequency = [[[hashtagGroupedArray lastObject] valueForKey:@"frequency"] intValue] + 1;
                    //NSLog(@"frequency from array value %d",frequency);
                    [[hashtagGroupedArray lastObject] setValue:[NSNumber numberWithInt:frequency] forKey:@"frequency"];
                }
            }
            
            //NSLog(@"hashtagGroupedArray:%@",hashtagGroupedArray);
            NSSortDescriptor *frequncySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"frequency" ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:frequncySortDescriptor, nil];
            NSArray *hashtagSortedArray = [hashtagGroupedArray sortedArrayUsingDescriptors:sortDescriptors];

            dispatch_async(dispatch_get_main_queue(), ^{
                self.hashtagList = (NSMutableArray*)hashtagSortedArray;
                //NSLog(@"reloading data from hashtag func: %@",[self.sentMessagesForSegment firstObject]);
                [self.tableView reloadData];
            });
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    //*****************

}

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
    
    [[self.messageTableViewController.menuList objectAtIndex:[self.originRowIndex intValue]] setValue:self.messageTextView.text  forKey:@"messageText"];
    
    [self.messageTableViewController.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}
    
- (IBAction)toggleIncludeLink:(id)sender {
    if([self.includeLinkToggle isOn]){
        [[self.messageTableViewController.menuList objectAtIndex:[self.originRowIndex intValue]] setValue:@YES forKey:@"isLinkIncluded"];
    }else {
        [[self.messageTableViewController.menuList objectAtIndex:[self.originRowIndex intValue]] setValue:@NO forKey:@"isLinkIncluded"];
        NSLog(@"Link will not be included");
    }
}
- (IBAction)sendToSignIn:(id)sender {
    [self pushToSignIn];
}

- (IBAction)tableSegmentControlClick:(id)sender {
    
    if(self.tableSegmentControl.selectedSegmentIndex == 0){
        self.tableData = (NSMutableArray*)self.sentMessagesForSegment;
    } else {
        self.tableData = (NSMutableArray*)self.hashtagList;
    }
    [self.tableView reloadData];
}


#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessagePanelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    // Configure the cell...
    if (cell == nil){
        NSLog(@"cell was nil");
        cell = [[MessagePanelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    cell.messagePanelViewController = self;
    [cell configureCellWithData:(NSDictionary*)[self.tableData objectAtIndex:indexPath.row]];
    
    [cell layoutIfNeeded];
    return cell;

//    
//    if(self.tableSegmentControl.selectedSegmentIndex == 0){
//        //self.frequencyLabel.hidden = true;
//        
//        NSDictionary *sentMessage = (NSDictionary*)[self.sentMessagesForSegment objectAtIndex:indexPath.row];
//        cell.textLabel.text = [sentMessage valueForKey:@"messageText"];
//        
//        
//    } else {
//        //self.frequencyLabel.hidden = false;
//        NSDictionary *hashtag = (NSDictionary*)[self.hashtagList objectAtIndex:indexPath.row];
//        cell.textLabel.text = [hashtag valueForKey:@"hashtag"];
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[hashtag valueForKey:@"frequency"]];
//
//    }
    

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of time zones in the region for the specified section.
//    if(self.tableSegmentControl.selectedSegmentIndex == 0){
//        return [self.sentMessagesForSegment count];
//    } else {
//        return [self.hashtagList count];
//    }
    return [self.tableData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    MessagePanelTableViewCell *cell = (MessagePanelTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if(self.tableSegmentControl.selectedSegmentIndex == 0){
        self.messageTextView.text = cell.messageTextLabel.text;
    } else {
        [self.messageTextView replaceRange:self.messageTextView.selectedTextRange withText:cell.messageTextLabel.text];
    }
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    // The header for the section is the region name -- get this from the region at the section index.
//
//    return [NSString stringWithFormat:@"Touch to insert above \r\n(%@)",[self.selectedMessageDictionary valueForKey:@"messageCategory"]];
//
////    return [NSString stringWithFormat:@"Touch to insert above (%@)",[self.selectedMessageDictionary valueForKey:@"messageCategory"]];
//}



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

@end
