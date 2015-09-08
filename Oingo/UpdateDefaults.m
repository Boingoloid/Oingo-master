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

-(void)updateLocationDefaultsFromUser {

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    PFUser *currentUser = [PFUser currentUser];
    
    if(currentUser){
        NSLog(@"updating defaults in with class from user!");
        if([currentUser valueForKey:@"latitude"] != nil && [currentUser valueForKey:@"longitude"] != nil) {
            //Coordinates exist so load to defaults
            [defaults setObject:[currentUser valueForKey:@"latitude"] forKey:@"latitude"];
            [defaults setObject:[currentUser valueForKey:@"longitude"] forKey:@"longitude"];
            [defaults synchronize];
            NSLog(@"loading lat/long from user to defaults, default latitude now:%@",[defaults valueForKey:@"latitude"]);
        }
        
        if ([currentUser valueForKey:@"zipCode"] != nil) {
            // zipCode exists so load to defaults
            [defaults setObject:[currentUser valueForKey:@"zipCode"] forKey:@"zipCode"];
            [defaults synchronize];
            NSLog(@"loading zipCode from user to defaults, default zipCode now:%@",[defaults valueForKey:@"zipCode"]);
        }
    }
}

-(void)saveZipCodeToDefaultsWithZip:zipCode{
    NSLog(@"inputs, zipCode:%@",zipCode);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:zipCode forKey:@"zipCode"];
    [defaults synchronize];
    
    //test
    NSLog(@"Save zipCode to defaults zipCode:%@",[defaults valueForKey:@"zipCode"]);
    
    
}

-(void)saveCoordinatesToDefaultsWithLatitude:(double)latitude andLongitude:(double)longitude {
    NSLog(@"inputs lat:%f long:%f",latitude,longitude);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    [defaults setObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    [defaults synchronize];
    
    //test
    NSLog(@"Save coordinates to defaults lat:%@ long:%@",[defaults valueForKey:@"latitude"],[defaults valueForKey:@"longitude"]);
}

-(void)saveLocationDefaultsToUser{
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if([defaults valueForKey:@"latitude"] != nil){
            [currentUser setValue:[defaults valueForKey:@"latitude"] forKey:@"latitude"];
        }
        if([defaults valueForKey:@"longitude"] != nil){
            [currentUser setObject:[defaults valueForKey:@"longitude"] forKey:@"longitude"];
        }
        if([defaults valueForKey:@"zipCode"] != nil){
            [currentUser setObject:[defaults valueForKey:@"zipCode"] forKey:@"zipCode"];
        }
        
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //save currentUser to parse disk
            if(error){
                NSLog(@"error updating from location Defaults to user!! - list:%@ %@ %@",[currentUser objectForKey:@"latitude"],[currentUser objectForKey:@"longitude"],[currentUser objectForKey:@"zipCode"]);
                
            }
            else {
                NSLog(@"saved location Defaults to user!! - list:%@ %@ %@",[currentUser objectForKey:@"latitude"],[currentUser objectForKey:@"longitude"],[currentUser objectForKey:@"zipCode"]);
            }
        }];
    }
}


-(void)saveMessageListWithCongressDefault:(NSArray*)messageList{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:messageList forKey:@"messageListWithCongress"];
    [defaults synchronize];
    
}

-(void)deleteMessageListFromCongressDefault{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"messageListWithCongress"];
    [defaults synchronize];
}

-(void)deleteCoordinates{
    // Delete from Defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"latitude"];
    [defaults removeObjectForKey:@"longitude"];
    [defaults synchronize];
    
    // Delete from currentUser if neccessary
    PFUser *currentUser = [PFUser currentUser];
    [currentUser removeObjectForKey:@"latitude"];
    [currentUser removeObjectForKey:@"longitude"];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //save currentUser to parse disk
        if(error){
        }
        else {
            NSLog(@"deleted coordinates in currentUser - list:%@ %@ %@",[currentUser objectForKey:@"latitude"],[currentUser objectForKey:@"longitude"],[currentUser objectForKey:@"zipCode"]);
        }
    }];
}

@end
