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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    PFUser *currentUser = [PFUser currentUser];

    // If a registered user then set default zip and location if available
    //? do I need to check if a sessionDefaults object already exists?
    if(currentUser){
        if([currentUser valueForKey:@"locationLatitude"] && [currentUser valueForKey:@"locationLongitude"]) {
            [defaults setObject:[currentUser valueForKey:@"locationLatitude"] forKey:@"latitude"];
            [defaults setObject:[currentUser valueForKey:@"locationLongitude"] forKey:@"longitude"];
            [defaults synchronize];
            NSLog(@"user already has value for location");
        }
        
        if ([currentUser valueForKey:@"zipCode"]) {
            [defaults setObject:[currentUser valueForKey:@"zipCode"] forKey:@"zipCode"];
            [defaults synchronize];
            NSLog(@"user already has value for zip");
        }
    }
    
    ParseAPI *parseAPI = [[ParseAPI alloc]init];
    parseAPI.messageTableViewController = self;
    [parseAPI getParseMessageData:self.selectedCampaign];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Format table header
    self.tableHeaderView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.tableHeaderView.layer.borderWidth = .5;
    self.tableHeaderView.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    self.tableHeaderView.layer.cornerRadius = 3;
    self.tableHeaderView.clipsToBounds = YES;
    
    NSString* padding = @"  "; // # of spaces
    self.tableHeaderLabel.text = [NSString stringWithFormat:@"%@%@%@", padding,[self.selectedCampaign valueForKey:@"topicTitle"], padding];
        self.tableHeaderSubLabel.text = [NSString stringWithFormat:@"%@%@%@", padding,[self.selectedProgram valueForKey:@"programTitle"], padding];

    //Create gesture recognizer
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture:)]; //connect recognizer to action method.
    tapRecognizer.delegate = self;
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [tapRecognizer setCancelsTouchesInView:NO];
    [self.tableView addGestureRecognizer:tapRecognizer];
    
    //create logout button
    UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(logout)];
     [[NSUserDefaults standardUserDefaults] synchronize];
    self.navigationItem.rightBarButtonItem = logOutButton;
}



