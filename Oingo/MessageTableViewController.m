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
#import "MessageTableViewCell.h"
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
#import "CongressFinderAPI.h"
#import "CongressionalMessageItem.h"
#import <UIKit/UIKit.h>
#import "MakePhoneCallAPI.h"
#import "EmailComposerViewController.h"



@interface MessageTableViewController () <UIGestureRecognizerDelegate,CLLocationManagerDelegate>
@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionToCategoryMap;
@property(nonatomic) CLLocationManager *locationManager;
@property(nonatomic) UILabel *longitudeLabel;
@property(nonatomic) UILabel *latitudeLabel;
@end

@implementation MessageTableViewController
@synthesize sections = _sections;
@synthesize sectionToCategoryMap = _sectionToCategoryMap;

MessageItem *messageItem;
CongressionalMessageItem *congressionalMessageItem;


NSInteger section;
NSInteger sectionHeaderHeight = 16;
NSInteger headerHeight = 48;
NSInteger footerHeight = 6;


-(void)viewWillAppear:(BOOL)animated {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // If a registered user then set default zip and location if available
    if([PFUser currentUser]){
        if([[PFUser currentUser] valueForKey:@"location"]) {
            [defaults setObject:[[PFUser currentUser] valueForKey:@"location"] forKey:@"location"];
            self.location = [defaults objectForKey:@"location"];
            [defaults synchronize];
            NSLog(@"user already has value for location");
        }
        
        if ([[PFUser currentUser] valueForKey:@"zipCode"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[[PFUser currentUser] valueForKey:@"zipCode"] forKey:@"zipCode"];
            self.zipCode= [defaults stringForKey:@"zipCode"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"user already has value for zip");
        }
    } else {    // not user
        
        // Now check user defaults to see if zip or location in cache
        if([[NSUserDefaults standardUserDefaults] stringForKey:@"latitude"] && [[NSUserDefaults standardUserDefaults] stringForKey:@"longitude"]){
            CLLocation *location = [[CLLocation alloc]initWithLatitude:[[defaults objectForKey:@"latitude"] doubleValue] longitude:[[[NSUserDefaults standardUserDefaults] stringForKey:@"longitude"] doubleValue]];
            self.location = location;
            NSLog(@"not user, but has location ");
            
        }
        if([[NSUserDefaults standardUserDefaults] stringForKey:@"zipCode"]){
            self.zipCode= [defaults stringForKey:@"zipCode"];
                        NSLog(@"not user, but has zipcode ");
        }
    }
    
    
    // if location data present, load with local reps
    if(self.zipCode || self.location) {
        NSLog(@"user has either zip or location %@,%@",self.location, self.zipCode);
        // zip here, fill in reps
        PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
        NSLog(@"selected campaign%@",self.selectedCampaign);
        [query whereKey:@"campaignID" equalTo:[self.selectedCampaign valueForKey:@"campaignID"]];
        [query orderByDescending:@"messageCategory"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.messageList = (NSMutableArray*)objects;  //messageList has everything ordered by category
                NSLog(@"messagelist location present:%@",self.messageList);
                //add congress people to list
                if(self.location){ //based on coordinate location
                    NSLog(@"got location, initiating congressfinder");
                    NSLog(@"initiating get congresswithlocation method:%@ and location %@",self.messageList, self.location);
                    
                    CongressFinderAPI *congressFinder = [[CongressFinderAPI alloc]init];
                    congressFinder.messageTableViewController = self;
                    [congressFinder getCongressWithLocation:self.location addToMessageList:(NSMutableArray*)self.messageList];
                } else { //or based on zipCode
                    CongressFinderAPI *congressFinder = [[CongressFinderAPI alloc]init];
                    congressFinder.messageTableViewController = self;
                    [congressFinder getCongress:self.zipCode addToMessageList:self.messageList];
                }
             //   [self.tableView reloadData];
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
    } else {
        
        // No location data, load without it
        PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
        [query whereKey:@"campaignID" equalTo:[self.selectedCampaign valueForKey:@"campaignID"]];
        [query orderByDescending:@"messageCategory"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.messageList = (NSMutableArray*)objects;  //messageList has everything ordered by category
                [self prepSections:self.messageList];
                [self.tableView reloadData];
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    
}

- (void)prepSections:(id)array {

    [self.sections removeAllObjects];
    [self.sectionToCategoryMap removeAllObjects];
    self.sections = [NSMutableDictionary dictionary];
    self.sectionToCategoryMap = [NSMutableDictionary dictionary];
    //Loops through every messageItem in the messageList and creates 2 dictionaries with index values and categories.
    NSInteger section = 0;
    NSInteger rowIndex = 0; //now 1
    for (MessageItem  *messageItem in self.messageList) {
        NSString *category = [messageItem valueForKey:@"messageCategory"]; //retrieves category for each message -1st regulator
        NSMutableArray *objectsInSection = [self.sections objectForKey:category]; //assigns objectsInSection value of sections for current category
        if (!objectsInSection) {
            objectsInSection = [NSMutableArray array];  //if new create array
            // this is the first time we see this category - increment the section index
            // sectionToCategoryMap literally it ends up (Regulator = 0)
            [self.sectionToCategoryMap setObject:category forKey:[NSNumber numberWithInt:(int)section++]]; // zero
        }
        [objectsInSection addObject:[NSNumber numberWithInt:(int)rowIndex++]]; //adds index number to objectsInSection temp array.
        [self.sections setObject:objectsInSection forKey:category]; //overwrite 1st object with new objects (2 regulatory objects).
    }
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

        //If touch on tweetButton, then
        if (CGRectContainsPoint(cell.tweetButton.frame, pointInCell)) {
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
    //Check if user logged in
    PFUser *currentUser = [PFUser currentUser];
    if(!currentUser) {  //if user not logged in, then go to signUpInScreen
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"signInViewController"];
        [self.navigationController pushViewController:controller animated:YES];
        
     //if logged in but not linked
    } else if(![PFTwitterUtils isLinkedWithUser:currentUser]){
        NSLog(@"user account not linked to twitter");
        [PFTwitterUtils linkUser:currentUser block:^(BOOL succeeded, NSError *error) {
            if(error){
                NSLog(@"There was an issue linking your twitter account. Please try again.");
            }
            else {
                NSLog(@"twitter account is linked");
                
                //Send the tweet
                NSString *tweetText = [NSString stringWithFormat:@"%@: %@",[self.selectedProgram valueForKey:@"programTitle"],[self.selectedCampaign valueForKey:@"topicTitle"]];
                NSURL *tweetURL = [NSURL URLWithString:[self.selectedCampaign valueForKey:@"linkToContent"]];
                PFFile *theImage = [self.selectedCampaign valueForKey:@"campaignImage"];
                NSData *imageData = [theImage getData];
                UIImage *image = [UIImage imageWithData:imageData];
                TWTRComposer *composer = [[TWTRComposer alloc] init];
                [composer setText:tweetText];
                [composer setURL:tweetURL];
                [composer setImage:image];
                [composer showWithCompletion:^(TWTRComposerResult result) {
                    if (result == TWTRComposerResultCancelled) {
                        NSLog(@"Tweet composition cancelled");
                    } else {
                        NSLog(@"Tweet is sent.");
                    }
                }];
            }
        }];
    } else {
        //Send the tweet
        NSString *tweetText = [NSString stringWithFormat:@"%@: %@",[self.selectedProgram valueForKey:@"programTitle"],[self.selectedCampaign valueForKey:@"topicTitle"]];
        NSURL *tweetURL = [NSURL URLWithString:[self.selectedCampaign valueForKey:@"linkToContent"]];
        PFFile *theImage = [self.selectedCampaign valueForKey:@"campaignImage"];
        NSData *imageData = [theImage getData];
        UIImage *image = [UIImage imageWithData:imageData];
        TWTRComposer *composer = [[TWTRComposer alloc] init];
        [composer setText:tweetText];
        [composer setURL:tweetURL];
        [composer setImage:image];
        [composer showWithCompletion:^(TWTRComposerResult result) {
            if (result == TWTRComposerResultCancelled) {
                NSLog(@"Tweet composition cancelled");
            } else {
                NSLog(@"Tweet is sent.");
            }
        }];
    }
}


- (IBAction)shareSegmentTwitter:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    if(!currentUser) {  //if user not logged in, then go to signUpInScreen
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"signInViewController"];
        [self.navigationController pushViewController:controller animated:YES];
        
        //if logged in but not linked
    } else if(![PFTwitterUtils isLinkedWithUser:currentUser]){
        NSLog(@"user account not linked to twitter");
        [PFTwitterUtils linkUser:currentUser block:^(BOOL succeeded, NSError *error) {
            if(error){
                NSLog(@"There was an issue linking your twitter account. Please try again.");
            }
            else {
                NSLog(@"twitter account is linked");
                //Send the tweet
                NSString *tweetText = [NSString stringWithFormat:@"%@: %@",[self.selectedProgram valueForKey:@"programTitle"],[self.selectedCampaign valueForKey:@"topicTitle"]];
                NSURL *tweetURL = [NSURL URLWithString:[self.selectedCampaign valueForKey:@"linkToContent"]];
                PFFile *theImage = [self.selectedCampaign valueForKey:@"campaignImage"];
                NSData *imageData = [theImage getData];
                UIImage *image = [UIImage imageWithData:imageData];
                
                TWTRComposer *composer = [[TWTRComposer alloc] init];
                [composer setText:tweetText];
                [composer setURL:tweetURL];
                [composer setImage:image];
                [composer showWithCompletion:^(TWTRComposerResult result) {
                    if (result == TWTRComposerResultCancelled) {
                        NSLog(@"Tweet composition cancelled");
                    } else {
                        NSLog(@"Tweet is sent.");
                    }
                }];
            }
        }];
    } else {
        //Send the tweet
        NSString *tweetText = [NSString stringWithFormat:@"%@: %@",[self.selectedProgram valueForKey:@"programTitle"],[self.selectedCampaign valueForKey:@"topicTitle"]];
        NSURL *tweetURL = [NSURL URLWithString:[self.selectedCampaign valueForKey:@"linkToContent"]];
        PFFile *theImage = [self.selectedCampaign valueForKey:@"campaignImage"];
        NSData *imageData = [theImage getData];
        UIImage *image = [UIImage imageWithData:imageData];
        
        TWTRComposer *composer = [[TWTRComposer alloc] init];
        [composer setText:tweetText];
        [composer setURL:tweetURL];
        [composer setImage:image];
        [composer showWithCompletion:^(TWTRComposerResult result) {
            if (result == TWTRComposerResultCancelled) {
                NSLog(@"Tweet composition cancelled");
            } else {
                NSLog(@"Tweet is sent.");
            }
        }];
    }

    
}

- (IBAction)shareSegmentFacebook:(id)sender {
    //Check if user logged in
    PFUser *currentUser = [PFUser currentUser];
    if(!currentUser) {  //if user not logged in, then go to signUpInScreen
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"signInViewController"];
        [self.navigationController pushViewController:controller animated:YES];

    
        
        //if logged in but not linked
    } else if(![PFFacebookUtils isLinkedWithUser:currentUser]){
        NSLog(@"user account not linked to facebook");
        [PFFacebookUtils linkUserInBackground:currentUser withPublishPermissions:@[@"publish_actions"] block:^(BOOL succeeded, NSError *error) {
            if(error){
                NSLog(@"There was an issue linking your facebook account. Please try again.");
            }
            else {
                NSLog(@"facebook account is linked");
                //Send the facebook status update
                FBSDKShareLinkContent *content = [FBSDKShareLinkContent new];
                content.contentURL = [NSURL URLWithString:self.selectedLink];
                content.contentTitle = [self.selectedCampaign valueForKey:@"programTitle"];
                content.contentDescription = [self.selectedCampaign valueForKey:@"purposeSummary"];
                FBSDKShareDialog *shareDialog = [FBSDKShareDialog new];
                [shareDialog setMode:FBSDKShareDialogModeAutomatic];
                [shareDialog setShareContent:content];
                [shareDialog setFromViewController:self];
                [shareDialog show];
            }
        }];
    } else {  //logged in and linked already
        
        FBSDKShareLinkContent *content = [FBSDKShareLinkContent new];
        content.contentURL = [NSURL URLWithString:self.selectedLink];
        content.contentTitle = [self.selectedProgram valueForKey:@"programTitle"];
        content.contentDescription = [self.selectedCampaign valueForKey:@"purposeSummary"];
        FBSDKShareDialog *shareDialog = [FBSDKShareDialog new];
        [shareDialog setMode:FBSDKShareDialogModeAutomatic];
        [shareDialog setShareContent:content];
        [shareDialog setFromViewController:self];
        [shareDialog show];
    }
}


