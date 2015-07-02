//
//  SessionDefaults.m
//  Oingo
//
//  Created by Matthew Acalin on 7/1/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "SessionDefaults.h"
#import <Parse/Parse.h>

@implementation SessionDefaults

//+(void)loadLocationDefaultsFromUser:current{
//    
//    // load current user and save it to the defaults, then sync
//    PFUser *currentUser = [PFUser currentUser];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if([currentUser valueForKey:@"locationLatitude"] && [currentUser valueForKey:@"locationLongitude"]) {
//       [defaults setObject:[currentUser valueForKey:@"locationLatitude"] forKey:@"latitude"];
//       [defaults setObject:[currentUser valueForKey:@"locationLongitude"] forKey:@"longitude"];
//       [defaults synchronize];
//       NSLog(@"user already has value for location");
//   }
//}

-(void) loadLocationDefaults:(NSUserDefaults*)defaults fromUser:(PFUser*)currentUser{
    if([currentUser valueForKey:@"locationLatitude"] && [currentUser valueForKey:@"locationLongitude"]) {
        [defaults setObject:[currentUser valueForKey:@"locationLatitude"] forKey:@"latitude"];
        [defaults setObject:[currentUser valueForKey:@"locationLongitude"] forKey:@"longitude"];
        [defaults synchronize];
        NSLog(@"user already has value for location");
    }
    
    if ([currentUser valueForKey:@"zipCode"]) {
        [defaults setObject:[currentUser valueForKey:@"zipCode"] forKey:@"zipCode"];
        [defaults synchronize];
        NSLog(@"user already has value for zip");
    }
}

//-(void)loadLocationDefaults:(NSUserDefaults*)defaults {
//    // Now check user defaults to see if zip or location in cache
//    if([defaults valueForKey:@"latitude"] && [defaults valueForKey:@"longitude"]){
//        NSLog(@"not user, but has location in defaults%@",self.messageTableViewController.location);
//    }
//    if([defaults stringForKey:@"zipCode"]){
//        self.messageTableViewController.zipCode= [defaults stringForKey:@"zipCode"];
//        NSLog(@"not user, but has zipcode in defaults");
//    }
//}

@end
