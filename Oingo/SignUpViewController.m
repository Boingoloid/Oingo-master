//
//  SignUpViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 6/4/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "LogInViewController.h"
#import "ParseAPI.h"
#import "CongressFinderAPI.h"


@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpWithFacebookButton;
- (IBAction)signupwithfacebook:(id)sender;
- (IBAction)signup:(id)sender;
@end

@implementation SignUpViewController

BOOL isNewAccountSignup = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Change the placeholder text color
    UIColor *color = [UIColor darkGrayColor];
    self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName:color}];
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Choose password" attributes:@{NSForegroundColorAttributeName:color}];
    
    
    //change border
    self.emailField.layer.borderColor = [[UIColor blackColor] CGColor];
    self.emailField.layer.borderWidth = 0;
    self.passwordField.layer.borderColor = [[UIColor blackColor] CGColor];
    self.passwordField.layer.borderWidth = 0;
    
    //set password security text format
    self.passwordField.secureTextEntry = YES;
}

- (IBAction)signup:(id)sender {
    NSString *email = [[self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([password length] == 0 || [email length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure you enter an email address and password!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else {
        
        //Assign newUser values
        PFUser *newUser = [PFUser user];
        newUser.username = email;
        newUser.email = email;
        newUser.password = password;
        
        //Save the user
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                NSLog(@"there was an error %@",newUser.email);
            }
            else {
                dispatch_async(dispatch_get_main_queue(),^{
                    [self popToMessagesController];
                });

                NSLog(@"no error %@",newUser.email);
            }
        }];
    }
}

- (IBAction)signupwithfacebook:(id)sender {
    NSString *accessToken = [FBSDKAccessToken currentAccessToken].tokenString;
    NSArray *permissionsArray = @[@"public_profile",@"email", @"user_birthday", @"user_location"];
    
    NSLog(@"token %@",accessToken);
        [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
            if (!user) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else if (user.isNew) {
                NSLog(@"User signed up and logged in through Facebook!");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self popToMessagesController];
                });
                [self updateFacebookUserData];
                isNewAccountSignup = YES;
            } else {
                NSLog(@"User logged in through Facebook!");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.messageTableViewController viewDidLoad];
                    NSLog(@"viewDidLoad from SignUp");
                    [self popToMessagesController];
                });
                [self updateFacebookUserData];
//                [FBSDKProfile currentProfile];
//                [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
            }
        }];
}


-(void)popToMessagesController {
    int viewsToPopAfterSignUp = 1; //Pop 1 views (signup)  Remember index starts at 0.
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex: self.navigationController.viewControllers.count-viewsToPopAfterSignUp-1] animated:YES];
    [self.messageTableViewController viewDidLoad];
}

-(void)updateFacebookUserData {
    FBSDKGraphRequest *requestMe = [[FBSDKGraphRequest alloc]initWithGraphPath:@"me" parameters:@{@"fields": @"id,name,link,first_name, last_name, picture.type(large), email, birthday,location ,hometown , gender, timezone, updated_time, verified"}];
    FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
    [connection addRequest:requestMe completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if(!result){
            NSLog(@"There has been an error retrieving fb data for user");
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self popToMessagesController];
            });
            
            [self updateAllFacebookFields:result];
        }
    }];
    [connection start];
}

-(void) updateAllFacebookFields:(id)result {
    PFUser *currentUser = [PFUser currentUser];
        NSLog(@"result:%@",result);
    [currentUser setEmail:[result objectForKey:@"email"]];  // updating email in currentUser
    [currentUser setObject:[result objectForKey:@"gender"] forKey:@"genderfb"];
    [currentUser setObject:[result objectForKey:@"first_name"] forKey:@"first_namefb"];
    [currentUser setObject:[result objectForKey:@"last_name"] forKey:@"last_namefb"];
    [currentUser setObject:[result objectForKey:@"updated_time"] forKey:@"updated_timefb"];
    [currentUser setObject:[result objectForKey:@"verified"] forKey:@"Verifiedfb"];
    [currentUser setObject:[result objectForKey:@"id"] forKey:@"fbID"];
    [currentUser setObject:[result objectForKey:@"link"] forKey:@"linkfb"];
    [currentUser setObject:[result objectForKey:@"timezone"] forKey:@"timezonefb"];
    
    if([result objectForKey:@"hometown"]){
        [currentUser setObject:[result objectForKey:@"hometown"] forKey:@"hometownfb"];
    }
    if([result objectForKey:@"birthday"]){
        [currentUser setObject:[result objectForKey:@"birthday"] forKey:@"birthdayfb"];
    }
    if([result objectForKey:@"location"]){
        [currentUser setObject:[result objectForKey:@"location"] forKey:@"locationfb"];
    }
        
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //save currentUser to parse disk
        if(error){
            [self showDuplicateEmailAlert:currentUser.email]; //Email already exists, show alert
        }
        else {
            NSLog(@"no error, email was updated fine");
        }
    }];
}

-(void) showDuplicateEmailAlert:(NSString *)email {
    if(isNewAccountSignup) {
        [PFUser logOut];
        [[PFUser currentUser] deleteInBackground]; //delete new user
        isNewAccountSignup = NO; //reset BOOL
    } else {
        [PFUser logOut]; //logout user with conflicting email
    }
    NSString *alertTitle = @"Email matches existing account";
    NSString *alertMessage = @"The email on your facebook profile is associated with an existing account.  Please login and link your facebook account.";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    //Add OK action button
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSLog(@"OK action");
        [self performSegueWithIdentifier:@"showLogIn" sender:self];
//        self.emailField.text = email;
//        [self.passwordField becomeFirstResponder];
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showLogIn"]){
        LogInViewController *logInViewController = [segue destinationViewController];
        logInViewController.messageTableViewController = self.messageTableViewController;
        NSLog(@"message table controller right before send to login:%@",logInViewController.messageTableViewController);
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //hide the keyborad
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.passwordField isFirstResponder] && [touch view] != self.passwordField) {
        [self.passwordField resignFirstResponder];
    } else if ([self.emailField isFirstResponder] && [touch view] != self.emailField) {
        [self.emailField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}


@end
