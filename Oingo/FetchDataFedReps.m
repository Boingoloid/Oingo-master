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

# pragma mark - Delegate Methohds

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    //gets the data, makes results array.
    NSError *error = nil;
    NSMutableDictionary *returnedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSArray *resultsArray = [returnedData valueForKey:@"results"];
    id countOfReps = [returnedData valueForKey:@"count"];
    NSLog(@"count of reps %@",countOfReps);
    

    dispatch_async(dispatch_get_main_queue(), ^{
        self.viewController.fedRepList = (NSMutableArray*)resultsArray;

        
        NSString *firstTwitterID = [[resultsArray firstObject] valueForKey:@"twitter_id"];
        NSString *initialTextViewText = self.viewController.pushthoughtTextView.text;
        
//        
//        NSString *newFullText = [NSString stringWithFormat:@"@%@, %@",firstTwitterID,initialTextViewText];
//        
//        NSMutableAttributedString *fullString = [[NSMutableAttributedString alloc] initWithString:newFullText];
//        
//        // Bold
//        [fullString addAttribute: NSFontAttributeName value: [[NSFont  ]: @"Helvetica-Bold"] range: NSMakeRange(0, 4)];
        
        
        
        // Insert twitterID of first Rep in Tweet
        self.viewController.pushthoughtTextView.text = [NSString stringWithFormat:@"%@ @%@",initialTextViewText,firstTwitterID];
        [self.viewController textViewDidChange:self.viewController.pushthoughtTextView];
        [self.viewController.collectionView reloadData];
            
            FetchFedRepPhoto *fetchPhoto = [[FetchFedRepPhoto alloc] init];
            fetchPhoto.viewController = self.viewController;
            [fetchPhoto fetchPhotos:resultsArray];
    });
}




@end
