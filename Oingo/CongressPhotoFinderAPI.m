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
@end
