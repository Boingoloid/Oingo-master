//
//  TweetTableViewDemoTableViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 6/6/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//


//#import <TwitterKit/TwitterKit.h>
#import "TweetTableViewDemoTableViewController.h"
//#import <Accounts/Accounts.h>
//#import <Social/Social.h>
#import <Parse/Parse.h>



static NSString * const TweetTableReuseIdentifier = @"tweetCell";

@interface TweetTableViewDemoTableViewController () //<TWTRTweetViewDelegate>
@property (nonatomic, strong) NSArray *tweets; // Hold all the loaded tweets

@end

@implementation TweetTableViewDemoTableViewController

NSString *tweetID = @"606879860234035200";


- (void)viewDidLoad {
    [super viewDidLoad];
//    [[[Twitter sharedInstance] APIClient] loadTweetWithID:tweetID completion:^(TWTRTweet *tweetFeed, NSError *error) {
//        if (tweetFeed) { //if we have tweets to display, we create a TweetView
//            TWTRTweetView *feedView = [[TWTRTweetView alloc] initWithTweet:tweetFeed];
//            //add the view to your hierarchy
//            [self.view addSubview:feedView];
//        } else {
//            NSLog(@"Failure to load tweet because: %@",[error localizedDescription]);
//        }
//    }];
}

# pragma mark - UITableViewDelegate Methods

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return [self.tweets count];
//}
//
//- (TWTRTweetTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    TWTRTweet *tweet = self.tweets[indexPath.row];
//    TWTRTweetTableViewCell *cell = (TWTRTweetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"tweetCell" forIndexPath:indexPath];
//    [cell configureWithTweet:tweet];
//    cell.tweetView.delegate = self;
//    
//    return cell;
//
//
//}

// Calculate the height of each row
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    TWTRTweet *tweet = self.tweets[indexPath.row];
//    
//    return [TWTRTweetTableViewCell heightForTweet:tweet width:CGRectGetWidth(self.view.bounds)];
//}

@end