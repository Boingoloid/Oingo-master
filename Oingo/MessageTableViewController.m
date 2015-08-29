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
#import "MessageTableViewCell.h"
#import "MessageTableViewMessageCell.h"
#import "MessageTableViewRepresentativeCell.h"
#import "MessageTableViewNoZipCell.h"
#import <QuartzCore/QuartzCore.h>
#import "PFTwitterUtils+NativeTwitter.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <TwitterKit/TwitterKit.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "SignUpViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <UIKit/UIKit.h>
#import "MakePhoneCallAPI.h"
#import "EmailComposerViewController.h"
#import "ParseAPI.h"
#import "CongressFinderAPI.h"
#import "TwitterAPITweet.h"
#import "FacebookAPIPost.h"
#import "LocationFinderAPI.h"
#import "MessageOptionsTableTableViewController.h"
#import "SignUpViewController.h"


@interface MessageTableViewController () <UIGestureRecognizerDelegate,CLLocationManagerDelegate>

@property(nonatomic) CLLocationManager *locationManager;
@property(nonatomic) UILabel *longitudeLabel;
@property(nonatomic) UILabel *latitudeLabel;
@end

@implementation MessageTableViewController

MessageItem *messageItem;
CongressionalMessageItem *congressionalMessageItem;


NSInteger section;
NSInteger sectionHeaderHeight = 16;
NSInteger headerHeight = 48;
NSInteger footerHeight = 1;

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillApper");
}



- (void)viewDidLoad {
    [super viewDidLoad];
        NSLog(@"viewDidLoad");
    
//    self.updateDefaults = [[UpdateDefaults alloc]init];
    [self.updateDefaults updateLocationDefaults]; // Checks if current user has location info, is so set defaults.

    //hidding tweet success
    self.segmentTweetButtonSuccessImageView.hidden = YES;
    self.segmentFacebookButtonSuccessImageView.hidden = YES;
    
    // Get menu data from parse
    ParseAPI *parseAPI = [[ParseAPI alloc]init];
    parseAPI.messageTableViewController = self;
    [parseAPI getParseMessageData:self.selectedSegment];
    
    // Format table header
    self.tableHeaderView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.tableHeaderView.layer.borderWidth = .5;
    self.tableHeaderView.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    self.tableHeaderView.layer.cornerRadius = 3;
    self.tableHeaderView.clipsToBounds = YES;
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
    
    // Create logout button
    UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(logout)];
     [[NSUserDefaults standardUserDefaults] synchronize];
    self.navigationItem.rightBarButtonItem = logOutButton;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    UITableView *tableView = (UITableView *)gestureRecognizer.view;
    CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view];
