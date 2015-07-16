//
//  CongressFinderAPI.m
//  Oingo
//
//  Created by Matthew Acalin on 6/20/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "CongressFinderAPI.h"
#import "CongressionalMessageItem.h"
#import "ParseAPI.h"


@interface CongressFinderAPI () <NSURLSessionDelegate>
@property(nonatomic) NSString *messageText;
@property(nonatomic) NSString *segmentID;
@end

@implementation CongressFinderAPI



-(void) getCongress:zipCode addToMessageList:(NSMutableArray*)messageList {
    // Method called when finding representatives by zipCode

    self.messageList = messageList;
    
    NSString *sunlightLabsAPIKey = @"ed7f6bb54edc4577943dcc588664c89f";
    NSString *baseURL = @"https://congress.api.sunlightfoundation.com";
    NSString *method = @"/legislators/locate?zip=";
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@&apikey=%@", baseURL,method,zipCode,sunlightLabsAPIKey];
    [self getCongressData:urlString];
    
}
    // Method called when finding representatives by Lat/Long
-(void)getCongressWithLatitude:(double)latitude andLongitude:(double)longitude addToMessageList:(NSMutableArray*)messageList {
    
    
    NSUInteger index = [messageList indexOfObjectPassingTest:
                        ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                            return [[dict objectForKey:@"isGetLocationCell"] isEqual:@YES];
                        }];
    if(index == NSNotFound){
        NSLog(@"did not find line");

    } else {
        NSLog(@"did find line and deleted it");
        [messageList removeObjectAtIndex:index];
    }
    
    self.messageList = messageList;
    
    
    
    NSLog(@"message list in get congress with location%@",self.messageList);
    NSString *sunlightLabsAPIKey = @"ed7f6bb54edc4577943dcc588664c89f";
    NSString *baseURL = @"https://congress.api.sunlightfoundation.com";
    NSString *method =@"/legislators/locate?";
    NSString *urlString = [NSString stringWithFormat:@"%@%@latitude=%%2B%f&longitude=%f&apikey=%@",baseURL,method,latitude,longitude,sunlightLabsAPIKey];
    [self getCongressData:urlString];
}

-(void)getCongressData:(NSString*)urlString {
    
    NSString *urlEncodedString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlEncodedString];
    
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
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url];
    [dataTask resume];
    
    NSLog(@"session created");
    NSLog(@"url:%@",url);
}


-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    //gets the data, makes results array.
    NSError *error = nil;
    NSMutableDictionary *returnedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSArray *resultsArray = [returnedData valueForKey:@"results"];
    id countOfReps = [returnedData valueForKey:@"count"];
    NSLog(@"count of reps %@",countOfReps);
    
    
    //combine the lists: add congress people to the message list
    self.messageListWithCongress = [self combine:resultsArray withMessageList:self.messageList];
    

    self.messageTableViewController.isRepsLoaded = YES;
    

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.parseAPI prepSections:self.messageListWithCongress];
    });
}


-(NSMutableArray*)combine:(NSArray*)resultsArray withMessageList:(NSMutableArray*)messageList  {
    
    
//    NSUInteger index = [messageList indexOfObjectPassingTest:
//                       ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
//                           return [[dict objectForKey:@"messageCategory"] isEqual:@"Local Representative"];
//                       }];
//    
//    self.messageTableViewController.repMessageText = [[messageList objectAtIndex:index] valueForKey:@"messageText"];
//    NSLog(@"message list before delete%@",messageList);
//   
//    //if no name, then dummy line, so store values and remove
//    if(![[messageList objectAtIndex:index] valueForKey:@"targetName"]) {
//        NSLog(@"dummy line being deleted");
//        self.messageText = [[messageList objectAtIndex:index] valueForKey:@"messageText"];
//        self.segmentID = [[messageList objectAtIndex:index] valueForKey:@"segmentID"];
//        [messageList removeObjectAtIndex:index];
//    } else {
//        NSLog(@"no dummy to delete!");
//    }
    
    NSMutableArray *congressMessageList = [NSMutableArray array];
    
    //for every congressperson in the results array
    for(NSMutableDictionary *congresspersonObject in resultsArray){ //array of dictionaries
        //first dictionary, what to do with the 1st dictionary
        //pull out the values in message item
        CongressionalMessageItem *congressionalMessageItem = [[CongressionalMessageItem alloc] init];
        
        [congressionalMessageItem setValue:@"Local Representative" forKey:@"messageCategory"];
        [congressionalMessageItem setValue:[congresspersonObject valueForKey:@"bioguide_id"] forKey:@"bioguide_id"];
        [congressionalMessageItem setValue:self.segmentID forKey:@"segmentID"];
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

        congressionalMessageItem.isGetLocationCell = 0;
        congressionalMessageItem.isMessage = 0;

        
        //now I have message item with all the data.  add object to the array
        [congressMessageList addObject:congressionalMessageItem];
    }
    //now add the two arrays together.
    NSMutableArray *newMessageList = (NSMutableArray*)[messageList arrayByAddingObjectsFromArray:congressMessageList];
    return newMessageList;
}



@end
