//
//  CongressPhotoFinderAPI.m
//  Oingo
//
//  Created by Matthew Acalin on 6/24/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "CongressPhotoFinderAPI.h"
#import <UIKit/UIKit.h>

@interface CongressPhotoFinderAPI () <NSURLSessionDelegate>

@end

@implementation CongressPhotoFinderAPI


-(void) getPhotos:(NSArray*)congressMessageList {
    NSLog(@"CongressPhotoFinderAPI is being called");

    NSMutableArray *bioguideArray = [[NSMutableArray alloc]init];
    
    // Iterate through list and collect bioguideIDs in array
    for(NSMutableDictionary *congresspersonObject in congressMessageList){
        [bioguideArray addObject:[congresspersonObject valueForKey:@"bioguide_id"]];
        
        NSString *bioguideID = [[NSString alloc]init];
        bioguideID = [congresspersonObject valueForKey:@"bioguide_id"];
        NSString *imageString =[[NSString alloc]init];
        imageString = [NSString stringWithFormat:@"%@.jpg",bioguideID];
    
        // Look up index of current rep in menuList
        NSUInteger index = [self.messageTableViewController.menuList indexOfObjectPassingTest:
                            ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                return [[dict valueForKey:@"bioguide_id"] isEqual:bioguideID];
                            }];
        
        if(index == NSNotFound){
            // Do nothing
        } else {
            
            // Load the photo only if file exists in project
            if([UIImage imageNamed:imageString]) {
                [[self.messageTableViewController.menuList objectAtIndex:index] setValue:imageString forKey:@"messageImageString"];
            } else {
                //Do nothing, leave image string as is so dummy icons will load
            }
        }
    }
    
    [self.messageTableViewController.tableView reloadData];
    NSLog(@"reloading data from Congress Photo Finder");

    
}














// ***********************************
// Code below does not work.  Attempts
// to call API to get photos. Photos
// now saved locally in project so
// below request not needed.
// ***********************************
/*
-(void) getPhotos:(id)bioguideID {
    NSString *url = [NSString stringWithFormat:@"https://theunitedstates.io/images/congress/original/%@.jpg",bioguideID];
    NSLog(@"%@",url);
    
    //BIOF000062 "https://theunitedstates.io/images/congress/675x825/BIOF000062.jpg
    
    NSString *modeSetString = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *modeSet = [NSURL URLWithString:modeSetString];
    //configure the session
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders: @{@"Accept": @"application/json"}];
    sessionConfig.timeoutIntervalForRequest = 30.0;
    sessionConfig.timeoutIntervalForResource = 60.0;
    sessionConfig.HTTPMaximumConnectionsPerHost = 1;
    
    //create session with configuration
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                          delegate:self
                                                     delegateQueue:nil];
    
    //Use task to get congress photo
    NSURLSessionDownloadTask *downloadPhotoTask = [session downloadTaskWithURL:modeSet completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
        self.tableViewCell.messageImage.image = downloadedImage;
    }];
    [downloadPhotoTask resume];
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {

    
}
 */
@end
