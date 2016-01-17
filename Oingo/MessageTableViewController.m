    //
//  MessageTableViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 5/11/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "MessageTableViewController.h"
#import <Parse/Parse.h>
#import "MessageItem.h"
#import "CongressionalMessageItem.h"
#import "EmailItem.h"
#import "MessageTableViewCell.h"
#import "MessageTableViewMessageCell.h"
#import "MessageTableViewRepresentativeCell.h"
#import "MessageTableViewNoZipCell.h"
#import <QuartzCore/QuartzCore.h>
#import "PFTwitterUtils+NativeTwitter.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "SignUpViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <UIKit/UIKit.h>
#import "MakePhoneCallAPI.h"
#import "EmailComposerViewController.h"
#import "LongFormEmailViewController.h"
#import "ParseAPI.h"
#import "CongressFinderAPI.h"
#import "TwitterAPITweet.h"
#import "FacebookAPIPost.h"
#import "LocationFinderAPI.h"
#import "MessageOptionsTableTableViewController.h"
#import "SignUpViewController.h"
#import "SettingsTableViewController.h"
#import "ComposeViewController.h"
#import "MessageTableViewEmailCell.h"
#import "WebViewController.h"
#import "MessagePanelViewController.h"
#import "SegmentDataViewController.h"
#import "ActionDashboardTableViewController.h"


@interface MessageTableViewController () <UIGestureRecognizerDelegate,CLLocationManagerDelegate>

@property(nonatomic) CLLocationManager *locationManager;
@property(nonatomic) UILabel *longitudeLabel;
@property(nonatomic) UILabel *latitudeLabel;
@end

@implementation MessageTableViewController

MessageItem *messageItem;
CongressionalMessageItem *congressionalMessageItem;
EmailItem *emailItem;

NSInteger section;
NSInteger sectionHeaderHeight = 18;
NSInteger headerHeight = 48;
NSInteger footerHeight = 1;




- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    
    // Allows for auto resizing of row height
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // TextView start at the top (NOT WORKING!!)
    //self.automaticallyAdjustsScrollViewInsets = false;
    
    NSLog(@"isCongressLoaded:%d",self.isCongressLoaded);

    //hidding success icons
    self.segmentTweetButtonSuccessImageView.hidden = YES;
    self.segmentFacebookButtonSuccessImageView.hidden = YES;
    
    // Format table header
    self.tableHeaderView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.tableHeaderView.layer.borderWidth = .5;
    self.tableHeaderView.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    self.tableHeaderView.layer.cornerRadius = 3;
    self.tableHeaderView.clipsToBounds = YES;
    
    // Assign header values
    NSString* padding = @"  "; // # of spaces
    self.tableHeaderLabel.text = [NSString stringWithFormat:@"%@%@%@", padding,[self.selectedSegment valueForKey:@"segmentTitle"], padding];
    self.tableHeaderSubLabel.text = [NSString stringWithFormat:@"%@%@%@", padding,[self.selectedProgram valueForKey:@"programTitle"], padding];

    // Create gesture recognizer
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture:)]; //connect recognizer to action method.
    tapRecognizer.delegate = self;
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [tapRecognizer setCancelsTouchesInView:NO];
    [self.tableView addGestureRecognizer:tapRecognizer];

    // 1)Get data from parse or, 2)load data already waiting (with Congress)
    ParseAPI *parseAPI = [[ParseAPI alloc]init];
    parseAPI.messageTableViewController = self;
    parseAPI.isCongressLoaded = self.isCongressLoaded;
    
    if(!self.isCongressLoaded){
    // Get menu data from parse
        [parseAPI getParseMessageData:self.selectedSegment];

        
    } else {
    //  Load menu data from existing list with Congress (loaded from CongressFinderAPI)
        [parseAPI prepSections:self.messageListWithCongress];
        self.isCongressLoaded = NO;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    self.segmentedControl.selectedSegmentIndex = 0;
    [super viewWillAppear:animated];
    NSLog(@"viewWillApper");
    
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.tableView setNeedsDisplay];
//    [self.tableView setNeedsLayout];
//    [self.view layoutSubviews];
//    [self.tableView layoutSubviews];
    [self.tableView reloadData];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear");
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    UITableView *tableView = (UITableView *)gestureRecognizer.view;
    CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view];
    if ([tableView indexPathForRowAtPoint:p]) {
        return YES;
    }
    return NO;
}

