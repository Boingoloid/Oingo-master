//
//  FetchDataFedReps.m
//  Oingo
//
//  Created by Matthew Acalin on 12/18/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "FetchDataFedReps.h"
#import "FetchFedRepPhoto.h"

@interface FetchDataFedReps () <NSURLSessionDelegate>

@end

@implementation FetchDataFedReps

-(void)getCongressWithLatitude:(double)latitude andLongitude:(double)longitude {
    // Form URL from string
    NSString *baseURL = @"https://congress.api.sunlightfoundation.com";
    NSString *method =@"/legislators/locate?";
    NSString *sunlightLabsAPIKey = @"ed7f6bb54edc4577943dcc588664c89f";
    NSString *urlString = [NSString stringWithFormat:@"%@%@latitude=%%2B%f&longitude=%f&apikey=%@",baseURL,method,latitude,longitude,sunlightLabsAPIKey];
    NSString *urlEncodedString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlEncodedString];
    
    // Create NSURLSession with configuration
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders: @{@"Accept": @"application/json"}];
    sessionConfig.timeoutIntervalForRequest = 30.0;
    sessionConfig.timeoutIntervalForResource = 60.0;
    sessionConfig.HTTPMaximumConnectionsPerHost = 1;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                          delegate:self
                                                     delegateQueue:nil];
    //get congress data using url
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url];
    [dataTask resume];
    NSLog(@"url:%@",url);
}

-(void)fetchRepsWithZip:zipCode{


    // Form URL from string
    NSString *baseURL = @"https://congress.api.sunlightfoundation.com";
    NSString *method = @"/legislators/locate?zip=";
    NSString *sunlightLabsAPIKey = @"ed7f6bb54edc4577943dcc588664c89f";
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@&apikey=%@", baseURL,method,zipCode,sunlightLabsAPIKey];
    NSString *urlEncodedString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlEncodedString];
    
    // Create NSURLSession with configuration
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders: @{@"Accept": @"application/json"}];
    sessionConfig.timeoutIntervalForRequest = 30.0;
    sessionConfig.timeoutIntervalForResource = 60.0;
    sessionConfig.HTTPMaximumConnectionsPerHost = 1;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                          delegate:self
                                                     delegateQueue:nil];
    //get congress data using url
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url];
    [dataTask resume];
    NSLog(@"url:%@",url);
    
}

# pragma mark - CLLocationManagerDelegate Delegate Methohds

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location, Please Try Again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    //gets the data, makes results array.
    NSError *error = nil;
    NSMutableDictionary *returnedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSArray *resultsArray = [returnedData valueForKey:@"results"];
    int countOfReps = [[returnedData valueForKey:@"count"] intValue];
    NSLog(@"count of reps %d",countOfReps);
    if (countOfReps == 0){
        
        [UpdateDefaults deleteLocation];
        NSString *alertTitle = @"No Reps For That Location";
        NSString *alertMessage = [NSString stringWithFormat:@"We are having trouble getting reps for that location, please try again!"];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [self.viewController.navigationController popViewControllerAnimated:YES];
        }];
        [alertController addAction:OKAction];
        
        [self.viewController presentViewController:alertController animated:YES completion:nil];

    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.viewController.fedRepList = (NSMutableArray*)resultsArray;
            self.viewController.collectionData = (NSMutableArray*)resultsArray;
            
            // Insert twitterID of first Rep in Tweet
            NSString *firstTwitterID = [[resultsArray firstObject] valueForKey:@"twitter_id"];
            NSString *initialTextViewText = self.viewController.pushthoughtTextView.text;
            self.viewController.pushthoughtTextView.text = [NSString stringWithFormat:@"%@ @%@",initialTextViewText,firstTwitterID];
            [self.viewController textViewDidChange:self.viewController.pushthoughtTextView];
            [self.viewController.collectionView reloadData];
            
            FetchFedRepPhoto *fetchPhoto = [[FetchFedRepPhoto alloc] init];
            fetchPhoto.viewController = self.viewController;
            [fetchPhoto fetchPhotos:resultsArray];
        });
    }
}

@end