- (void)postToFacebook:(MessageTableViewCell *)cell {
    //Check if user logged in
    PFUser *currentUser = [PFUser currentUser];
    if(!currentUser) {  //if user not logged in, then go to signUpInScreen
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"signInViewController"];
        [self.navigationController pushViewController:controller animated:YES];
        NSLog(@"send user to signup");

        //if logged in but not linked
    } else if(![PFFacebookUtils isLinkedWithUser:currentUser]){
        NSLog(@"user account not linked to facebook");
        [PFFacebookUtils linkUserInBackground:currentUser withPublishPermissions:@[@"publish_actions"] block:^(BOOL succeeded, NSError *error) {
            if(error){
                NSLog(@"There was an issue linking your facebook account. Please try again.");
            } else {
                NSLog(@"facebook account is linked");
                
                //Send the facebook status update
                FBSDKShareLinkContent *content = [FBSDKShareLinkContent new];
                content.contentURL = [NSURL URLWithString:self.selectedLink];
                content.contentTitle = @"Test Post!";
                content.contentDescription = @"Content Description";
                FBSDKShareDialog *shareDialog = [FBSDKShareDialog new];
                [shareDialog setMode:FBSDKShareDialogModeAutomatic];
                [shareDialog setShareContent:content];
                [shareDialog setFromViewController:self];
                [shareDialog show];
            }
        }];
    } else {  //logged in and linked already
        
        FBSDKShareLinkContent *content = [FBSDKShareLinkContent new];
        content.contentURL = [NSURL URLWithString:self.selectedLink];
        content.contentTitle = @"Test Post!";
        content.contentDescription = @"Content Description";
        FBSDKShareDialog *shareDialog = [FBSDKShareDialog new];
        [shareDialog setMode:FBSDKShareDialogModeAutomatic];
        [shareDialog setShareContent:content];
        [shareDialog setFromViewController:self];
        [shareDialog show];
    }
}


