//
//  SettingsTableViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 6/12/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "PFTwitterUtils+NativeTwitter.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface SettingsTableViewController () <CLLocationManagerDelegate>
@property(nonatomic) CLLocationManager *locationManager;
@end

@implementation SettingsTableViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    
    
    PFUser *currentUser = [PFUser currentUser];
    
    //Set twitter/facebook toggle to off
    [self.linkTwitterSwitch setOn:NO animated:NO];
    [self.linkFacebookSwitch setOn:NO animated:NO];
        
    // User is logged in so load values from user settings to see if linked
    // Set twitter toggle
    if([PFTwitterUtils isLinkedWithUser:currentUser]){
        [self.linkTwitterSwitch setOn:YES animated:NO];
    } else {
        [self.linkTwitterSwitch setOn:NO animated:NO];
    }
    
    // Set facebook toggle
    if([PFFacebookUtils isLinkedWithUser:currentUser]){
        [self.linkFacebookSwitch setOn:YES animated:NO];
    } else {
        [self.linkFacebookSwitch setOn:NO animated:NO];
    }
    
    // Draw borders on buttons
    self.leaveFeedbackButton.layer.borderColor = [[UIColor colorWithRed:13/255.0 green:81/255.0 blue:183/255.0 alpha:1] CGColor];
    self.leaveFeedbackButton.layer.borderWidth = .5;
    self.leaveFeedbackButton.layer.cornerRadius =3;
    self.leaveFeedbackButton.clipsToBounds = YES;
    
    self.enterZipButton.layer.borderColor = [[UIColor blackColor]CGColor];
    self.enterZipButton.layer.borderWidth = .5;
    self.enterZipButton.layer.cornerRadius =3;
    self.enterZipButton.clipsToBounds = YES;
    
    self.logoutButton.layer.borderColor = [[UIColor blackColor]CGColor];
    self.logoutButton.layer.borderWidth = .5;
    self.logoutButton.layer.cornerRadius = 3;
    self.logoutButton.clipsToBounds = YES;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)logout:(id)sender {
    //removes zip default
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"zipCode"];
    [defaults removeObjectForKey:@"latitude"];
    [defaults removeObjectForKey:@"longitude"];
    [defaults synchronize];
    
    [PFUser logOut];
    NSLog(@"user logged out");
    NSLog(@"current user:%@", [PFUser currentUser]);
    [self.navigationController popViewControllerAnimated:YES];
    [self.messageTableViewController viewDidLoad];
}




#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 2;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 3;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
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
}
*/

- (IBAction)linktwitter:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    if([self.linkTwitterSwitch isOn]){
        NSLog(@"now its on");
        if (![PFTwitterUtils isLinkedWithUser:currentUser]) {
            [PFTwitterUtils linkUser:currentUser block:^(BOOL succeeded, NSError *error) {
                if(error){
                NSLog(@"problem linking with twitter");
                } else {
                NSLog(@"Woohoo, user is linked Twitter!");
                }
            }];
        } else {
            //This should never happen. IF they show as already linked just give them success message.
            NSLog(@"Twitter now linked.");
        }
    
    } else {
        NSLog(@"Twitter account is unlinked.");
        [PFTwitterUtils unlinkUserInBackground:currentUser block:^(BOOL succeeded, NSError *error) {
            NSLog(@"Woohoo, user is unlinked Twitter!");
        }];
    }
}

- (IBAction)linkfacebook:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    if([self.linkFacebookSwitch isOn]){
        NSLog(@"now its on, link the FB account");
            [PFFacebookUtils linkUserInBackground:currentUser withReadPermissions:@[@"public_profile",@"email"] block:^(BOOL succeeded, NSError *error) {
                if(error){
                    NSLog(@"problem linking with FB");
                } else {
                    NSLog(@"Woohoo, user is linked FB!");
                }
            }];
    } else {
        [PFFacebookUtils unlinkUserInBackground:currentUser block:^(BOOL succeeded, NSError *error) {
            NSLog(@"user is unlinked FB.");
        }];
    }
    
}

- (IBAction)getUserLocation:(id)sender {
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
    
    //if current a user then save location info to account.
    PFUser *currentUser = [PFUser currentUser];
    
    if(currentUser) {
        // Grab lat/long from newLocation object
        double latitude = newLocation.coordinate.latitude;
        double longitude = newLocation.coordinate.longitude;
        NSLog(@"latitude to be saved: %f",latitude);
        
        // Store lat/long data in currentUser instance
        [currentUser setObject:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
        [currentUser setObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];

        // Save to Parse
        [self saveToParse:currentUser];

    }
}

-(void)saveToParse:(PFUser*)currentUser{
    // Save to Parse
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //save currentUser to parse disk
        if(error){
            NSLog(@"error UPDATING COORDINATES!!");
        }
        else {
            NSLog(@"UPDATING COORDINATES!!");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
                [self.messageTableViewController viewDidLoad];
            });
        }
    }];
}

- (IBAction)lookUpZip:(id)sender {
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
            [UpdateDefaults saveLocationDefaultsToUser];
            [UpdateDefaults deleteCoordinates]; //purges lat/long from Defaults and currentUser(if neccesary)
            // Deleting coordinates in case they conflict with zipCode
            
            // Send back to MessageTableViewController
            [self.navigationController popViewControllerAnimated:YES];
            [self.messageTableViewController viewDidLoad];
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
            [UpdateDefaults saveLocationDefaultsToUser];
            [UpdateDefaults deleteCoordinates]; //purges lat/long from Defaults and currentUser(if neccesary)
            // Deleting coordinates in case they conflict with zipCode

            // Send back to MessageTableViewController
            [self.navigationController popViewControllerAnimated:YES];
            [self.messageTableViewController viewDidLoad];
        }
    }];
    
    [alertController addAction:lookUpAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    return zipCode;
}
@end