//    NSIndexPath* indexPath = [tableView indexPathForRowAtPoint:p];
//    MessageTableViewCell *cell = (MessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    //if point is in the tableview then return YES
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
        MessageTableViewCell *cell = (MessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        CGPoint pointInCell = [tap locationInView:cell];
        NSString *category= [self categoryForSection:indexPath.section];
        NSArray *rowIndecesInSection = [self.sections objectForKey:category];
        NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row]; //pulling the row indece from array above
        
        // Deselect the row
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
 
        // Create dictionary = selected menu object (could be message or contact)
        NSDictionary *dictionary = [self.menuList objectAtIndex:[rowIndex intValue]];
        self.selectedContact = dictionary;
       
        //Get the isMessage Bool from Parse backend
        NSNumber *isMessageNumber = [dictionary valueForKey:@"isMessage"];
        bool isMessageBool = [isMessageNumber boolValue];
        
        if(isMessageBool){
            NSLog(@"touch in message cell");
            // triggers segue to message options
        } else if (CGRectContainsPoint(cell.tweetButton.frame, pointInCell)) {
            NSLog(@"touch in tweet button area");
            if(!cell.tweetButton.hidden){
                // Create Tweet API object, Properties passed: -menuList -selection info
                TwitterAPITweet *twitterAPITweet = [[TwitterAPITweet alloc]init];
                twitterAPITweet.messageTableViewController = self;
                twitterAPITweet.selectedSegment = self.selectedSegment;
                twitterAPITweet.selectedProgram = self.selectedProgram;
                twitterAPITweet.menuList = self.menuList;
                twitterAPITweet.selectedContact = self.selectedContact;
                
                //Look up message - note this works b/c message is first item in section.
                NSUInteger index = [self.menuList indexOfObjectPassingTest:
                                    ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                        return [[dict valueForKey:@"messageCategory"] isEqualToString:category];
                                    }];
                if(index == NSNotFound){
                    NSLog(@"did not find line");
                    
                } else {
                    NSLog(@"index was found:%ld",index);
                    twitterAPITweet.messageText = [[self.menuList objectAtIndex:index] valueForKey:@"messageText"];
                }
                
                [twitterAPITweet shareMessageTwitterAPI:cell];
            }
        //if touch on postToFacebookButton, then
        } else if(CGRectContainsPoint(cell.postToFacebookButton.frame, pointInCell)) {
            NSLog(@"touch in facebook button area");
            if(!cell.postToFacebookButton.hidden){
                [self postToFacebook:cell];
            }
        } else if(CGRectContainsPoint(cell.zipCodeButton.frame, pointInCell)) {
            NSLog(@"touch in zipCodeButton area");
            if(!cell.zipCodeButton.hidden){
                [self lookUpZip];
            }
        } else if (CGRectContainsPoint(cell.locationButton.frame, pointInCell)) {
            NSLog(@"touch in getUserLocation area");
            if(!cell.locationButton.hidden){
                [self getUserLocation];
            }
        } else if (CGRectContainsPoint(cell.phoneButton.frame, pointInCell)) {
            NSLog(@"touch in phone area");
            if(!cell.phoneButton.hidden){
                NSString *phoneNumber =[[cell.phone componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"6177940337"] invertedSet]] componentsJoinedByString:@""];
                MakePhoneCallAPI *makePhoneCallAPI = [[MakePhoneCallAPI alloc] init];
                [makePhoneCallAPI dialPhoneNumber:phoneNumber];
            }
        } else if (CGRectContainsPoint(cell.emailButton.frame, pointInCell)) {
            NSLog(@"touch in email button area");
            if(!cell.emailButton.hidden){
                
                // Check if current user, otherwise send to login
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
                        NSLog(@"index was found:%ld",index);
                        
                        EmailComposerViewController *emailComposer = [[EmailComposerViewController alloc] init];
                        emailComposer.selectedSegment = self.selectedSegment;
                        emailComposer.selectedContact = self.selectedContact;
                        emailComposer.messageTableViewController = self;
                        
                        [emailComposer showMailPicker:cell.openCongressEmail withMessage:[[self.menuList objectAtIndex:index] valueForKey:@"messageText"]];

                        [self presentViewController:emailComposer animated:YES completion:NULL];
                    }
                }
            }
        } else if (CGRectContainsPoint(cell.webFormButton.frame, pointInCell)) {
            NSLog(@"touch in webForm area");
            if(!cell.webFormButton.hidden){
                NSString *url = cell.contantForm;
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
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

/*
-(void)shareMessageTwitter{
    
}
*/

-(void) pushToSignIn {
    SignUpViewController *signUpViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"signInViewController"];
    signUpViewController.messageTableViewController = self;
    [self.navigationController pushViewController:signUpViewController animated:YES];
    NSLog(@"message view controller as signup pushed:%@ and %@",self,signUpViewController.messageTableViewController);
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


- (void)postToFacebook:(MessageTableViewCell *)cell {

    FacebookAPIPost *facebookAPIPost = [[FacebookAPIPost alloc]init];
    facebookAPIPost.messageTableViewController = self;
    facebookAPIPost.selectedSegment = self.selectedSegment;
    facebookAPIPost.selectedProgram = self.selectedProgram;
    [facebookAPIPost shareSegmentFacebookAPI];
}


-(void)logout {
    //removes zip default
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"zipCode"];
    [defaults removeObjectForKey:@"latitude"];
    [defaults removeObjectForKey:@"longitude"];
    [defaults synchronize];
    
    [PFUser logOut];
    NSLog(@"user logged out");
    [self viewDidLoad];
}
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"\u2699"  style:UIBarButtonItemStylePlain target:nil action:nil];
//    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void) getUserLocation {
//    LocationFinderAPI *locationFinderAPI = [[LocationFinderAPI alloc]init];
//    locationFinderAPI.messageTableViewController = self;
//    [locationFinderAPI findUserLocation];
    
    
    self.locationManager = [[CLLocationManager alloc] init];
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude] forKey:@"latitude"];
    [defaults setObject:[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude] forKey:@"longitude"];
    [defaults synchronize];
    NSLog(@"UPDATING DEFAULTS!!%@,%@",[defaults valueForKey:@"latitude"],[defaults valueForKey:@"longitude"]);
    
    //if currently a user then save location info to account.
    if([PFUser currentUser]) {
        NSString *latitudeString = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
        NSString *longitudeString =[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
        [[PFUser currentUser] setValue:latitudeString forKey:@"latitude"];
        [[PFUser currentUser] setValue:longitudeString forKey:@"longitude"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error) {
                NSLog(@"error UPDATING COORDINATES!!");
            } else{
                NSLog(@"UPDATING COORDINATES!!");
            }
        }];
    }

    [self viewDidLoad];
