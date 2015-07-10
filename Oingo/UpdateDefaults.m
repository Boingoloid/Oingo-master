//
//  UpdateDefaults.m
//  Oingo
//
//  Created by Matthew Acalin on 7/9/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "UpdateDefaults.h"
#import <Parse/Parse.h>

@implementation UpdateDefaults

-(void)updateLocationDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    PFUser *currentUser = [PFUser currentUser];

    // If a registered user then set default zip and location if available
    //? do I need to check if a sessionDefaults object already exists?
    if(currentUser){
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
    NSLog(@"updating defaults!");
}
@end