- (void)respondToTapGesture:(UITapGestureRecognizer *)tap {
    //*******
    //This is what we use for user touches in the cells
    //It grabs point coordinate of touch as finger lifted
    //******************

    if (UIGestureRecognizerStateEnded == tap.state) {
        
        // Collect data about tap location
        UITableView *tableView = (UITableView *)tap.view;
        CGPoint p = [tap locationInView:tap.view];
        NSIndexPath* indexPath = [tableView indexPathForRowAtPoint:p];
        

        // Deselect the row
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        // Gathering info about cell touched
        UITableViewCell *cellScout = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        CGPoint pointInCell = [tap locationInView:cellScout];
        NSString *category= [self categoryForSection:indexPath.section];
        NSArray *rowIndecesInSection = [self.sections objectForKey:category];
        NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row];
        
        // Create dictionary = selected menu object (could be message or contact)
        NSDictionary *dictionary = [self.menuList objectAtIndex:[rowIndex intValue]];
        self.selectedContact = dictionary;
        
        
        // Message Cell Touch ----------
        if ([cellScout isKindOfClass:[MessageTableViewMessageCell class]]) {
            NSLog(@"yes it is a message class cell"); // Segue triggered to message options
        
            
        // NoZip Cell Touch ----------
        } else if ([cellScout isKindOfClass:[MessageTableViewNoZipCell class]]){
            NSLog(@"yes it is a NO ZIP class cell");
            MessageTableViewNoZipCell *cell = (MessageTableViewNoZipCell *)[tableView cellForRowAtIndexPath:indexPath];
            
            if(CGRectContainsPoint(cell.zipCodeButton.frame, pointInCell)) {
                NSLog(@"touch in zipCodeButton area");
                if(!cell.zipCodeButton.hidden){
                    [self lookUpZip];
                }
                
            } else if (CGRectContainsPoint(cell.locationButton.frame, pointInCell)) {
                NSLog(@"touch in getUserLocation area");
                if(!cell.locationButton.hidden){
                    [self getUserLocationAlert];
                }
            } else {
                NSLog(@"touch in outer area");
            }
            
            
        // Long Form Email Cell Touch ----------
        } else if ([cellScout isKindOfClass:[MessageTableViewEmailCell class]]){
            NSLog(@"Email class cell");
            MessageTableViewEmailCell *cell = (MessageTableViewEmailCell *)[tableView cellForRowAtIndexPath:indexPath];
            
            
            __block NSUInteger countFirstName = 0;
            [cell.firstName.text enumerateSubstringsInRange:NSMakeRange(0, [cell.firstName.text length])
                                        options:NSStringEnumerationByComposedCharacterSequences
                                     usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                         countFirstName++;
                                     }];
            
            __block NSUInteger countLastName = 0;
            [cell.lastName.text enumerateSubstringsInRange:NSMakeRange(0, [cell.lastName.text length])
                                                    options:NSStringEnumerationByComposedCharacterSequences
                                                 usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                     countLastName++;
                                                 }];

            
            
            if (CGRectContainsPoint(cell.emailRecipientsButton.frame, pointInCell)) {
                
                PFUser *currentUser = [PFUser currentUser];
                if(!currentUser) {
                    [self pushToSignIn];
                    
                } else if (countFirstName == 0 || countLastName == 0) {

                    [self showCheckFullNameWarning];
                    
                } else {
                    LongFormEmailViewController *emailComposer = [[LongFormEmailViewController alloc] init];
                    emailComposer.selectedSegment = self.selectedSegment;
                    emailComposer.emailSubject = cell.emailSubjectTextView.text;
                    emailComposer.emailBody = cell.messageTextView.text;
                    emailComposer.emailRecipients = cell.emailRecipientsTextView.text;
                    emailComposer.firstName = cell.firstName.text;
                    emailComposer.lastName = cell.lastName.text;
                    emailComposer.messageTableViewController = self;
                    [self.navigationController pushViewController:emailComposer animated:YES];
                    [emailComposer showMailPicker];
                }

            } else if (CGRectContainsPoint(cell.linkToEmailButton.frame, pointInCell)) {
                
                PFUser *currentUser = [PFUser currentUser];
                if(!currentUser) {
                    [self pushToSignIn];
                } else {
                    self.linkToEmail = cell.linkToEmail;
                    [self performSegueWithIdentifier:@"showWebViewControllerEmail" sender:self];
                }
            }


        // Local Rep Touch
        } else if ([cellScout isKindOfClass:[MessageTableViewRepresentativeCell class]]){
            MessageTableViewRepresentativeCell *cell = (MessageTableViewRepresentativeCell *)[tableView cellForRowAtIndexPath:indexPath];

            
            if (CGRectContainsPoint(cell.tweetTouchCaptureImageView.frame, pointInCell)) {
                NSLog(@"touch in tweet button area");
                if(!cell.tweetButton.hidden){
                    // Create Tweet API object, Properties passed: -menuList -selection info
                    TwitterAPITweet *twitterAPITweet = [[TwitterAPITweet alloc]init];
                    twitterAPITweet.messageTableViewController = self;
                    twitterAPITweet.selectedSegment = self.selectedSegment;
                    twitterAPITweet.selectedProgram = self.selectedProgram;
                    twitterAPITweet.menuList = self.menuList;
                    twitterAPITweet.selectedContact = self.selectedContact;
                    twitterAPITweet.messageOptionsList = self.messageOptionsList;

                    
                    //Look up message - note this works b/c message is first item in section.
                    NSUInteger index = [self.menuList indexOfObjectPassingTest:
                                        ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                            return [[dict valueForKey:@"messageCategory"] isEqualToString:category];
                                        }];
                    if(index == NSNotFound){
                        NSLog(@"did not find line");
                        
                    } else {
                        NSLog(@"index was found:%ld",(unsigned long)index);
                        twitterAPITweet.messageText = [[self.menuList objectAtIndex:index] valueForKey:@"messageText"];
                    }
                    twitterAPITweet.selectedMessageDictionary = [self.menuList objectAtIndex:index];
                    [twitterAPITweet shareMessageTwitterAPI:cell];
                }
            } else if(CGRectContainsPoint(cell.postToFacebookButton.frame, pointInCell)) {
                NSLog(@"touch in facebook button area");
                if(!cell.postToFacebookButton.hidden){
                    [self postToFacebook:cell];
                }
            } else if (CGRectContainsPoint(cell.phoneTouchCaptureImageView.frame, pointInCell)) {
                
                NSLog(@"touch in phone area");
                if(!cell.phoneButton.hidden){
                    
                    PFUser *currentUser = [PFUser currentUser];
                    if(!currentUser) {
                        [self pushToSignIn];
                    } else {
                        [self showPhoneCallAlert:cell.phone];
                    }
                    
                }
            } else if (CGRectContainsPoint(cell.emailTouchCaptureImageView.frame, pointInCell)) {
                NSLog(@"touch in email button area");
                if(!cell.emailButton.hidden){
                    
                    PFUser *currentUser = [PFUser currentUser];
                    if(!currentUser) {
                        [self pushToSignIn];
                    } else {
                        
                        //Look up message - note this works b/c message is first item in section.
                        NSUInteger index = [self.menuList indexOfObjectPassingTest:
                                            ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                                return [[dict valueForKey:@"messageCategory"] isEqualToString:category];
                                            }];
                        if(index == NSNotFound){
                            NSLog(@"did not find line");
                            
                        } else {
                            NSLog(@"index was found:%ld",(unsigned long)index);
                            
                            EmailComposerViewController *emailComposer = [[EmailComposerViewController alloc] init];
                            emailComposer.selectedSegment = self.selectedSegment;
                            emailComposer.selectedContact = self.selectedContact;
                            emailComposer.messageTableViewController = self;
                            emailComposer.selectedMessageDictionary = [self.menuList objectAtIndex:index];
                            
                            [self.navigationController pushViewController:emailComposer animated:YES];
                            [emailComposer showMailPicker:cell.openCongressEmail withMessage:[[self.menuList objectAtIndex:index] valueForKey:@"messageText"]];
                        }
                    }
                }
            } else if (CGRectContainsPoint(cell.webFormTouchCaptureImageView.frame, pointInCell)){
                NSLog(@"touch in webForm area");
                if(!cell.webFormButton.hidden){
                    PFUser *currentUser = [PFUser currentUser];
                    if(!currentUser) {
                        [self pushToSignIn];
                    } else {
                        NSString *url = cell.contactForm;
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                    }
                }
            } else if (CGRectContainsPoint(cell.messageImage.frame, pointInCell)) {
                NSLog(@"touch in image area");
                if(!cell.messageImage.hidden){
                }
            } else {
                NSLog(@"touch in outer area");
            }
            
            
            
        // Civilian/Rep Cell Touch ----------
        } else {
            MessageTableViewCell *cell = (MessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            
            if (CGRectContainsPoint(cell.tweetTouchCaptureImageView.frame, pointInCell)) {
            NSLog(@"touch in tweet button area");
                if(!cell.tweetButton.hidden){
                    // Create Tweet API object, Properties passed: -menuList -selection info
                    TwitterAPITweet *twitterAPITweet = [[TwitterAPITweet alloc]init];
                    twitterAPITweet.messageTableViewController = self;
                    twitterAPITweet.selectedSegment = self.selectedSegment;
                    twitterAPITweet.selectedProgram = self.selectedProgram;
                    twitterAPITweet.menuList = self.menuList;
                    twitterAPITweet.selectedContact = self.selectedContact;
                    twitterAPITweet.messageOptionsList = self.messageOptionsList;
                    
                    //Look up message - note this works b/c message is first item in section.
                    NSUInteger index = [self.menuList indexOfObjectPassingTest:
                                        ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                            return [[dict valueForKey:@"messageCategory"] isEqualToString:category];
                                        }];
                    if(index == NSNotFound){
                        NSLog(@"did not find line");
                        
                    } else {
                        NSLog(@"index was found:%ld",(unsigned long)index);
                        twitterAPITweet.messageText = [[self.menuList objectAtIndex:index] valueForKey:@"messageText"];
                    }
                    twitterAPITweet.selectedMessageDictionary = [self.menuList objectAtIndex:index];
                    [twitterAPITweet shareMessageTwitterAPI:cell];
                }
            } else if(CGRectContainsPoint(cell.postToFacebookButton.frame, pointInCell)) {
            NSLog(@"touch in facebook button area");
                if(!cell.postToFacebookButton.hidden){
                    [self postToFacebook:cell];
                }
            } else if (CGRectContainsPoint(cell.phoneTouchCaptureImageView.frame, pointInCell)) {
                
                NSLog(@"touch in phone area");
                if(!cell.phoneButton.hidden){

                    PFUser *currentUser = [PFUser currentUser];
                    if(!currentUser) {
                        [self pushToSignIn];
                    } else {
                        [self showPhoneCallAlert:cell.phone];
                    }
                
                }
            } else if (CGRectContainsPoint(cell.emailTouchCaptureImageView.frame, pointInCell)) {
                NSLog(@"touch in email button area");
                if(!cell.emailButton.hidden){
                    
                    PFUser *currentUser = [PFUser currentUser];
                    if(!currentUser) {
                        [self pushToSignIn];
                    } else {
                        
                        //Look up message - note this works b/c message is first item in section.
                        NSUInteger index = [self.menuList indexOfObjectPassingTest:
                                            ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                                return [[dict valueForKey:@"messageCategory"] isEqualToString:category];
                                            }];
                        if(index == NSNotFound){
                            NSLog(@"did not find line");
                            
                        } else {
                            NSLog(@"index was found:%ld",(unsigned long)index);
                            
                            EmailComposerViewController *emailComposer = [[EmailComposerViewController alloc]init];
                            emailComposer.selectedSegment = self.selectedSegment;
                            emailComposer.selectedContact = self.selectedContact;
                            emailComposer.messageTableViewController = self;
                            emailComposer.selectedMessageDictionary = [self.menuList objectAtIndex:index];
                            
                            [self.navigationController pushViewController:emailComposer animated:YES];
                            [emailComposer showMailPicker:cell.email withMessage:[[self.menuList objectAtIndex:index] valueForKey:@"messageText"]];
                        }
                    }
                }
            } else if (CGRectContainsPoint(cell.webFormTouchCaptureImageView.frame, pointInCell)){
                NSLog(@"touch in webForm area");
                if(!cell.webFormButton.hidden){
                    PFUser *currentUser = [PFUser currentUser];
                    if(!currentUser) {
                        [self pushToSignIn];
                    } else {
                        NSString *url = cell.contactForm;
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                    }
                }
            } else if (CGRectContainsPoint(cell.messageImage.frame, pointInCell)) {
                NSLog(@"touch in image area");
                if(!cell.messageImage.hidden){
                }
            } else {
                NSLog(@"touch in outer area");
            }
        }
    }
}

