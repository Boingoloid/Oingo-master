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

-(void)addImagesToMenuList:objects{
    NSLog(@"objects before image add:%@",objects);
    for (PFObject *object in objects) {
        NSString *bioguideID = [object valueForKey:@"bioguideID"];
        
        // Look up index of current congressPerson in menuList
        NSUInteger index = [self.messageTableViewController.menuList indexOfObjectPassingTest:
                            ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                return [[dict valueForKey:@"bioguide_id"] isEqual:bioguideID];
                            }];
        
        if(index == NSNotFound){
            // Do nothing, load no photo
            NSLog(@"did nothing");
        } else {
            if([object objectForKey:@"imageFile"]) {
            
            //add image to menuList
            PFFile *theImage = [object objectForKey:@"imageFile"];
            NSData *imageData = [theImage getData];
            UIImage *image = [UIImage imageWithData:imageData];
            [[self.messageTableViewController.menuList objectAtIndex:index] setValue:image forKey:@"messageImageDownload"];
            // Load the photo only if file exists in project
            NSLog(@"check:%@",[self.messageTableViewController.menuList objectAtIndex:index]);
            } else {
            //Do nothing, leave image string as is so dummy icons will load
            }
        }
    }
    [self.messageTableViewController.view setNeedsDisplay];
    [self.messageTableViewController.tableView reloadData];
    NSLog(@"reloading data from Congress Photo Finder");
    
}


-(void) getPhotos:(NSArray*)congressMessageList {
    NSLog(@"CongressPhotoFinderAPI is being called");
    
    NSMutableArray *bioguideArray = [congressMessageList valueForKey:@"bioguide_id"];

    PFQuery *query = [PFQuery queryWithClassName:@"CongressImages"];
    [query whereKey:@"bioguideID" containedIn:bioguideArray];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {
            
            NSLog(@"results of congress query:%@",objects);
            dispatch_async(dispatch_get_main_queue(),^{
            
            [self addImagesToMenuList:objects];
            
            
            });
        }
    }];


    
    
//    for(NSMutableDictionary *congresspersonObject in congressMessageList){
//        
//        // Grab bioguideID
//        NSString *bioguideID = [[NSString alloc]init];
//        bioguideID = [congresspersonObject valueForKey:@"bioguide_id"];
//        
//
//        // Build imageString from the bioguideID
//        NSString *imageString =[[NSString alloc]init];
//        imageString = [NSString stringWithFormat:@"%@.jpg",bioguideID];
//    
//        // Look up index of current congressPerson in menuList
//        NSUInteger index = [self.messageTableViewController.menuList indexOfObjectPassingTest:
//                            ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
//                                return [[dict valueForKey:@"bioguide_id"] isEqual:bioguideID];
//                            }];
//        
//        if(index == NSNotFound){
//            // Do nothing, load no photos
//        } else {
//            
//            // Load the photo only if file exists in project
//            if([UIImage imageNamed:imageString]) {
//                [[self.messageTableViewController.menuList objectAtIndex:index] setValue:imageString forKey:@"messageImageString"];
//            } else {
//                //Do nothing, leave image string as is so dummy icons will load
//            }
//        }
//    }
//    
//    dispatch_async(dispatch_get_main_queue(),^{
//        [self.messageTableViewController.view setNeedsDisplay];
//        [self.messageTableViewController.tableView reloadData];
//        NSLog(@"reloading data from Congress Photo Finder");
//    });
//

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