- (void)respondToTapGesture:(UITapGestureRecognizer *)tap {
   
    //This is what we use for touches in the cells
    //It grabs point coordinate of touch as finger lifted
    //Pulls the indexPath of the of the touch
    //Testing result is below
    if (UIGestureRecognizerStateEnded == tap.state) {
        UITableView *tableView = (UITableView *)tap.view;
        CGPoint p = [tap locationInView:tap.view];
        NSLog(@"%@",NSStringFromCGPoint(p));
        NSIndexPath* indexPath = [tableView indexPathForRowAtPoint:p];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        MessageTableViewCell *cell = (MessageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        CGPoint pointInCell = [tap locationInView:cell];
        NSLog(@"coordinates pointp%@",NSStringFromCGPoint(p));
        NSLog(@"coordinates indexpath%@",indexPath);
      
        NSString *category= [self categoryForSection:indexPath.section];
        NSArray *rowIndecesInSection = [self.sections objectForKey:category];
        NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row]; //pulling the row indece from array above
        
        
        NSDictionary *dictionary = [self.messageList objectAtIndex:[rowIndex intValue]];
        NSNumber *isMessageNumber = [dictionary valueForKey:@"isMessage"];
        bool isMessageBool = [isMessageNumber boolValue];
        NSLog(@"is message: %d",isMessageBool);
//        NSNumber *isGetLocationNumber = [dictionary valueForKey:@"isGetLocationCell"];
//        bool isGetLocationBool = [isGetLocationNumber boolValue];
        NSLog(@"category: %@",category);
        NSLog(@"category from dictionary%@",[dictionary valueForKey:@"messageCategory"]);

        
        if(isMessageBool){
            NSLog(@"touch in message cell, don't worry about it for now.");
        //If touch on tweetButton, then
        } else if (CGRectContainsPoint(cell.tweetButton.frame, pointInCell)) {
            NSLog(@"touch in tweet button area");
            [self tweet:cell];
        //if touch on postToFacebookButton, then
        } else if(CGRectContainsPoint(cell.postToFacebookButton.frame, pointInCell)) {
            NSLog(@"touch in facebook button area");
            [self postToFacebook:cell];
        } else if(CGRectContainsPoint(cell.zipCodeButton.frame, pointInCell)) {
            NSLog(@"touch in zipCodeButton area");
            [self lookUpZip];
        } else if (CGRectContainsPoint(cell.locationButton.frame, pointInCell)) {
            NSLog(@"touch in getUserLocation area");
            [self getUserLocation];
        } else if (CGRectContainsPoint(cell.phoneButton.frame, pointInCell)) {
            NSLog(@"touch in phone area");
            NSString *phoneNumber =[[cell.phone componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
            MakePhoneCallAPI *makePhoneCallAPI = [[MakePhoneCallAPI alloc] init];
            [makePhoneCallAPI dialPhoneNumber:phoneNumber];
        } else if (CGRectContainsPoint(cell.emailButton.frame, pointInCell)) {
            NSLog(@"touch in email area");
            EmailComposerViewController *emailComposer = [[EmailComposerViewController alloc] init];
            [emailComposer showMailPicker:cell.openCongressEmail withMessage:cell.messageText.text];
            [self presentViewController:emailComposer animated:YES completion:NULL];
        } else if (CGRectContainsPoint(cell.webFormButton.frame, pointInCell)) {
            NSLog(@"touch in webForm area");
            NSString *url = cell.contantForm;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        } else if (CGRectContainsPoint(cell.messageImage.frame, pointInCell)) {
            NSLog(@"touch in image area");
        } else {
            NSLog(@"touch in outer area");
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    UITableView *tableView = (UITableView *)gestureRecognizer.view;
    CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view];
    //if point is in the tableview then return YES
    if ([tableView indexPathForRowAtPoint:p]) {
        return YES;
    }
    return NO;
}

- (void)tweet:(MessageTableViewCell *)cell {
    TwitterAPITweet *twitterAPITweet = [[TwitterAPITweet alloc]init];
    twitterAPITweet.messageTableViewController = self;
    twitterAPITweet.selectedCampaign = self.selectedCampaign;
    twitterAPITweet.selectedProgram = self.selectedProgram;
    [twitterAPITweet shareMessageTwitterAPI:cell];
}


- (IBAction)shareSegmentTwitter:(id)sender {
    TwitterAPITweet *twitterAPITweet = [[TwitterAPITweet alloc]init];
    twitterAPITweet.messageTableViewController = self;
    twitterAPITweet.selectedCampaign = self.selectedCampaign;
    twitterAPITweet.selectedProgram = self.selectedProgram;
    [twitterAPITweet shareSegmentTwitterAPI];
}

- (IBAction)shareSegmentFacebook:(id)sender {
    FacebookAPIPost *facebookAPIPost = [[FacebookAPIPost alloc]init];
    facebookAPIPost.messageTableViewController = self;
    facebookAPIPost.selectedCampaign = self.selectedCampaign;
    facebookAPIPost.selectedProgram = self.selectedProgram;
    [facebookAPIPost shareSegmentFacebookAPI];
}


- (void)postToFacebook:(MessageTableViewCell *)cell {

    FacebookAPIPost *facebookAPIPost = [[FacebookAPIPost alloc]init];
    facebookAPIPost.messageTableViewController = self;
    facebookAPIPost.selectedCampaign = self.selectedCampaign;
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
}
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"\u2699"  style:UIBarButtonItemStylePlain target:nil action:nil];
//    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


//          SAVING MESSAGE DATA TO PARSE
//            //------------------------- second table text
//            PFObject *facebookUserData = [PFObject objectWithClassName:@"facebookUserData"];
//
//            [facebookUserData setObject:[result objectForKey:@"gender"] forKey:@"gender"];
//            [facebookUserData setObject:[result objectForKey:@"email"] forKey:@"email"];
//
//            [facebookUserData saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //save currentUser to parse disk
//                if(error){
//                    [self showDuplicateEmailAlert:currentUser.email]; //Email already exists, show alert
//                }
//                else {
//                    NSLog(@"no error, email was updated fine");
//                }
//            }];


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
        [[PFUser currentUser] setValue:latitudeString forKey:@"locationLatitude"];
        [[PFUser currentUser] setValue:longitudeString forKey:@"locationLongitude"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error) {
                NSLog(@"error UPDATING COORDINATES!!");
            } else{
                NSLog(@"UPDATING COORDINATES!!");
            }
        }];
    }
    
    ParseAPI *parseAPI = [[ParseAPI alloc]init];
    parseAPI.MessageTableViewController = self;
    [parseAPI getParseMessageData:self.selectedCampaign];
    
