//
//  FetchFedRepPhoto.m
//  Oingo
//
//  Created by Matthew Acalin on 12/21/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "FetchFedRepPhoto.h"

@implementation FetchFedRepPhoto

-(void)fetchPhotos:(NSArray *)resultsArray{
    

    NSLog(@"FetchFedRepPhotoFinder is being called");

    NSMutableArray *bioguideArray = [resultsArray valueForKey:@"bioguide_id"];

    PFQuery *query = [PFQuery queryWithClassName:@"CongressImages"];
    [query whereKey:@"bioguideID" containedIn:bioguideArray];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {
            
            
            dispatch_async(dispatch_get_main_queue(),^{
                
                [self addImages:objects ToArray:resultsArray];
                [self.viewController.collectionView setNeedsDisplay];
                [self.viewController.collectionView reloadData];
            });
        }
    }];
}


-(void)addImages:objects ToArray:resultsArray{
    
    for (PFObject *object in objects) {
        NSString *bioguideID = [object valueForKey:@"bioguideID"];
        
        // Look up index of current congressPerson in menuList
        NSUInteger index = [resultsArray indexOfObjectPassingTest:
                            ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                                return [[dict valueForKey:@"bioguide_id"] isEqual:bioguideID];
                            }];
        
        if(index == NSNotFound){
            // Do nothing, load no photo
            NSLog(@"did nothing");
        } else {
            if([object objectForKey:@"imageFile"]) {
                
                //add image to FedRepList
                PFFile *theImage = [object objectForKey:@"imageFile"];
                NSData *imageData = [theImage getData];
                UIImage *image = [UIImage imageWithData:imageData];
                [[resultsArray objectAtIndex:index] setValue:image forKey:@"image"];
                // Load the photo only if file exists in project
                //NSLog(@"check:%@",[resultsArray objectAtIndex:index]);
            } else {
                //Do nothing, leave image string as is so dummy icons will load
            }
        }
    }
    self.viewController.fedRepList = resultsArray;
    self.viewController.collectionData = resultsArray;

    
    NSLog(@"reloading data from Congress Photo Finder");
}

@end
