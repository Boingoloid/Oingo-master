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
     NSLog(@"updating defaults in with class!");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    PFUser *currentUser = [PFUser currentUser];
    
    if(currentUser){
        if([currentUser valueForKey:@"latitude"] && [currentUser valueForKey:@"longitude"]) {
            [defaults setObject:[currentUser valueForKey:@"latitude"] forKey:@"latitude"];
            [defaults setObject:[currentUser valueForKey:@"longitude"] forKey:@"longitude"];
            [defaults synchronize];
            NSLog(@"user already has value for lat/long, verify default:%@",[defaults valueForKey:@"latitude"]);
        }
        
        if ([currentUser valueForKey:@"zipCode"]) {
            [defaults setObject:[currentUser valueForKey:@"zipCode"] forKey:@"zipCode"];
            [defaults synchronize];
            NSLog(@"user already has value for zip, verify default:%@",[defaults valueForKey:@"zipCode"]);
        }
    }

}
@end
