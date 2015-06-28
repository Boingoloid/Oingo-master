//
//  CongressFinderAPI.m
//  Oingo
//
//  Created by Matthew Acalin on 6/20/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "CongressFinderAPI.h"
#import "CongressionalMessageItem.h"


@interface CongressFinderAPI () <NSURLSessionDelegate>
@property (nonatomic) NSString *userid;
@property (nonatomic) NSString *password;
@property(nonatomic) NSString *messageText;
@property(nonatomic) NSString *campaignID;

@end

@implementation CongressFinderAPI

NSString *sunlightLabsAPIKey = @"ed7f6bb54edc4577943dcc588664c89f";

-(void) getCongress:zipCode addToMessageList:(NSMutableArray*)messageList {
    //creates url and creates NSURLSession task
    self.messageList = messageList;
    //create url string
    NSString *baseURL = @"https://congress.api.sunlightfoundation.com";
    NSString *method = @"/legislators/locate?zip=";
    NSString *url = [NSString stringWithFormat:@"%@%@%@&apikey=%@", baseURL,method,zipCode,sunlightLabsAPIKey];
    NSLog(@"%@",url);
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
    //get congress data using url
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:modeSet];
    [dataTask resume];
    
    //completionHandler:^(NSData *data,NSURLResponse *response, NSError *error) {
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //
    //        NSLog(@"HERE!!!!!!!");
    //    });
}


-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    //gets the data, makes results array.
    NSError *error = nil;
    NSMutableDictionary *returnedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSArray *resultsArray = [returnedData valueForKey:@"results"];
    id countOfReps = [returnedData valueForKey:@"count"];
    //results array is 3 dictionaries
    NSLog(@"count of reps %@",countOfReps);
    self.messageListWithCongress = [self combine:resultsArray withMessageList:self.messageList];
    
    NSSortDescriptor *messageCategory = [[NSSortDescriptor alloc] initWithKey:@"messageCategory" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:messageCategory];
    NSArray *sortedArray = [self.messageListWithCongress sortedArrayUsingDescriptors:sortDescriptors];
    
    self.messageTableViewController.messageList = sortedArray;
    self.messageTableViewController.isRepsLoaded = YES;
    [self.messageTableViewController prepSections:self.messageTableViewController.messageList];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageTableViewController.tableView reloadData];
    });
}


-(NSMutableArray*)combine:(NSArray*)resultsArray withMessageList:(NSMutableArray*)messageList  {
    
    
    NSUInteger index = [messageList indexOfObjectPassingTest:
                       ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                           return [[dict objectForKey:@"messageCategory"] isEqual:@"Local Representative"];
                       }];
   
    //if no name, then dummy line, so store values and remove
    if(![[messageList objectAtIndex:index] valueForKey:@"targetName"]) {
        NSLog(@"dummy line being deleted");
        self.messageText = [[messageList objectAtIndex:index] valueForKey:@"messageText"];
        self.campaignID = [[messageList objectAtIndex:index] valueForKey:@"campaignID"];
        [messageList removeObjectAtIndex:index];
    } else {
        NSLog(@"no dummy to delete!");
    }
    
    NSMutableArray *congressMessageList = [NSMutableArray array];
    for(NSMutableDictionary *congresspersonObject in resultsArray){ //array of dictionaries
        //first dictionary, what to do with the 1st dictionary
        //pull out the values in message item
        CongressionalMessageItem *congressionalMessageItem = [[CongressionalMessageItem alloc] init];
        
        [congressionalMessageItem setValue:@"Local Representative" forKey:@"messageCategory"];
        [congressionalMessageItem setValue:[congresspersonObject valueForKey:@"bioguide_id"] forKey:@"bioguide_id"];
        [congressionalMessageItem setValue:self.campaignID forKey:@"campaignID"];
        [congressionalMessageItem setValue:self.messageText forKey:@"messageText"];
        
        // Name, full name, nickname, use nickname for firstname if available.
        if(![congresspersonObject valueForKey:@"nickName"]){
            [congressionalMessageItem setValue:[congresspersonObject valueForKey:@"first_name"] forKey:@"firstName"];
        } else {
            [congressionalMessageItem setValue:[congresspersonObject valueForKey:@"nickName"] forKey:@"firstName"];
        }
        [congressionalMessageItem setValue:[congresspersonObject valueForKey:@"last_name"] forKey:@"lastName"];
        congressionalMessageItem.fullName = [NSString stringWithFormat:@"%@ %@",congressionalMessageItem.firstName,congressionalMessageItem.lastName];
        
        //load dummy images
        [congressionalMessageItem setValue:[NSString stringWithFormat:@"%@.png",[congressionalMessageItem.lastName lowercaseString]] forKey:@"messageImageString"];
        NSLog(@"congress message item string image:%@", [congressionalMessageItem valueForKey:@"messageImageString"]);

        
        //Senator, CA District 12
        congressionalMessageItem.state = [congresspersonObject valueForKey:@"state"];
        
        if([[congresspersonObject valueForKey:@"chamber"] isEqualToString:@"senate"]) {
            congressionalMessageItem.chamber = @"Senator";
            congressionalMessageItem.title = [NSString stringWithFormat:@"%@, %@",congressionalMessageItem.chamber,congressionalMessageItem.state];
        } else {
            congressionalMessageItem.chamber = @"Representative";
            congressionalMessageItem.district = [congresspersonObject valueForKey:@"district"];
            congressionalMessageItem.title = [NSString stringWithFormat:@"%@, %@ district %@",congressionalMessageItem.chamber,congressionalMessageItem.state,congressionalMessageItem.district];
        }

        
        congressionalMessageItem.inOffice = [congresspersonObject valueForKey:@"in_office"];
        congressionalMessageItem.gender = [congresspersonObject valueForKey:@"gender"];
        congressionalMessageItem.birthday = [congresspersonObject valueForKey:@"birthday"];
        congressionalMessageItem.stateName = [congresspersonObject valueForKey:@"state_name"];
        congressionalMessageItem.leadershipRole = [congresspersonObject valueForKey:@"leadership_role"];
        
        //contact info
        congressionalMessageItem.phone = [congresspersonObject valueForKey:@"phone"];
        congressionalMessageItem.website = [congresspersonObject valueForKey:@"website"];
        congressionalMessageItem.openCongressEmail = [congresspersonObject valueForKey:@"oc_email"];
        congressionalMessageItem.youtubeID = [congresspersonObject valueForKey:@"youtube_id"];
        congressionalMessageItem.facebookID = [congresspersonObject valueForKey:@"facebook_id"];
        congressionalMessageItem.twitterID = [congresspersonObject valueForKey:@"twitter_id"];
        congressionalMessageItem.contactForm = [congresspersonObject valueForKey:@"contact_form"];

        
        //now I have message item with all the data.  add object to the array
        [congressMessageList addObject:congressionalMessageItem];
    }
    //now add the two arrays together.
    NSMutableArray *newMessageList = (NSMutableArray*)[messageList arrayByAddingObjectsFromArray:congressMessageList];
    return newMessageList;
}



@end