-(void) pushToSignIn {
    SignUpViewController *signUpViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"signInViewController"];
    signUpViewController.messageTableViewController = self;
    [self.navigationController pushViewController:signUpViewController animated:YES];

}

- (IBAction)viewSettings:(id)sender {
    NSLog(@"currentUser:%@",[PFUser currentUser]);
    if(![PFUser currentUser]){
        [self pushToSignIn];
    }else {
        
        [self performSegueWithIdentifier:@"showSettings" sender:nil];

    }
}

- (IBAction)shareSegmentTwitter:(id)sender {
    TwitterAPITweet *twitterAPITweet = [[TwitterAPITweet alloc]init];
    twitterAPITweet.messageTableViewController = self;
    twitterAPITweet.selectedSegment = self.selectedSegment;
    twitterAPITweet.selectedProgram = self.selectedProgram;
    NSLog(@"sharing segment on twitter, here is view controller%@",self);
    [twitterAPITweet shareSegmentTwitterAPI];
}

- (IBAction)shareSegmentFacebook:(id)sender {
    FacebookAPIPost *facebookAPIPost = [[FacebookAPIPost alloc]init];
    facebookAPIPost.messageTableViewController = self;
        NSLog(@"sharing segment on fb, here is view controller%@",self);
    NSLog(@" on message tableview before share facebook segment:%@",facebookAPIPost.messageTableViewController);
    facebookAPIPost.selectedSegment = self.selectedSegment;
    facebookAPIPost.selectedProgram = self.selectedProgram;
    [facebookAPIPost shareSegmentFacebookAPI];
}