//Note: if going directly to congressFinderAPI you must check that they isGetLocationCell does not exist.  Delete it if it does.
//    CongressFinderAPI *congressFinder = [[CongressFinderAPI alloc]init];
//    congressFinder.messageTableViewController = self;
//    congressFinder.parseAPI = parseAPI;
//    [congressFinder getCongressWithLatitude:newLocation.coordinate.latitude andLongitude:newLocation.coordinate.longitude addToMessageList:(NSMutableArray*)self.messageList];
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
            
            ParseAPI *parseAPI = [[ParseAPI alloc]init];
            parseAPI.MessageTableViewController = self;
            [parseAPI getParseMessageData:self.selectedCampaign];
//            CongressFinderAPI *congressFinder = [[CongressFinderAPI alloc]init];
//            congressFinder.messageTableViewController = self;
//            congressFinder.parseAPI = parseAPI;
//            [congressFinder getCongress:zipCode addToMessageList:self.messageList];
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
            
            ParseAPI *parseAPI = [[ParseAPI alloc]init];
            parseAPI.MessageTableViewController = self;
            [parseAPI getParseMessageData:self.selectedCampaign];
//            CongressFinderAPI *congressFinder = [[CongressFinderAPI alloc]init];
//            congressFinder.messageTableViewController = self;
//            congressFinder.parseAPI = parseAPI;
//            [congressFinder getCongress:zipCode addToMessageList:self.messageList];
//            NSLog(@"zip%@ messagelist%@",zipCode, self.messageList);
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


    

    // Get bool value from current index on list.
    NSDictionary *dictionary = [self.messageList objectAtIndex:[rowIndex intValue]];
    NSNumber *isMessageNumber = [dictionary valueForKey:@"isMessage"];
    bool isMessageBool = [isMessageNumber boolValue];
        NSLog(@"is message: %d",isMessageBool);
    NSNumber *isGetLocationNumber = [dictionary valueForKey:@"isGetLocationCell"];
    bool isGetLocationBool = [isGetLocationNumber boolValue];
        NSLog(@"category: %@",category);
    NSLog(@"category from dictionary%@",[dictionary valueForKey:@"messageCategory"]);


    
    if(isMessageBool){
        MessageTableViewMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellCategoryMessage" forIndexPath:indexPath];
        NSLog(@"loading message cell");
        cell.layer.cornerRadius = 3;
        [self.tableView addSubview:cell];
        messageItem = [self.messageList objectAtIndex:[rowIndex intValue]];
        [cell configMessageCell:messageItem indexPath:indexPath];
        return cell;
        
    } else if (isGetLocationBool) {
        //user has no zip or location
        NSLog(@"loading no location cell");
        MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.layer.cornerRadius = 3;
        [self.tableView addSubview:cell];
        [cell configMessageCellNoZip:indexPath];
        return cell;
        
    } else if([category isEqualToString:@"Local Representative"]) {
        MessageTableViewRepresentativeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellRep" forIndexPath:indexPath];
        NSLog(@"loading local rep cell");
        cell.layer.cornerRadius = 3;
        [self.tableView addSubview:cell];
        congressionalMessageItem = [self.messageList objectAtIndex:[rowIndex intValue]];
        [cell configMessageCellLocalRep:congressionalMessageItem indexPath:indexPath];
        return cell;
        
    } else {
        MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        NSLog(@"loading civilian");
        cell.layer.cornerRadius = 3;
        [self.tableView addSubview:cell];
        messageItem = [self.messageList objectAtIndex:[rowIndex intValue]];
        [cell configMessageCell:messageItem indexPath:indexPath];
        return cell;

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *category= [self categoryForSection:indexPath.section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:category];
    NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row]; //pulling the row indece from array above
    
    // Get bool value from current index on list.
    NSDictionary *dictionary = [self.messageList objectAtIndex:[rowIndex intValue]];
    NSNumber *isMessageNumber = [dictionary valueForKey:@"isMessage"];
    bool isMessageBool = [isMessageNumber boolValue];

    NSNumber *isGetLocationNumber = [dictionary valueForKey:@"isGetLocationCell"];
    bool isGetLocationBool = [isGetLocationNumber boolValue];
    NSLog(@"MESSAGE BOOL%d",isMessageBool);
    
    if(isMessageBool) {
        return 30;
    } else if(isGetLocationBool) {
        return 60;
    } else if([category isEqualToString:@"Local Representative"]) {
        return 65;
    } else {
        return 90;
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return footerHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    NSString *category= [self categoryForSection:section];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

//    if([category isEqualToString:@"Local Representative"] && ![defaults valueForKey:@"zipCode"] && ![defaults valueForKey:@"latitude"]) {
        //do nothing
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
//        
//    } else if([category isEqualToString:@"Local Representative"]) {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(7, 0, tableView.frame.size.width -14 , localRepSectionHeaderHeight)];
//        UILabel *sectionLabel = [[UILabel alloc] init];
//        sectionLabel.frame = CGRectMake(7, 0, tableView.frame.size.width -14, sectionHeaderHeight);
//        sectionLabel.backgroundColor = [UIColor colorWithRed:.96 green:.96 blue:.96 alpha:1];
//        sectionLabel.layer.borderWidth = .5;
//        sectionLabel.layer.borderColor = [[UIColor blackColor] CGColor];
//        sectionLabel.font = [UIFont boldSystemFontOfSize:11];
//        sectionLabel.textColor = [UIColor blackColor];
//        sectionLabel.layer.cornerRadius = 3;
//        sectionLabel.clipsToBounds = YES;
//        NSString* padding = @"  "; // # of spaces
//        sectionLabel.text = [NSString stringWithFormat:@"%@%@%@", padding, [self categoryForSection:section], padding];
//        [view addSubview:sectionLabel];
//        
//        
//        UILabel *messageLabelForReps = [[UILabel alloc]initWithFrame:CGRectMake(10, 20,tableView.frame.size.width -20  , localRepSectionHeaderHeight - 20)];
//        messageLabelForReps.text = [NSString stringWithFormat:@"\"%@\"", self.repMessageText];
//        messageLabelForReps.lineBreakMode = NSLineBreakByWordWrapping;
//        messageLabelForReps.numberOfLines = 0;
//        messageLabelForReps.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
//        messageLabelForReps.textColor = [UIColor blackColor];
//        messageLabelForReps.textAlignment = NSTextAlignmentCenter;
//        messageLabelForReps.backgroundColor = [UIColor whiteColor];
//        [view addSubview:messageLabelForReps];
//        
//        return view;
//    } else {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(7, 0, tableView.frame.size.width -14 , sectionHeaderHeight +70)];
//        UILabel *sectionLabel = [[UILabel alloc] init];
//        sectionLabel.frame = CGRectMake(7, 0, tableView.frame.size.width -14, sectionHeaderHeight);
//        sectionLabel.backgroundColor = [UIColor colorWithRed:.96 green:.96 blue:.96 alpha:1];
//        sectionLabel.layer.borderWidth = .5;
//        sectionLabel.layer.borderColor = [[UIColor blackColor] CGColor];
//        sectionLabel.font = [UIFont boldSystemFontOfSize:11];
//        sectionLabel.textColor = [UIColor blackColor];
//        sectionLabel.layer.cornerRadius = 3;
//        sectionLabel.clipsToBounds = YES;
//        NSString* padding = @"  "; // # of spaces
//        sectionLabel.text = [NSString stringWithFormat:@"%@%@%@", padding, [self categoryForSection:section], padding];
//        [view addSubview:sectionLabel];
//        return view;
//    }
}

//-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(8, 0, tableView.frame.size.width -14 , footerHeight )];
//    UILabel *footerLabel = [[UILabel alloc] init];
//    [view addSubview:footerLabel];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
*/



@end
