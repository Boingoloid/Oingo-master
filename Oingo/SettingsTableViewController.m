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


@interface SettingsTableViewController () 

@end

@implementation SettingsTableViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    PFUser *currentUser = [PFUser currentUser];
    
    //Set twitter toggle to off
    [self.linkTwitterSwitch setOn:NO animated:NO];
    
    // Set facebook toggle to off
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

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

@end
