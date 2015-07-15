//
//  LogInViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 6/5/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "LogInViewController.h"
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "ParseAPI.h"

@interface LogInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *facebookLogInButton;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

- (IBAction)login:(id)sender;
- (IBAction)forgotpassword:(id)sender;
- (IBAction)facebooklogin:(id)sender;

@end

@implementation LogInViewController


BOOL isNewAccount = NO;

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

- (IBAction)login:(id)sender {
    NSString *email = [[self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([password length] == 0 || [email length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure you enter an email address and password!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else {
        [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
            else {
                [self popToMessagesController];
            }
        }];
    }
}

-(BOOL)isValidEmail:(NSString*)email{
    BOOL stricterFilter = NO;
    BOOL isValidEmail = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    isValidEmail = [emailTest evaluateWithObject:email];
    return isValidEmail;
}

- (IBAction)forgotpassword:(id)sender {
    NSString *email = [[self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    
    //Check if fields are blank
    if([email length] == 0){ //check pw field not blank
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please enter an email address first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {  //if not blank, check if email is a valid email
        if(![self isValidEmail:email]) {
            UIAlertView *alertViewVaidEmail = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertViewVaidEmail show];
        } else {
            
            //if email valid, then check if user exist
            PFQuery *query = [PFUser query];
            [query whereKey:@"email" equalTo:email];
            if (![query getFirstObject]){ //if user does not exit, show message and encourage sign up
                UIAlertView *alertViewEmailSent = [[UIAlertView alloc] initWithTitle:@"We don't recognize that email." message:[NSString stringWithFormat:@"Hi!, we don't have an account associated with %@.  Please proceed to Sign Up!",email] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertViewEmailSent show];
                
            } else { //if user does exist, confirm that we should send email from user

                //Create alert
                NSString *alertTitle = @"Confirm Forgotten Password?";
                NSString *alertMessage = [NSString stringWithFormat:@"Would you like us to send a password reset email to: %@?",email];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"YES, reset password", @"OK action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    NSLog(@"OK action");
                    [PFUser requestPasswordResetForEmailInBackground:email];
                    [PFUser requestPasswordResetForEmailInBackground:@"matthew.acalin@gmail.com"];
                    UIAlertView *alertViewEmailSent = [[UIAlertView alloc] initWithTitle:@"Email sent!" message:@"Password reset email has been sent." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertViewEmailSent show];
                }];
                [alertController addAction:okAction];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    NSLog(@"cancel action");
                }];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    }
}


-(void)popToMessagesController {
    int viewsToPopAfterLogin = 2; //Pop 2 views (signup and login)  Remember index starts at 0.
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex: self.navigationController.viewControllers.count-viewsToPopAfterLogin-1] animated:YES];
    self.updateDefaults = [[UpdateDefaults alloc]init];
    [self.updateDefaults updateLocationDefaults];
    
    ParseAPI *parseAPI = [[ParseAPI alloc]init];
    parseAPI.messageTableViewController = self.messageTableViewController;
    [parseAPI getParseMessageData:self.messageTableViewController.selectedSegment];
    
    [self.messageTableViewController.tableView reloadData];
    
    
}

- (IBAction)facebooklogin:(id)sender {
    NSString *accessToken = [FBSDKAccessToken currentAccessToken].tokenString;
    NSLog(@"token %@",accessToken);
    if(![FBSDKAccessToken currentAccessToken]){
        [PFFacebookUtils logInInBackgroundWithReadPermissions:@[@"public_profile",@"email"] block:^(PFUser *user, NSError *error) {
            isNewAccount = NO;
            if (!user) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else if (user.isNew) {
                NSLog(@"User signed up and logged in through Facebook!");
                [self updateFacebookUserData];
                isNewAccount = YES;
            } else {
                NSLog(@"User logged in through Facebook!");
                [self updateFacebookUserData];
            }
            
        }];
    }
    else {
        [PFFacebookUtils logInInBackgroundWithAccessToken:[FBSDKAccessToken currentAccessToken] block:^(PFUser *user, NSError *error) {
            isNewAccount = NO;
            if (!user) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else if (user.isNew) {
                NSLog(@"User signed up and logged in through Facebook!");
                [self updateFacebookUserData];
                isNewAccount = YES;
                [self popToMessagesController];
            } else {
                NSLog(@"User logged in through Facebook!");
                [self updateFacebookUserData];
                [self popToMessagesController];
            }
        }];
    }
}


-(void)updateFacebookUserData {
    FBSDKGraphRequest *requestMe = [[FBSDKGraphRequest alloc]initWithGraphPath:@"me" parameters:nil];
    FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
    [connection addRequest:requestMe completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {

        if(!result){
            NSLog(@"There has been an error retrieving fb data for user");
        }
        else {
            [self updateAllFacebookFields:result];
        }
    }];
    [connection start];
}


-(void) updateAllFacebookFields:(id)result {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setEmail:[result objectForKey:@"email"]];  // updating email in currentUser
    [currentUser setObject:[result objectForKey:@"gender"] forKey:@"genderfb"];
    [currentUser setObject:[result objectForKey:@"first_name"] forKey:@"first_namefb"];
    [currentUser setObject:[result objectForKey:@"last_name"] forKey:@"last_namefb"];
    [currentUser setObject:[result objectForKey:@"link"] forKey:@"linkfb"];
    [currentUser setObject:[result objectForKey:@"locale"] forKey:@"localefb"];
    [currentUser setObject:[result objectForKey:@"timezone"] forKey:@"timezonefb"];
    [currentUser setObject:[result objectForKey:@"updated_time"] forKey:@"updated_timefb"];
    [currentUser setObject:[result objectForKey:@"verified"] forKey:@"Verifiedfb"];
    [currentUser setObject:[result objectForKey:@"id"] forKey:@"fbID"];
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //save currentUser to parse disk
        if(error){
            [self showDuplicateEmailAlert:currentUser.email]; //Email already exists, show alert
        }
        else {
            NSLog(@"no error, email was updated fine");
            [self popToMessagesController];
        }
    }];
}


-(void) showDuplicateEmailAlert:(NSString *)email {
    if(isNewAccount) {
        [PFUser logOut];
        [[PFUser currentUser] deleteInBackground]; //delete new user
        isNewAccount = NO; //reset BOOL
    } else {
        [PFUser logOut]; //logout user with conflicting email
    }
    
    NSString *alertTitle = @"Email matches existing account";
    NSString *alertMessage = @"The email on your facebook profile is associated with an existing account.  Please login and link your facebook account.";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    //Add OK action button
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSLog(@"OK action");
        self.emailField.text = email;
        [self.passwordField becomeFirstResponder];
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
