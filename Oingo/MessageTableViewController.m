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
    

    //if current user has zip, load it and set as NSDefault,
    if([[PFUser currentUser] valueForKey:@"zipCode"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[[PFUser currentUser] valueForKey:@"zipCode"] forKey:@"zipCode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.zipCode =[[PFUser currentUser] valueForKey:@"zipCode"];
    }
    
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"zipCode"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.zipCode= [defaults stringForKey:@"zipCode"];
        // zip here, fill in reps
        
        PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
        [query whereKey:@"campaignID" equalTo:[self.selectedCampaign valueForKey:@"campaignID"]];
        [query orderByDescending:@"messageCategory"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.messageList = (NSMutableArray*)objects;  //messageList has everything ordered by category
                //add congress people to list
                CongressFinderAPI *congressFinderAPI = [[CongressFinderAPI alloc]init];
                congressFinderAPI.messageTableViewController = self;
                [congressFinderAPI getCongress:self.zipCode addToMessageList:self.messageList];
                // Sections already being prepped in congressFinderAPI
                //[self prepSections:self.messageList];
                [self.tableView reloadData];
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
    } else {
        //zip not here, load without
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
        NSLog(@"flag prepsections");

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


    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager
         respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    } 
    //Format table header
    
    self.tableHeaderView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.tableHeaderView.layer.borderWidth = .5;
    self.tableHeaderView.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    self.tableHeaderView.layer.cornerRadius = 3;
    self.tableHeaderView.clipsToBounds = YES;
    
    NSString* padding = @"  "; // # of spaces
    self.tableHeaderLabel.text = [NSString stringWithFormat:@"%@%@/%@ %@", padding,[self.selectedProgram valueForKey:@"programTitle"],[self.selectedCampaign valueForKey:@"topicTitle"], padding];

    //Create gesture recognizer
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture:)]; //connect recognizer to action method.
    tapRecognizer.delegate = self;
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [tapRecognizer setCancelsTouchesInView:NO];
    [self.tableView addGestureRecognizer:tapRecognizer];
    
    //create logout button
    UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(logout)];
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
            NSLog(@"touch in getLocation area");
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
        NSLog(@"send user to signup");
        
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
    NSLog(@"ok Twitter is happening");
    PFUser *currentUser = [PFUser currentUser];
    if(!currentUser) {  //if user not logged in, then go to signUpInScreen
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"signInViewController"];
        [self.navigationController pushViewController:controller animated:YES];
        NSLog(@"send user to signup");
        
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
    NSLog(@"ok FB post is happening");
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
        NSLog(@"%@",[self.selectedCampaign valueForKey:@"purposeSummary"]);
        FBSDKShareDialog *shareDialog = [FBSDKShareDialog new];
        [shareDialog setMode:FBSDKShareDialogModeAutomatic];
        [shareDialog setShareContent:content];
        [shareDialog setFromViewController:self];
        [shareDialog show];
    }
}


- (void)postToFacebook:(MessageTableViewCell *)cell {
    NSLog(@"ok FB post is happening");
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
    NSLog(@"see if selector works = yes");
    PFUser *currentUser = [PFUser currentUser];
    PFGeoPoint *userGeoPoint = currentUser[@"location"];
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            NSLog(@"geopoint %@", userGeoPoint);
        } else {
            NSLog(@"error");
        }
    }];
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
            NSLog(@"Yes, it is a good zip");
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
            NSLog(@"zip.code %@",self.zipCode);
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
        NSLog(@"Look up");
        //get value entered
        NSString *zipCode = [alertController.textFields.firstObject valueForKey:@"text"];
        NSLog(@"zipCode:%@",zipCode);
        
        __block NSUInteger count = 0;
        [zipCode enumerateSubstringsInRange:NSMakeRange(0, [zipCode length])
                                    options:NSStringEnumerationByComposedCharacterSequences
                                 usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                     count++;
                                 }];
        if(count != 5) {
            [self retryZipCode:zipCode count:count];
        } else {
            NSLog(@"Yes, it is a good zip");
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
            NSLog(@"zip.code %@",self.zipCode);
            // if a current user entered zip, then save it.
            if(self.currentUser) {
                [self.currentUser setValue:zipCode forKey:@"zipCode"]; //no user
                [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {}];
            }
            
            CongressFinderAPI *congressFinderAPI = [[CongressFinderAPI alloc]init];
            congressFinderAPI.messageTableViewController = self;
            [congressFinderAPI getCongress:zipCode addToMessageList:self.messageList];        }
    }];
    [alertController addAction:lookUpAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    return zipCode;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.layer.cornerRadius = 3;
    [self.tableView addSubview:cell];
    
    NSString *category= [self categoryForSection:indexPath.section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:category];
    NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row]; //pulling the row indece from array above
    NSLog(@"category: %@",category);
    
    
    
    if([category isEqualToString:@"Local Representative"] && !self.zipCode) { //user has no zip
        [cell configMessageCellNoZip:indexPath];
    } else if([category isEqualToString:@"Local Representative"]) {
        NSLog(@"new loading of local rep");
        congressionalMessageItem = [self.messageList objectAtIndex:[rowIndex intValue]];
        [cell configMessageCellLocalRep:congressionalMessageItem indexPath:indexPath];
    } else {    
        messageItem = [self.messageList objectAtIndex:[rowIndex intValue]];
        [cell configMessageCell:messageItem indexPath:indexPath];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *category= [self categoryForSection:indexPath.section];
    if([category isEqualToString:@"Local Representative"] && !self.zipCode) {
        return 30;
    } else if([category isEqualToString:@"Local Representative"]) {
        return 115;
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
    return sectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return footerHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(7, 0, tableView.frame.size.width -14 , sectionHeaderHeight )];
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
