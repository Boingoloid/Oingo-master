//
//  LocationFinderAPI.m
//  Oingo
//
//  Created by Matthew Acalin on 7/2/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "LocationFinderAPI.h"

#import <Parse/Parse.h>
#import "MessageItem.h"
#import "CongressionalMessageItem.h"
#import "CongressFinderAPI.h"
#import "ParseAPI.h"

@interface LocationFinderAPI () <CLLocationManagerDelegate>
@property(nonatomic) CLLocationManager *cLLocationManager;
@property(nonatomic) UILabel *longitudeLabel;
@property(nonatomic) UILabel *latitudeLabel;
@end


@implementation LocationFinderAPI

static CLLocationManager *locationManager;

-(void) findUserLocation {
    self.cLLocationManager = locationManager;
    NSLog(@"find user location going");
    self.cLLocationManager = [[CLLocationManager alloc] init];
    self.cLLocationManager.delegate = self;
    
    //check for permissions, either "when in user" or "always" and it's good to move on.
    NSUInteger code = [CLLocationManager authorizationStatus];
    NSLog(@"%lu",(unsigned long)code);
    if (code == kCLAuthorizationStatusNotDetermined && ([self.cLLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.cLLocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
        
        if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]){
            [self.cLLocationManager requestWhenInUseAuthorization];
        } else {
            NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
        }
    }
    [self.cLLocationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}



- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self.cLLocationManager stopUpdatingLocation];
    
    //Set the location default
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude] forKey:@"latitude"];
    [defaults setObject:[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude] forKey:@"longitude"];
    [defaults synchronize];
    NSLog(@"UPDATING DEFAULTS!!%@,%@",[defaults valueForKey:@"latitude"],[defaults valueForKey:@"longitude"]);
    
    //if currently a user then save location info to account.
    if([PFUser currentUser]) {
        NSString *latitudeString = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
        NSString *longitudeString =[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
        [[PFUser currentUser] setValue:latitudeString forKey:@"locationLatitude"];
        [[PFUser currentUser] setValue:longitudeString forKey:@"locationLongitude"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error) {
                NSLog(@"error UPDATING COORDINATES!!");
            } else{
                NSLog(@"UPDATING COORDINATES!!");
            }
        }];
    }
    
    ParseAPI *parseAPI = [[ParseAPI alloc]init];
    parseAPI.MessageTableViewController = self.messageTableViewController;
    CongressFinderAPI *congressFinder = [[CongressFinderAPI alloc]init];
    congressFinder.messageTableViewController = self.messageTableViewController;
    congressFinder.parseAPI = parseAPI;
    [congressFinder getCongressWithLatitude:newLocation.coordinate.latitude andLongitude:newLocation.coordinate.longitude addToMessageList:(NSMutableArray*)self.messageTableViewController.messageList];
    
}



@end