-(void)logout {
    //removes zip default
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"zipCode"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"location"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [PFUser logOut];
    NSLog(@"user logged out");
}
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"\u2699"  style:UIBarButtonItemStylePlain target:nil action:nil];
//    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude] forKey:@"latitude"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude] forKey:@"longitude"];
    
    // if a current user entered location, then save it to self and to user.
    self.location = newLocation;
    //[[NSUserDefaults standardUserDefaults] setObject:newLocation forKey:@"location"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //if currently a user then save location info to account.
    if([PFUser currentUser]) {
        [[PFUser currentUser] setValue:newLocation forKey:@"location"]; //no user
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error) {
                NSLog(@"error UPDATING COORDINATES!!");
            } else{
                NSLog(@"UPDATING COORDINATES!!");
            }
        }];
    }
    
    CongressFinderAPI *congressFinder = [[CongressFinderAPI alloc]init];
    congressFinder.messageTableViewController = self;
    [congressFinder getCongressWithLocation:newLocation addToMessageList:(NSMutableArray*)self.messageList];

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
            [[NSUserDefaults standardUserDefaults] setObject:zipCode forKey:@"zipCode"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //If user, update the user current zip
            if([PFUser currentUser]) {
                [[PFUser currentUser] setValue:zipCode forKey:@"zipCode"];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(!error){
                        NSLog(@"succeeded saving user");
                    }
                }];
            }
            self.zipCode = zipCode;

            CongressFinderAPI *congressFinderAPI = [[CongressFinderAPI alloc]init];
            congressFinderAPI.messageTableViewController = self;
            [congressFinderAPI getCongress:zipCode addToMessageList:self.messageList];
            NSLog(@"zip%@ messagelist%@",zipCode, self.messageList);
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
            [[NSUserDefaults standardUserDefaults] setObject:zipCode forKey:@"zipCode"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            //If user update the user current zip
            if([PFUser currentUser]) {
                [[PFUser currentUser] setValue:zipCode forKey:@"zipCode"];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(!error){
                        NSLog(@"succeeded saving user");
                    }
                }];
            }
            self.zipCode = zipCode;
            // if a current user entered zip, then save it.
            if(self.currentUser) {
                [self.currentUser setValue:zipCode forKey:@"zipCode"]; //no user
                [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {}];
            }
            
            CongressFinderAPI *congressFinderAPI = [[CongressFinderAPI alloc]init];
            congressFinderAPI.messageTableViewController = self;
            [congressFinderAPI getCongress:zipCode addToMessageList:self.messageList];
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
    NSLog(@"category: %@",category);
    
    if([category isEqualToString:@"Local Representative"] && !self.zipCode && !self.location) {
        //user has no zip or location
        NSLog(@"user no zip or loaction local rep cell");
        MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.layer.cornerRadius = 3;
        [self.tableView addSubview:cell];
        [cell configMessageCellNoZip:indexPath];
        return cell;
        
    } else if([category isEqualToString:@"Local Representative"]) {
        MessageTableViewRepresentativeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellRep" forIndexPath:indexPath];
        NSLog(@"user has loaction local rep cell");
        cell.layer.cornerRadius = 3;
        [self.tableView addSubview:cell];
        congressionalMessageItem = [self.messageList objectAtIndex:[rowIndex intValue]];
        [cell configMessageCellLocalRep:congressionalMessageItem indexPath:indexPath];
        return cell;
        
    } else {
        MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.layer.cornerRadius = 3;
        [self.tableView addSubview:cell];
        messageItem = [self.messageList objectAtIndex:[rowIndex intValue]];
        [cell configMessageCell:messageItem indexPath:indexPath];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *category= [self categoryForSection:indexPath.section];
    if([category isEqualToString:@"Local Representative"] && !self.zipCode && !self.location) {
        return 30;
    } else if([category isEqualToString:@"Local Representative"]) {
        return 70;
    } else {
        return 115;
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

    NSString *category= [self categoryForSection:section];
    if([category isEqualToString:@"Local Representative"] && !self.zipCode && !self.location) {
        return sectionHeaderHeight;
    } else if([category isEqualToString:@"Local Representative"]) {
        return sectionHeaderHeight +62;
    } else {
        return sectionHeaderHeight;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return footerHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    NSString *category= [self categoryForSection:section];

    if([category isEqualToString:@"Local Representative"] && !self.zipCode && !self.location) {
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
        
    } else if([category isEqualToString:@"Local Representative"]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(7, 0, tableView.frame.size.width -14 , sectionHeaderHeight +100)];
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
        
        
        UILabel *messageLabelForReps = [[UILabel alloc]initWithFrame:CGRectMake(10, 16,tableView.frame.size.width -20  , 61)];
        messageLabelForReps.text = [NSString stringWithFormat:@"\"%@\"", self.repMessageText];
//        messageLabelForReps.font = [UIFont boldSystemFontOfSize:12];
        messageLabelForReps.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
        messageLabelForReps.textColor = [UIColor blackColor];
        messageLabelForReps.textAlignment = NSTextAlignmentCenter;
        messageLabelForReps.backgroundColor = [UIColor whiteColor];
        [view addSubview:messageLabelForReps];
        
        return view;
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(7, 0, tableView.frame.size.width -14 , sectionHeaderHeight +70)];
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