//    ParseAPI *parseAPI = [[ParseAPI alloc]init];
//    parseAPI.MessageTableViewController = self;
//    [parseAPI getParseMessageData:self.selectedSegment];

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
            //set user default so zip stays if user goes off table
//            [self.updateDefaults updateLocationDefaults];
            NSUserDefaults *defaults = [[NSUserDefaults alloc]init];
            [defaults setObject:zipCode forKey:@"zipCode"];
            [defaults synchronize];
            
            //If user, update the user current zip
            if([PFUser currentUser]) {
                [[PFUser currentUser] setValue:zipCode forKey:@"zipCode"];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(!error){
                        NSLog(@"succeeded saving user");
                    }
                }];
            }
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
            //set user default so zip stays if user goes off table
            NSUserDefaults *defaults = [[NSUserDefaults alloc]init];
            [defaults setObject:zipCode forKey:@"zipCode"];
            [defaults synchronize];
            
            //If user, update the user current zip
            if([PFUser currentUser]) {
                [[PFUser currentUser] setValue:zipCode forKey:@"zipCode"];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(!error){
                        NSLog(@"succeeded saving user");
                    }
                }];
            }
            
//            ParseAPI *parseAPI = [[ParseAPI alloc]init];
//            parseAPI.MessageTableViewController = self;
//            [parseAPI getParseMessageData:self.selectedSegment];
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
        return cell;
        
    } else if (isGetLocationBool) {
        //user has no zip or location
        NSLog(@"loading no location cell");
        MessageTableViewNoZipCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellCategoryNoZip" forIndexPath:indexPath];
        cell.layer.cornerRadius = 3;
        [self.tableView addSubview:cell];
        [cell configMessageCellNoZip:indexPath];
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
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *category= [self categoryForSection:indexPath.section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:category];
    NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row]; //pulling the row indece from array above
    
    // Get bool value from current index on list.
    NSDictionary *dictionary = [self.menuList objectAtIndex:[rowIndex intValue]];
    NSNumber *isMessageNumber = [dictionary valueForKey:@"isMessage"];
    bool isMessageBool = [isMessageNumber boolValue];
    
    NSNumber *isGetLocationNumber = [dictionary valueForKey:@"isGetLocationCell"];
    bool isGetLocationBool = [isGetLocationNumber boolValue];
    
    NSNumber *isCollapsedNumber = [dictionary valueForKey:@"isCollapsed"];
    bool isCollapsedBool = [isCollapsedNumber boolValue];

    if(isMessageBool) {
        NSString *messageText = [dictionary valueForKey:@"messageText"];
        double charCount = messageText.length;
        
        int rowHeight = 50;
            if (charCount < 50){
                rowHeight = 25;

            } else if (charCount < 100) {
                rowHeight = 35;

            } else {

                rowHeight = 50;
            }
        return rowHeight;
    } else if(isGetLocationBool) {
        return 55;
    } else if(isCollapsedBool) {
        return .0001;
    } else if([category isEqualToString:@"Local Representative"]) {
        return 65;
    } else { // normal contact cell
        return 65;
    }
}

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
        sectionLabel.font = [UIFont boldSystemFontOfSize:11];
        sectionLabel.textColor = [UIColor blackColor];
        sectionLabel.layer.cornerRadius = 3;
        sectionLabel.clipsToBounds = YES;
        NSString* padding = @"  "; // # of spaces
        sectionLabel.text = [NSString stringWithFormat:@"%@%@%@", padding, [self categoryForSection:section], padding];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"showMessageOptions"]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSLog(@"indexPath:%@",indexPath);
        NSString *category= [self categoryForSection:indexPath.section];
        NSArray *rowIndecesInSection = [self.sections objectForKey:category];
        NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row]; //pulling the row indece from array above
       
        MessageOptionsTableTableViewController *messageOptionsViewController = segue.destinationViewController;
        
        messageOptionsViewController.category = category;
        messageOptionsViewController.messageTableViewController = self;
        messageOptionsViewController.originIndexPath = indexPath;
        messageOptionsViewController.originRowIndex = rowIndex;
        messageOptionsViewController.messageOptionsList = self.messageOptionsList;
        messageOptionsViewController.menuList = self.menuList;
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



@end
