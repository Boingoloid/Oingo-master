//
//  TestViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 6/5/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "TestViewController.h"
#import <TwitterKit/TwitterKit.h>
#import <Parse/Parse.h>
#import <Fabric/Fabric.h>

@interface TestViewController ()
@property(nonatomic) UIView *tweetView;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    

    TWTRLogInButton* logInButton =  [TWTRLogInButton
                                     buttonWithLogInCompletion:
                                     ^(TWTRSession* session, NSError* error) {
                                         if (session) {
                                             NSLog(@"signed in as %@", [session userName]);
                                             [[[Twitter sharedInstance] APIClient] loadTweetWithID:@"20" completion:^(TWTRTweet *tweet, NSError *error) {
                                                 if (tweet) {
                                                     [self.tweetView configureWithTweet:tweet]
                                                 } else {
                                                     NSLog(@"Failed to load tweet: %@", [error localizedDescription]);
                                                 }
                                             }];

                                             
                                         } else {
                                             NSLog(@"error: %@", [error localizedDescription]);
                                         }
                                     }];
    logInButton.center = self.view.center;
    [self.view addSubview:logInButton];
    
    
    // Objective-C
    __weak typeof(self) weakSelf = self;
    
    [TwitterKit logInGuestWithCompletion:^(TWTRGuestSession *guestSession, NSError *error) {
        if (guestSession) {
            // Loading public Tweets do not require user auth
            [[[Twitter sharedInstance] APIClient] loadTweetWithID:@"20" completion:^(TWTRTweet *tweet, NSError *error) {
                if (tweet) {
                    [weakSelf.tweetView configureWithTweet:tweet]
                } else {
                    NSLog(@"Failed to load tweet: %@", [error localizedDescription]);
                }
            }];
        } else {
            NSLog(@"Unable to log in as guest: %@", [error localizedDescription]);
        }
    }];
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

@end