- (void)postToFacebook:(UITableViewCell *)cell {

    FacebookAPIPost *facebookAPIPost = [[FacebookAPIPost alloc]init];
    facebookAPIPost.messageTableViewController = self;
    facebookAPIPost.selectedSegment = self.selectedSegment;
    facebookAPIPost.selectedProgram = self.selectedProgram;
    [facebookAPIPost shareSegmentFacebookAPI];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Location Manager

-(void) getUserLocationAlert{
    NSString *alertTitle = @"Let's get your Local Representatives!";
    NSString *alertMessage = [NSString stringWithFormat:@"We will access your location one time only to get your district."];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSLog(@"cancel action");
    }];
    [alertController addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self getUserLocation];
          }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

-(void) getUserLocation {

//    LocationFinderAPI *locationFinderAPI = [[LocationFinderAPI alloc]init];
//    locationFinderAPI.messageTableViewController = self;
//    [locationFinderAPI findUserLocation];
    
    if(self.locationManager == nil){
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    
    NSUInteger code = [CLLocationManager authorizationStatus];
    if (code == kCLAuthorizationStatusNotDetermined && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
        // choose one request according to your business.
        if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]){
            [self.locationManager requestWhenInUseAuthorization];
        } else {
            NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
        }
    }
    [self.locationManager startUpdatingLocation];
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}



- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self.locationManager stopUpdatingLocation];
    
    //Set the location default
    UpdateDefaults *updateDefaults = [[UpdateDefaults alloc]init];
    [updateDefaults saveCoordinatesToDefaultsWithLatitude:(double)newLocation.coordinate.latitude andLongitude:(double)newLocation.coordinate.longitude];
    [updateDefaults saveLocationDefaultsToUser];
    
    [self viewDidLoad];

}

-(void)lookUpZip {
    
    NSString *alertTitle = @"Let's get your Local Representatives";
    NSString *alertMessage = [NSString stringWithFormat:@"Enter you Zipcode"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"'98765'", @"Zip");
        textField.keyboardType = UIKeyboardTypeNumberPad;
        [textField becomeFirstResponder];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSLog(@"cancel action");
    }];
    [alertController addAction:cancelAction];
    
    UIAlertAction *lookUpAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Look up", @"Look up") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        //get value entered
        NSString *zipCode = [alertController.textFields.firstObject valueForKey:@"text"];
        __block NSUInteger count = 0;
        [zipCode enumerateSubstringsInRange:NSMakeRange(0, [zipCode length])
                                    options:NSStringEnumerationByComposedCharacterSequences
                                 usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                     count++;
                                 }];
        if(count != 5) {
            [self retryZipCode:zipCode count:count];
        } else {
            //set user default zipCode and save to user
            UpdateDefaults *updateDefaults = [[UpdateDefaults alloc]init];
            [updateDefaults saveZipCodeToDefaultsWithZip:zipCode];
            [updateDefaults saveLocationDefaultsToUser];
            
            [self viewDidLoad];
        }
    }];
    [alertController addAction:lookUpAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSString*)retryZipCode:zipCode count:(NSInteger)count {
    NSString *alertTitle = @"Please give it another try";
    NSString *alertMessage = [NSString stringWithFormat:@"Your Zip Code must be 5 numbers, you entered %ld",(long)count];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"'98765'", @"Zip");
        textField.text = zipCode;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        [textField becomeFirstResponder];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSLog(@"cancel action");
    }];
    [alertController addAction:cancelAction];
    
    UIAlertAction *lookUpAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Look up", @"Look up") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        //get value entered
        NSString *zipCode = [alertController.textFields.firstObject valueForKey:@"text"];
        
        __block NSUInteger count = 0;
        [zipCode enumerateSubstringsInRange:NSMakeRange(0, [zipCode length])
                                    options:NSStringEnumerationByComposedCharacterSequences
                                 usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                     count++;
        }];
        
        if(count != 5) {
            [self retryZipCode:zipCode count:count];
        } else {
            //set user default zipCode and save to user
            UpdateDefaults *updateDefaults = [[UpdateDefaults alloc]init];
            [updateDefaults saveZipCodeToDefaultsWithZip:zipCode];
            [updateDefaults saveLocationDefaultsToUser];

            [self viewDidLoad];
        }
    }];
    [alertController addAction:lookUpAction];
    [self presentViewController:alertController animated:YES completion:nil];
    return zipCode;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    NSString *category= [self categoryForSection:indexPath.section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:category];
    NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row]; //pulling the row indece from array above

    // Get dictionary from current index on list.
    NSDictionary *dictionary = [self.menuList objectAtIndex:[rowIndex intValue]];
    
    // Get the isMesssage bool
    NSNumber *isMessageNumber = [dictionary valueForKey:@"isMessage"];
    bool isMessageBool = [isMessageNumber boolValue];

    // Get the isGetLocation bool
    NSNumber *isGetLocationNumber = [dictionary valueForKey:@"isGetLocationCell"];
    bool isGetLocationBool = [isGetLocationNumber boolValue];

    // Decide which type of cell to load
    
    if(isMessageBool){
        MessageTableViewMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellCategoryMessage" forIndexPath:indexPath];
        // Remove noZip controls
        if (cell == nil){
            NSLog(@"cell was nil");
            cell = [[MessageTableViewMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellCategoryMessage"];
        }
        
        NSLog(@"loading message cell");
        cell.layer.cornerRadius = 3;
        [self.tableView addSubview:cell];
        messageItem = [self.menuList objectAtIndex:[rowIndex intValue]];
        [cell configMessageCell:messageItem indexPath:indexPath];
        
        [cell.contentView layoutIfNeeded];
        [cell setNeedsDisplay];
        [cell layoutIfNeeded];
        return cell;
        
    } else if (isGetLocationBool) {
        //user has no zip or location
        NSLog(@"loading no location cell");
        MessageTableViewNoZipCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellCategoryNoZip" forIndexPath:indexPath];
        if (cell == nil){
            NSLog(@"cell was nil");
            cell = [[MessageTableViewNoZipCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellCategoryNoZip"];
        }
        
        cell.layer.cornerRadius = 3;
        [self.tableView addSubview:cell];
        [cell configMessageCellNoZip:indexPath];
        
//        [cell.contentView layoutIfNeeded];
//        [cell setNeedsDisplay];
//        [cell layoutIfNeeded];
        return cell;
        
    } else if([category isEqualToString:@"Long Form Email"]) {
        MessageTableViewEmailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellEmail" forIndexPath:indexPath];
        NSLog(@"loading email cell");
        if (cell == nil){
            NSLog(@"cell was nil");
            cell = [[MessageTableViewEmailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellEmail"];
        }
        
        cell.layer.cornerRadius = 3;
        [self.tableView addSubview:cell];
        emailItem = [self.menuList objectAtIndex:[rowIndex intValue]];
        cell.menuList = self.menuList;
        [cell configEmailCell:emailItem indexPath:indexPath];

        //        [cell.contentView layoutIfNeeded];
        //        [cell  setNeedsDisplay];
        //        [cell layoutIfNeeded];
        return cell;

        
    } else if([category isEqualToString:@"Local Representative"]) {
        MessageTableViewRepresentativeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellRep" forIndexPath:indexPath];
        NSLog(@"loading local rep cell");
        if (cell == nil){
            NSLog(@"cell was nil");
            cell = [[MessageTableViewRepresentativeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellRep"];
        }
        
        cell.layer.cornerRadius = 3;
        [self.tableView addSubview:cell];
        congressionalMessageItem = [self.menuList objectAtIndex:[rowIndex intValue]];
        [cell configMessageCellLocalRep:congressionalMessageItem indexPath:indexPath];
        
//        [cell.contentView layoutIfNeeded];
//        [cell setNeedsDisplay];
//        [cell layoutIfNeeded];
        return cell;
        
    } else {
        MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        NSLog(@"loading civilian");
        if (cell == nil){
            NSLog(@"cell was nil");
            cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        }
        cell.layer.cornerRadius = 3;
        [self.tableView addSubview:cell];
        messageItem = [self.menuList objectAtIndex:[rowIndex intValue]];
        [cell configMessageContactCell:messageItem indexPath:indexPath];
        
//        [cell.contentView layoutIfNeeded];
//        [cell setNeedsDisplay];
//        [cell layoutIfNeeded];
//        [cell layoutSubviews];
        return cell;
    }
}


//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *category= [self categoryForSection:indexPath.section];
//    NSArray *rowIndecesInSection = [self.sections objectForKey:category];
//    NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row]; //pulling the row indece from array above
//    
//    // Get bool value from current index on list.
//    NSDictionary *dictionary = [self.menuList objectAtIndex:[rowIndex intValue]];
//    NSNumber *isMessageNumber = [dictionary valueForKey:@"isMessage"];
//    bool isMessageBool = [isMessageNumber boolValue];
//    
//    NSNumber *isGetLocationNumber = [dictionary valueForKey:@"isGetLocationCell"];
//    bool isGetLocationBool = [isGetLocationNumber boolValue];
//    
//    NSNumber *isCollapsedNumber = [dictionary valueForKey:@"isCollapsed"];
//    bool isCollapsedBool = [isCollapsedNumber boolValue];
//
//    if(isMessageBool) {
//        NSString *messageText = [dictionary valueForKey:@"messageText"];
//        double charCount = messageText.length;
//        
//        int rowHeight = 50;
//            if (charCount < 50){
//                rowHeight = 25;
//
//            } else if (charCount < 100) {
//                rowHeight = 35;
//
//            } else {
//
//                rowHeight = 50;
//            }
//        return rowHeight;
//    } else if(isGetLocationBool) {
//        return 55;
//    } else if(isCollapsedBool) {
//        return .0001;
//    } else if([category isEqualToString:@"Local Representative"]) {
//        return 65;
//    } else { // normal contact cell
//        return 65;
//    }
//}





#pragma mark - Sections
- (NSString *) categoryForSection:(NSInteger)section { //takes section # and returns name of section.
    return [self.sectionToCategoryMap objectForKey:[NSNumber numberWithInt:(int)section]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (unsigned long)self.sections.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *category = [self categoryForSection:section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:category];
    return [rowIndecesInSection count];
}

#pragma mark - Header and Footers

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    NSString *category= [self categoryForSection:section];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if([category isEqualToString:@"Local Representative"] && ![defaults valueForKey:@"zipCode"] && ![defaults valueForKey:@"latitude"]) {
//        return sectionHeaderHeight;
//    } else if([category isEqualToString:@"Local Representative"]) {
//        return localRepSectionHeaderHeight + 3;
//    } else {
        return sectionHeaderHeight;
//    }
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(7, 0, tableView.frame.size.width -14 , sectionHeaderHeight)];
        UILabel *sectionLabel = [[UILabel alloc] init];
        sectionLabel.frame = CGRectMake(7, 0, tableView.frame.size.width -14, sectionHeaderHeight);
        sectionLabel.backgroundColor = [UIColor colorWithRed:.96 green:.96 blue:.96 alpha:1];
        sectionLabel.layer.borderWidth = .5;
        sectionLabel.layer.borderColor = [[UIColor blackColor] CGColor];
        sectionLabel.font = [UIFont systemFontOfSize:14];
        sectionLabel.textColor = [UIColor blackColor];
        sectionLabel.layer.cornerRadius = 3;
        sectionLabel.clipsToBounds = YES;
        NSString* padding = @"  "; // # of spaces
        sectionLabel.text = [NSString stringWithFormat:@"%@Contact -> %@%@", padding, [self categoryForSection:section], padding];
        [view addSubview:sectionLabel];
        return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    //return footerHeight;
    return 2;
}

//-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(9, 0, tableView.frame.size.width -14 , 13)];
//    view.layer.backgroundColor = [[UIColor clearColor] CGColor];
//    
//    
//    UIImageView *footerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(110, 0, 30,25)];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(150, 0, 75,16)];
//    label.text = @"show more";
//    label.font = [UIFont boldSystemFontOfSize:11];
//    label.textColor = [UIColor grayColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.layer.backgroundColor = [[UIColor whiteColor] CGColor];
//    label.layer.cornerRadius = 3;
////    footerImageView.image = [UIImage imageNamed:@"arrow-down-gray-hi.png"];
////    footerImageView.layer.borderColor = [[UIColor blackColor] CGColor];
////    footerImageView.layer.borderWidth = 1;
////    footerImageView.layer.backgroundColor =[[UIColor whiteColor] CGColor];
//    footerImageView.layer.cornerRadius = 3;
//    footerImageView.clipsToBounds = YES;
//    [view addSubview:label];
//    [view addSubview:footerImageView];
//    return view;
//}



/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Check Full Name for Email Alert
- (void) showCheckFullNameWarning {
    NSString *alertTitle = @"Please enter your name";
    NSString *alertMessage = [NSString stringWithFormat:@"Please enter both a first and last name."];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
    
    }];
    
    [alertController addAction:OKAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Phone Call API
-(void)showPhoneCallAlert:(NSString*)phoneString{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel://%@",phoneString]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        
        NSString *alertTitle = @"Phone Call";
        NSString *alertMessage = @"Remember to state your name and your sentiment.  Would you like to call?";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
        
        //Add cancel button
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSLog(@"Cancel action");
        }];
        [alertController addAction:cancelAction];
        
        //Add OK action button
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            [[UIApplication sharedApplication] openURL:phoneUrl];
            [self savePhoneCall:phoneUrl];
            
            NSLog(@"OK action");
            
        }];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else{
        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [calert show];
    }
    
    //    MakePhoneCallAPI *makePhoneCallAPI = [[MakePhoneCallAPI alloc] init];
    //    makePhoneCallAPI.selectedProgram = self.selectedProgram;
    //    makePhoneCallAPI.selectedSegment = self.selectedSegment;
    //    makePhoneCallAPI.selectedContact = self.selectedContact;
    //    [makePhoneCallAPI dialPhoneNumber:(NSURL*)phoneUrl];
    
}
-(void)savePhoneCall:(NSURL*)phoneURL{
    //  SAVING MESSAGE DATA TO PARSE
    PFUser *currentUser = [PFUser currentUser];
    
    PFObject *sentMessageItem = [PFObject objectWithClassName:@"sentMessages"];
    [sentMessageItem setObject:@"phoneCall" forKey:@"messageType"];
    [sentMessageItem setObject:[phoneURL absoluteString] forKey:@"phoneNumber"];
    [sentMessageItem setObject:[self.selectedSegment valueForKey:@"segmentID"] forKey:@"segmentID"];
    [sentMessageItem setObject:[currentUser valueForKey:@"username"] forKey:@"username"];
    NSString *userObjectID = currentUser.objectId;
    [sentMessageItem setObject:userObjectID forKey:@"userObjectID"];
    
    //if segment then skip, else don't
    if ([self.selectedContact isKindOfClass:[CongressionalMessageItem class]]) {
        NSLog(@"Saving congressional Message Item Class");
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
    
    [sentMessageItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //save sent message to parse
        if(error){
            NSLog(@"error, message not saved");
        }
        else {
            NSLog(@"no error, message saved");
            [self viewDidLoad];
        }
    }];
}

- (IBAction)segmentedControlChange:(id)sender {
    if(self.segmentedControl.selectedSegmentIndex == 0){
    } else {
        [self performSegueWithIdentifier:@"showSegmentData" sender:self];
        
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showMessageOptions"]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSString *category= [self categoryForSection:indexPath.section];
        NSArray *rowIndecesInSection = [self.sections objectForKey:category];
        NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row]; //pulling the row indece from array above
       
        MessageOptionsTableTableViewController *messageOptionsViewController = [segue destinationViewController];
        
        messageOptionsViewController.category = category;
        messageOptionsViewController.messageTableViewController = self;
        messageOptionsViewController.originIndexPath = indexPath;
        messageOptionsViewController.originRowIndex = rowIndex;
        messageOptionsViewController.messageOptionsList = self.messageOptionsList;
        messageOptionsViewController.menuList = self.menuList;
        
        
    } else if ([segue.identifier isEqualToString:@"showSettings"]){
        SettingsTableViewController *settingsTableVC = [segue destinationViewController];
        settingsTableVC.messageTableViewController = self;
        
    } else if ([segue.identifier isEqualToString:@"showCompose"]){
        ComposeViewController *composeViewController = [segue destinationViewController];
        composeViewController.messageTableViewController = self;
        composeViewController.selectedSegment = self.selectedSegment;
        composeViewController.selectedProgram = self.selectedProgram;
        composeViewController.facebookAPIPost = (FacebookAPIPost*)sender;
        NSLog(@"sender:%@",sender);
    } else if ([segue.identifier isEqualToString:@"showWebViewControllerEmail"]){
        WebViewController *webViewController =  [segue destinationViewController];
        webViewController.selectedLink = self.linkToEmail;
        NSLog(@"selected link program detail %@:",webViewController.selectedLink);
    } else if ([segue.identifier isEqualToString:@"showMessagePanel"]){
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSString *category= [self categoryForSection:indexPath.section];
        NSArray *rowIndecesInSection = [self.sections objectForKey:category];
        NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row]; //pulling the row indece from array above
        
        MessagePanelViewController *messagePanel =  [segue destinationViewController];
        
        messagePanel.selectedProgram = self.selectedProgram;
        messagePanel.selectedSegment = self.selectedSegment;
        messagePanel.messageOptionsList = self.messageOptionsList;
        messagePanel.category = category;
        messagePanel.messageTableViewController = self;
        messagePanel.originIndexPath = indexPath;
        messagePanel.originRowIndex = rowIndex;
        messagePanel.menuList = self.menuList;
        messagePanel.messageOptionsList = self.messageOptionsList;
        //NSLog(@"menuList:%@",self.menuList);
        
        //Look up message - note this works b/c message is first item in section.
        NSUInteger index = [self.menuList indexOfObjectPassingTest:
                            ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                return [[dict valueForKey:@"messageCategory"] isEqualToString:category];
                            }];
        if(index == NSNotFound){
            NSLog(@"did not find line");
        } else if ([segue.identifier isEqualToString:@"showSegmentData"]){
            SegmentDataViewController *segmentDataViewController = [segue destinationViewController];
            segmentDataViewController.messageTableViewController = self;
        } else {
            messagePanel.selectedMessageDictionary = [self.menuList objectAtIndex:index];
        }
    }
}


@end
