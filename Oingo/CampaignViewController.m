//
//  CampaignViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 4/26/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "CampaignViewController.h"
#import <Social/Social.h>
#import <Parse/Parse.h>
#import "PFTwitterUtils+NativeTwitter.h"
#import <Accounts/Accounts.h>
//#import "NTRTwitterClient.h"

@interface CampaignViewController () <UIActionSheetDelegate>


@end

@implementation CampaignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendTweet:(id)sender {
    NSLog(@"hi");
    PFUser *currentuser = [PFUser currentUser];
    NSLog(@"Current user: %@",currentuser.username);
    NSString *twitterScreenName = [PFTwitterUtils twitter].screenName;
    NSLog(@"%@",twitterScreenName);
    
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            return;
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in with Twitter!");
        } else {
            NSLog(@"User logged in with Twitter!");
            NSLog(@"%@",user.username);
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end

