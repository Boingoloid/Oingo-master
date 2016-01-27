//
//  FederalRepActionDashboardViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 12/17/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "FederalRepActionDashboardViewController.h"
#import "FedRepPhoneTableViewController.h"
#import "FedRepCell.h"
#import "FedRepCollectionCell.h"
#import "FetchDataFedReps.h"
#import <TwitterKit/TwitterKit.h>
#import "UpdateDefaults.h"
#import "EmailViewController.h"


@interface FederalRepActionDashboardViewController () <UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, NSURLSessionDelegate>

@end

@implementation FederalRepActionDashboardViewController

static NSString * const reuseIdentifier = @"Cell";

-(void)viewWillAppear{
    self.segmentedControlCommunicationType.selectedSegmentIndex = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"FedrepAction Firing");
    NSString *category = [self.selectedActionDict valueForKey:@"messageCategory"];
    
    // Load Reps OR Contacts, depends on category
    if([category isEqualToString:@"Local Representative"]){
        // Fetch Federal Rep data, try Coordinates first, then Zip
        FetchDataFedReps *fetchDataFedReps = [[FetchDataFedReps alloc]init];
        fetchDataFedReps.viewController = self;
        if([UpdateDefaults isLocationInDefaults]){
            if([UpdateDefaults isCoordinatesInDefaults]){
                double latitude = [[UpdateDefaults getLatitudeFromDefaults] doubleValue];
                double longitude = [[UpdateDefaults getLongitudeFromDefaults] doubleValue];
                [fetchDataFedReps getCongressWithLatitude:latitude andLongitude:longitude];
                NSLog(@"Fetching Reps by coordinates, lat/long:%f | %f",latitude,longitude);
            } else {
                [fetchDataFedReps fetchRepsWithZip:[UpdateDefaults getZipFromDefaults]];
                NSLog(@"Fetching Reps by Zip, zip:%@",[UpdateDefaults getZipFromDefaults]);
            }
            
        } else {
            NSLog(@"location info shoudld area be there before this page, error");
        }
    } else {
        // Filter contacts list for the selectedAction
        NSMutableArray *contactsForAction = [[NSMutableArray alloc]init];
        for (NSDictionary *dict in self.contacts){
            NSString *dictCategory = [dict valueForKey:@"messageCategory"];
            if([category isEqualToString:dictCategory]){
                [contactsForAction addObject:dict];
            }
        }
        self.contactsForAction = contactsForAction;
        self.collectionData = contactsForAction;
        
        
        // Insert twitterID of first Rep in Tweet
//        NSString *firstTwitterID = [[self.collectionData firstObject] valueForKey:@"twitterID"];
//        NSString *initialTextViewText = self.pushthoughtTextView.text;
//        self.pushthoughtTextView.text = [NSString stringWithFormat:@"%@ @%@",initialTextViewText,firstTwitterID];
//        [self textViewDidChange:self.pushthoughtTextView];
//        [self.collectionView reloadData];
        
        //NSLog(@"contactsForAction:%@",self.contactsForAction);
    }
    
    // Fetch hashtag data - async
    [self getHashtagData];
    
    // Set TextView Delegate
    self.pushthoughtTextView.delegate = self;
    
    // Set Delegates / DataSource
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Set CollectionView delegate and Flow layout
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.collectionView setContentInset:UIEdgeInsetsMake(-20, 5, -20, 0)];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    flowLayout.minimumInteritemSpacing = 3;
    flowLayout.minimumLineSpacing = 3;
    [flowLayout setHeaderReferenceSize:CGSizeMake(0, 50)];
    [flowLayout setFooterReferenceSize:CGSizeMake(0, 100)];
    self.collectionView.collectionViewLayout = flowLayout;
    self.collectionView.allowsSelection = YES;
    self.collectionView.allowsMultipleSelection = YES;
    
    // Format Breadcrumb label
    self.breadcrumbsLabel.text = [NSString stringWithFormat:@"/ %@ / %@",[self.selectedProgram valueForKey:@"programTitle"],[self.selectedSegment valueForKey:@"segmentTitle"]];
    
    // Format Push Thought suggestion
    self.pushthoughtTextView.text = [self.selectedActionDict valueForKey:@"messageText"];
    self.pushthoughtTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.pushthoughtTextView.layer.borderWidth = 0.0;
    self.pushthoughtTextView.layer.cornerRadius = 3;
    self.pushthoughtTextView.clipsToBounds = YES;
    
    // Format textView Container
    self.textViewContainer.layer.borderColor = [[UIColor grayColor] CGColor];
    self.textViewContainer.layer.borderWidth = 0.5;
    self.textViewContainer.layer.cornerRadius = 3;
    self.textViewContainer.clipsToBounds = YES;
    
    // Format Button Container
    self.buttonContainerImageView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.buttonContainerImageView.layer.borderWidth = 0.5;
    self.buttonContainerImageView.layer.cornerRadius = 3;
    self.buttonContainerImageView.clipsToBounds = YES;
    
    // Format Send Tweet Touch Area
    self.sendTweet.layer.borderColor = [[UIColor colorWithRed:13/255.0 green:81/255.0 blue:183/255.0 alpha:1] CGColor];
    self.sendTweet.layer.borderWidth = 0;
    self.sendTweet.layer.cornerRadius = 3;
    self.sendTweet.clipsToBounds = YES;

    // Format Custom Text View
    self.textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.textView.layer.borderWidth = .5;
    self.textView.layer.cornerRadius = 15;
    self.textView.clipsToBounds = YES;
    
    
    // Format Expanded Options Label
    self.otherOptionsLabel.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.otherOptionsLabel.layer.borderWidth = 0;
    self.otherOptionsLabel.layer.cornerRadius = 0;
    self.otherOptionsLabel.clipsToBounds = YES;
    // Do any additional setup after loading the view.
    
    
    // Format TableView
    self.tableView.estimatedRowHeight = 150.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.layer.borderColor = [[UIColor colorWithRed:13/255.0 green:81/255.0 blue:183/255.0 alpha:1] CGColor];
    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.cornerRadius = 3;
    self.tableView.clipsToBounds = YES;
    
    // Set link Checkbox State
    self.linkState = 0;

    // Format Sent Message Data -----------------------------------------------------------------------------------
    NSArray *filteredActionList;
    
    //COULD JUST PUT THE CATEGORY BELOW IN THE PREDICATE, THEN IT WOULD FILTER ON WHATEVER
    filteredActionList = [self.sentActionsForSegment filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"actionCategory = %@", category]];
    // NSLog(@"printing array count:%lu  value:%@",(unsigned long)filteredActionList.count,filteredActionList);
    
    
    NSArray *filteredSentActionList;
    filteredSentActionList = [self.sentActionsForSegment filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"actionCategory = %@", category]];

    // strip hidden and count
    int count = 0;
    NSMutableArray *filteredSentActionsHiddenRemoved = [[NSMutableArray alloc]init];
    for(NSDictionary *dict in filteredSentActionList){
        if([[dict valueForKey:@"isHidden"] boolValue]){
            count++;
        } else{
            [filteredSentActionsHiddenRemoved addObject:dict];
            count++;
        }
    }
    
    //apply count to
    self.tableViewTitleLabel.text = [NSString stringWithFormat:@"Recent Tweets: %d", count];
    
    //NSLog(@"printing sent array count:%lu  value:%@",(unsigned long)filteredSentActionList.count,filteredSentActionList);
    
    self.filteredActionsForSegment = (NSMutableArray*)filteredActionList;
    self.filteredSentActionsForSegment = (NSMutableArray*)filteredSentActionsHiddenRemoved;
    
//    // Adjust for default count
//    NSString *defaultMessage =[[self.filteredActionsForSegment objectAtIndex:0] valueForKey:@"messageText"];
//    NSMutableDictionary *defaultMessageDictionary = [[NSMutableDictionary alloc]initWithObjectsAndKeys:defaultMessage, @"messageText", 0, @"messageCount", nil];
//    
//    NSMutableArray *messageArray= [[NSMutableArray alloc]init];
//    
//    for(NSDictionary *sentMessageDict in self.filteredSentActionsForSegment){
//        if([sentMessageDict valueForKey:@"isDefaultMessage"]){
//            int newCount = [[defaultMessageDictionary valueForKey:@"messageCount"]intValue] +1;
//            [defaultMessageDictionary setObject:[NSNumber numberWithInt:newCount] forKey:@"messageCount"];
//        } else {
//            [sentMessageDict setValue:[NSNumber numberWithInt:0] forKey:@"messageCount"];
//            [messageArray addObject:(NSDictionary*)sentMessageDict];
//        }
//    }
//    
//    NSMutableArray *tableDataArray = [[NSMutableArray alloc]init];
//    [tableDataArray addObject:defaultMessageDictionary];
//    [tableDataArray addObjectsFromArray:messageArray];
//    NSLog(@"message Array:%@",messageArray);
//    self.filteredSentActionsForSegmentWithCount = tableDataArray;
    
    // Set self.tableData default to sent messages
//    self.tableData = self.filteredSentActionsForSegmentWithCount;
    self.tableData = self.filteredSentActionsForSegment;  //REMOVE THIS LINE when you reinitialize count above
    
    [self.tableView reloadData];
    
    //----------------------------------------------------------------------------------------------------------------
    
    // Create gesture recognizer
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture:)]; //connect recognizer to action method.
    tapRecognizer.delegate = self;
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [tapRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapRecognizer];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentedControlCummunicationTypeClick:(id)sender {
    
    if([[self.collectionData firstObject] valueForKey:@"bioguide_id"]){
        
        if(self.segmentedControlCommunicationType.selectedSegmentIndex == 0){
            // do nothing
        } else if(self.segmentedControlCommunicationType.selectedSegmentIndex == 1) {
            self.segmentedControlCommunicationType.selectedSegmentIndex = 0;
            [self performSegueWithIdentifier:@"showFedRepPhone" sender:self];
        } else {
            self.segmentedControlCommunicationType.selectedSegmentIndex = 0;
            EmailViewController *emailVC = [[EmailViewController alloc]init];
            emailVC.selectedSegment = (NSMutableDictionary*)self.selectedSegment;
            emailVC.selectedProgram = (NSMutableDictionary*)self.selectedProgram;
            emailVC.selectedAction = self.selectedActionDict;
            emailVC.fedRepList = self.fedRepList;
            
            [self.navigationController pushViewController:emailVC animated:YES];
            //[self presentViewController:emailVC animated:YES completion:nil];
        }
    }else {
        if(self.segmentedControlCommunicationType.selectedSegmentIndex == 0){
            // do nothing
        } else if(self.segmentedControlCommunicationType.selectedSegmentIndex == 1) {
            [self performSegueWithIdentifier:@"showFedRepPhone" sender:self];
            self.segmentedControlCommunicationType.selectedSegmentIndex = 0;
        } else {
            [self performSegueWithIdentifier:@"showFedRepPhone" sender:self];
            self.segmentedControlCommunicationType.selectedSegmentIndex = 0;
        }
    }
}

-(void) getHashtagData{
    
    //**************  This should  be moved to Cloud Code at some point.  Pointless to do all this work as the UI is loading when I just need the grouped/summed table
    //get message data for segment menu
    NSString *selectedSegmentID = [self.selectedSegment valueForKey:@"objectId"];
    PFQuery *queryHashtags = [PFQuery queryWithClassName:@"Hashtags"];
    [queryHashtags whereKey:@"segmentObjectId" equalTo:selectedSegmentID];
    [queryHashtags orderByAscending:@"hashtag"];
    [queryHashtags findObjectsInBackgroundWithBlock:^(NSArray *objectsHash, NSError *error) {
        if (!error) {
            
            NSString *hashtag = @"";
            NSMutableArray *hashtagGroupedArray = [[NSMutableArray alloc]init];
            
            for(NSDictionary *hashtagDict in objectsHash){
                //NSLog(@"hashtag:%@",hashtag);
                //NSLog(@"hashtagDict hashtag:%@",[[hashtagDict valueForKey:@"hashtag"] lowercaseString]);
                
                if([hashtag caseInsensitiveCompare:[hashtagDict valueForKey:@"hashtag"]]){
                    //NSLog(@"different"); //add new item to list
                    hashtag = [hashtagDict valueForKey:@"hashtag"];
                    int frequency = [[hashtagDict valueForKey:@"frequency"]intValue];
                    //NSLog(@"frequency from parse %d",frequency);
                    NSMutableDictionary *hashtagInsertDictionary = [[NSMutableDictionary alloc]init];
                    [hashtagInsertDictionary setValue:hashtag forKey:@"hashtag"];
                    [hashtagInsertDictionary setValue:[NSNumber numberWithInt:frequency] forKey:@"frequency"];
                    [hashtagGroupedArray addObject:hashtagInsertDictionary];
                    
                } else {
                    //NSLog(@"same, increment 1"); //no add, just increment 1
                    
                    int frequency = [[[hashtagGroupedArray lastObject] valueForKey:@"frequency"] intValue] + 1;
                    //NSLog(@"frequency from array value %d",frequency);
                    [[hashtagGroupedArray lastObject] setValue:[NSNumber numberWithInt:frequency] forKey:@"frequency"];
                }
            }
            //NSLog(@"hashtagGroupedArray:%@",hashtagGroupedArray);
            NSSortDescriptor *frequncySortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"frequency" ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:frequncySortDescriptor, nil];
            NSArray *hashtagSortedArray = [hashtagGroupedArray sortedArrayUsingDescriptors:sortDescriptors];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.hashtagList = (NSMutableArray*)hashtagSortedArray;
                //NSLog(@"reloading data from hashtag func: %@",[self.sentMessagesForSegment firstObject]);
                [self.tableView reloadData];
            });
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    //*****************
    
}

#pragma mark - Table view data source


- (IBAction)segmentedControlTableViewClick:(id)sender {
    if(self.segmentedControlTableView.selectedSegmentIndex == 0){
        self.tableData = (NSMutableArray*)self.filteredSentActionsForSegment;
    } else {
        self.tableData = (NSMutableArray*)self.hashtagList;
    }
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Create cell
    FedRepCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FedRepCell" forIndexPath:indexPath];
    cell.viewController = self;
    [self.tableView addSubview:cell];
    
    
    // Configure the cell...
    NSMutableDictionary *dictionary = [self.tableData objectAtIndex:indexPath.row];

    
    [cell layoutIfNeeded];
    return [cell configCell:(NSMutableDictionary*)dictionary];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    FedRepCell *cell = (FedRepCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if(self.segmentedControlTableView.selectedSegmentIndex == 0){
        self.pushthoughtTextView.text = cell.tableViewPrimaryLabel.text;
    } else {
        [self.pushthoughtTextView replaceRange:self.pushthoughtTextView.selectedTextRange withText:[NSString stringWithFormat:@" %@",cell.tableViewPrimaryLabel.text]];
    }
    [self textViewDidChange:self.pushthoughtTextView];
}




//- (void)textViewDidBeginEditing:(UITextView *)textView
//{
//    self.placeholderTextLabel.hidden = YES;
//}

//- (void)textViewDidChange:(UITextView *)textView
//{
//    self.placeholderTextLabel.hidden = ([textView.text length] > 0);
//}

//- (void)textViewDidEndEditing:(UITextView *)textView
//{
//    self.placeholderTextLabel.hidden = ([textView.text length] > 0);
//}

#pragma mark - TextView Delegate
- (void)textViewDidChange:(UITextView *)textView{
    if(textView == self.pushthoughtTextView){
        NSString *string = self.pushthoughtTextView.text;
        int count = 0;

        for (NSDictionary *dictionary in self.fedRepList){
            NSString *tweetAddress = [NSString stringWithFormat:@"@%@",[dictionary valueForKey:@"twitter_id"]];
            
            if ([string rangeOfString:tweetAddress options:NSCaseInsensitiveSearch].location == NSNotFound) {
                //NSLog(@"string does not contain address for:%@",tweetAddress);
                [[self.fedRepList objectAtIndex:count] setObject:@NO forKey:@"isSelected"];
                count = count + 1;
            } else {
                //NSLog(@"string contains address:%@",tweetAddress);
                [[self.fedRepList objectAtIndex:count] setObject:@YES forKey:@"isSelected"];
                count = count +1;
            }
            //NSLog(@"fedreplist:%@",self.fedRepList);
            [self.collectionView reloadData];
        }
        
        if(self.linkState == 1){
            NSInteger lengthNumber = [self.pushthoughtTextView.text length];
            NSInteger countNumber =(int)140-47-lengthNumber;
            self.characterCount.text = [NSString stringWithFormat:@"%ld",(long)countNumber];

        } else {
            NSInteger lengthNumber = [self.pushthoughtTextView.text length];
            NSInteger countNumber =(int)140-lengthNumber;
            self.characterCount.text = [NSString stringWithFormat:@"%ld",(long)countNumber];
        }
    }
    
}



#pragma mark - User Login Twitter
-(void) logIn{
    NSLog(@"login called");

    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            return;
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in with Twitter!");
            [UpdateDefaults saveLocationDefaultsToUser];
            [self sendTweetwithComposer];
        } else {
            NSLog(@"User logged in with Twitter!");
            [UpdateDefaults updateLocationDefaultsFromUser];
            [self sendTweetwithComposer];
        }
    }];
}

#pragma mark - Tweeting, Send and Save
-(void)sendTweetwithComposer{
    NSLog(@"tweet sent");
    
    NSString *tweetText = [NSString stringWithFormat:@"%@", self.pushthoughtTextView.text];
    NSURL *tweetURL = [NSURL URLWithString:[self.selectedSegment valueForKey:@"linkToContent"]];
    PFFile *theImage = [self.selectedSegment valueForKey:@"segmentImage"];
    NSData *imageData = [theImage getData];
    UIImage *image = [UIImage imageWithData:imageData];
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    
    [composer setText:tweetText];

    if (self.linkState == 1){
        [composer setURL:tweetURL];
        [composer setImage:image];
    }
    
    [composer showFromViewController:self completion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Tweet composition cancelled");
        } else {
            NSLog(@"Tweet is sent:%ld",(long)result);
            [self showTweetDisclosureAlert];
            //Need to save tweet result ID in callBack
        }
    }];
    
//    https://api.twitter.com/1.1/statuses/update.json
    

//    NSString *baseURL = @"https://api.twitter.com/1.1/statuses/update.json";
//    NSString *method =@"?status=";
//    NSString *status =@"This is a test Tweet";
//    NSString *urlString = [NSString stringWithFormat:@"%@%@",baseURL,method];
//    
//    NSLog(@"urlString:%@",urlString);
//    
//    
//    NSString *urlEncodedString =
//    [[NSURL URLWithDataRepresentation:[status dataUsingEncoding:NSUTF8StringEncoding] relativeToURL:nil] relativeString];
//    // API: Uses URL,
//    //NSString *urlEncodedString = [status stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"urlEncodedString:%@",urlEncodedString);
//    
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",urlString,urlEncodedString]];
//    
//    //[NSURL URLWithString:urlEncodedString];
//    NSLog(@"url:%@",url);
//    
//    //configure the session
//    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
//    [sessionConfig setHTTPAdditionalHeaders: @{@"Accept": @"application/json"}];
//    sessionConfig.timeoutIntervalForRequest = 30.0;
//    sessionConfig.timeoutIntervalForResource = 60.0;
//    sessionConfig.HTTPMaximumConnectionsPerHost = 1;
//    
//    //create session with configuration
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig
//                                                          delegate:self
//                                                     delegateQueue:nil];
//    //get congress data using url
//    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url];
//    [dataTask resume];

    
//    [[[FBSDKGraphRequest alloc]
//      initWithGraphPath:@"me/feed"
//      parameters: parameters
//      HTTPMethod:@"POST"]
//     //list of parameters: https://developers.facebook.com/docs/graph-api/reference/
//
//     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//         if (!error) {
//             NSLog(@"Post id:%@", result[@"id"]);
//             [self saveSentMessageSegment:result[@"id"]];
//             [self.messageTableViewController.navigationController popViewControllerAnimated:YES];
//         }
//     }];
}

-(void)showTweetDisclosureAlert{
    NSString *alertTitle = @"Way to go!";
    NSString *alertMessage = [NSString stringWithFormat:@"Your tweet will be displayed anonymously below to inspire others.  Is that OK with you?"];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSLog(@"OK");
        // just save
        [self saveSentMessageWithHidden:NO];
    }];
    [alertController addAction:OKAction];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"No, do not display my message at all", @"cancel action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSLog(@"no, don't show");
        [self saveSentMessageWithHidden:YES];
        // update defaults for hide
    }];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void) saveSentMessageWithHidden:(BOOL)isHidden{
    
    // add check defaults to hide bool
    
    //  SAVING MESSAGE DATA TO PARSE
    PFUser *currentUser = [PFUser currentUser];
    
    //NSLog(@"printing shit - program:%@ | segment:%@ | actionDict:%@",self.selectedProgram,self.selectedSegment,self.selectedActionDict);
    PFObject *sentMessageItem = [PFObject objectWithClassName:@"sentMessages"];
    [sentMessageItem setObject:self.pushthoughtTextView.text forKey:@"messageText"];
    [sentMessageItem setObject:[self.selectedActionDict valueForKey:@"messageCategory"] forKey:@"messageCategory"];
    [sentMessageItem setObject:[self.selectedActionDict valueForKey:@"actionCategory"] forKey:@"actionCategory"];
    [sentMessageItem setObject:@"twitter" forKey:@"messageType"];
    
    // Set isHidden
    if(isHidden){
        [sentMessageItem setObject:@YES forKey:@"isHidden"];
    }else {
        [sentMessageItem setObject:@NO forKey:@"isHidden"];
    }
    
    //Program and segment info
    [sentMessageItem setObject:[self.selectedSegment valueForKey:@"segmentID"] forKey:@"segmentID"];
    [sentMessageItem setObject:[self.selectedSegment valueForKey:@"objectId"] forKey:@"segmentObjectId"];
    [sentMessageItem setObject:[self.selectedProgram valueForKey:@"objectId"] forKey:@"programObjectId"];
    
    //user info
    [sentMessageItem setObject:currentUser.objectId forKey:@"userObjectId"];
    [sentMessageItem setObject:[currentUser valueForKey:@"username"] forKey:@"username"];
    NSMutableDictionary *authDict = [currentUser valueForKey:@"authData"];
    [sentMessageItem setObject:authDict[@"twitter"][@"screen_name"] forKey:@"twitterId"];
    
//    This code adds info about the rep or person contacted
//    if ([self.selectedActionDict isKindOfClass:[CongressionalMessageItem class]]) {
//        NSLog(@"Congressional Message Item Class");
//        NSString *bioguide_id = [self.selectedContact valueForKey:@"bioguide_id"];
//        NSString *fullName = [self.selectedContact valueForKey:@"fullName"];
//        [sentMessageItem setObject:bioguide_id forKey:@"contactID"];
//        [sentMessageItem setObject:fullName forKey:@"contactName"];
//    } else {
//        NSLog(@"Regular Contact Item Class");
//        NSString *contactID = [self.selectedContact valueForKey:@"contactID"];
//        NSString *targetName = [self.selectedContact valueForKey:@"targetName"];
//        [sentMessageItem setObject:contactID forKey:@"contactID"];
//        [sentMessageItem setObject:targetName forKey:@"contactName"];
//    }
    
//    This code adds the default message flag
//    NSString *category = [self.selectedActionDict valueForKey:@"messageCategory"];
//    NSString *messageText = self.pushthoughtTextView.text;
//    NSString *defaultMessage =[self.selectedActionDict valueForKey:@"messageText"];
//    NSLog(@"comparing default: %@ and sent message: %@",defaultMessage,self.selectedActionDict);
//    
//    if([messageText isEqualToString:defaultMessage]) {
//        NSLog(@"comparison EQUAL");
//        [sentMessageItem setObject:@YES forKey:@"isDefaultMessage"];
//    }else{
//        NSLog(@"comparison NOT EQUAL");
//        [sentMessageItem setObject:@NO forKey:@"isDefaultMessage"];
//    }
    
    [sentMessageItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //save
        if(error){
            NSLog(@"error, message not saved");
        }
        else {
            NSLog(@"no error, message saved");
            [self saveHashtags];
            [self saveTwitterTargets];
            [self saveSegmentStats];
            //NSLog(@"Got here in the save 2:%@",sentMessageItem);
            //MarkSentMessageAPI *markSentMessagesAPI = [[MarkSentMessageAPI alloc]init];
            //markSentMessagesAPI.messageTableViewController = self.messageTableViewController;
            //[markSentMessagesAPI markSentMessages];
        }
    }];
}

-(void)saveSegmentStats{
    //go to segment in table and add one then save
    PFQuery *query = [PFQuery queryWithClassName:@"sentMessages"];
    [query whereKey:@"segmentObjectId" equalTo:[self.selectedSegment valueForKey:@"objectId"]];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        //Now update query with count
        if(!error) {
            NSNumber *countNumber = [[NSNumber alloc]initWithInt:count];
            NSLog(@"count of objects in sentMessage for Segment:%@",countNumber);
            
            PFQuery *queryCount = [PFQuery queryWithClassName:@"SegmentStats"];
            [queryCount whereKey:@"segmentObjectId" equalTo:[self.selectedSegment valueForKey:@"objectId"]];
            [queryCount getFirstObjectInBackgroundWithBlock:^(PFObject *segmentStatDict, NSError *error) {
                if (!error) {
                    //NSLog(@"Segment Stats Dict from Parse:%@",segmentStatDict);
                    [segmentStatDict setObject:countNumber forKey:@"actionCount"];
                    //NSLog(@"New Segment Stats Dict to Parse:%@",segmentStatDict);
                    // Save
                    [segmentStatDict saveInBackground];
                } else {
                    // Did not find any actionStats for this segment, create NEW entry
                    PFObject *statObject = [PFObject objectWithClassName:@"SegmentStats"];
                    [statObject setObject:[self.selectedSegment valueForKey:@"objectId"] forKey:@"segmentObjectId"];
                    [statObject setObject:[self.selectedProgram valueForKey:@"objectId"] forKey:@"programObjectId"];
                    if(countNumber == 0){
                        [statObject setObject:countNumber forKey:@"actionCount"];
                    } else {
                        [statObject setObject:@(1) forKey:@"actionCount"];
                    }
                    NSLog(@"Error:%@, nothing in Parse, adding new statObjec:%@", error, statObject);
                    [statObject saveInBackground];
                }
            }];
        }
    }];
}


# pragma mark - Save # and @ Methods
-(void) saveHashtags {
    NSString *messageText = self.pushthoughtTextView.text;
    NSMutableArray *hashtagList = [[NSMutableArray alloc]init];
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#\\w+" options:0 error:&error];
    NSArray *matches = [regex matchesInString:messageText options:0 range:NSMakeRange(0, messageText.length)];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:0];
        NSString* word = [messageText substringWithRange:wordRange];
        PFObject *parseHashtagDict = [PFObject objectWithClassName:@"Hashtags"];
        [parseHashtagDict setValue:word forKey:@"hashtag"];
        [parseHashtagDict setValue:[self.selectedSegment valueForKey:@"objectId"] forKey:@"segmentObjectId"];
        [parseHashtagDict setValue:[self.selectedProgram valueForKey:@"objectId"] forKey:@"programObjectId"];
        [parseHashtagDict setValue:[NSNumber numberWithInt:1] forKey:@"frequency"];
        NSLog(@"Found tag %@", word);
        [hashtagList addObject:parseHashtagDict];
    }
    [PFObject saveAll:(NSArray*)hashtagList];
}

-(void) saveTwitterTargets {
    NSString *messageText = self.pushthoughtTextView.text;
    NSMutableArray *targetArray = [[NSMutableArray alloc]init];
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@\\w+" options:0 error:&error];
    NSArray *matches = [regex matchesInString:messageText options:0 range:NSMakeRange(0, messageText.length)];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:0];
        NSString *word = [messageText substringWithRange:wordRange];
        PFObject *parseHashtagDict = [PFObject objectWithClassName:@"TargetTwitterNames"];
        [parseHashtagDict setValue:word forKey:@"TwitterName"];
        [parseHashtagDict setValue:[self.selectedSegment valueForKey:@"objectId"] forKey:@"segmentObjectId"];
        [parseHashtagDict setValue:[self.selectedProgram valueForKey:@"objectId"] forKey:@"programObjectId"];
        [parseHashtagDict setValue:[NSNumber numberWithInt:1] forKey:@"frequency"];
        NSLog(@"Found Twitter target:%@", word);
        [targetArray addObject:parseHashtagDict];
    }
    
    [PFObject saveAll:(NSArray*)targetArray];
}




//   ((?:^|\s)(?:@){1}[0-9a-zA-Z_]{1,15})

# pragma mark - Gesture Recognizer
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //    UITableView *tableView = (UITableView *)gestureRecognizer.view;
    //    CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view];
    //    if ([tableView indexPathForRowAtPoint:p]) {
    //        return YES;
    //
    //    }
    //    return NO;
    return YES;
}
- (void)respondToTapGesture:(UITapGestureRecognizer *)tap {
    //*******
    //This is what we use for user touches in the cells
    //It grabs point coordinate of touch as finger lifted
    //******************
    
    if (UIGestureRecognizerStateEnded == tap.state) {

        // Collect data about tap location
        //UITableView *tableView = (UITableView *)tap.view;
        CGPoint p = [tap locationInView:tap.view];
        CGPoint pLocal = [tap locationInView:self.collectionView];
        //self.selectedActionDict = [self.actionOptionsArray objectAtIndex:indexPath.row];
        //NSLog(@"selected Action dict:%@",self.selectedActionDict);
        
        if (CGRectContainsPoint(self.clearTouchAreaImageView.frame, p)){
            self.pushthoughtTextView.text = @"";
            [self textViewDidChange:self.pushthoughtTextView];
            
        } else if (CGRectContainsPoint(self.linkTouchArea.frame, p)) {
            if(self.linkState == 1){
                self.linkState = 0;
                self.linkCheckbox.image = [UIImage imageNamed:@"checkbox_unchecked.png"];
            } else {
                self.linkState = 1;
                self.linkCheckbox.image = [UIImage imageNamed:@"checked_checkbox.png"];
            }
        [self textViewDidChange:self.pushthoughtTextView];
            
        } else if (CGRectContainsPoint(self.sendTweet.frame, p)) {
            NSLog(@"touch in tweet:");
            if([PFUser currentUser]){
                if([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]){
                    // just send it
                    [self sendTweetwithComposer];
                } else {
                    // link to a twitter account
                    [self logIn];
                }
            } else {
                [self logIn];
            }
            
        } else if (CGRectContainsPoint(self.collectionView.frame, p)) {
            //NSLog(@"Touch point is in collectionView");
            NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:pLocal];
            //NSLog(@"collectionview cell indexpath: %@",indexPath);
            FedRepCollectionCell *cell = (FedRepCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            
            NSDictionary *dictionary = [self.collectionData objectAtIndex:indexPath.row];
            NSNumber *number = [dictionary valueForKey:@"isSelected"];
            int intValue = [number intValue];
            
            NSString *tweetAddress = [[NSString alloc]init];
            NSString *tweetAddressFrontSpace = [[NSString alloc]init];
            if([dictionary valueForKey:@"bioguide_id"]){
                tweetAddress = [NSString stringWithFormat:@"@%@",[dictionary valueForKey:@"twitter_id"]];
                tweetAddressFrontSpace = [NSString stringWithFormat:@" @%@",[dictionary valueForKey:@"twitter_id"]];
            } else {
                tweetAddressFrontSpace = [NSString stringWithFormat:@" @%@",[dictionary valueForKey:@"twitterID"]];
                tweetAddress = [NSString stringWithFormat:@"@%@",[dictionary valueForKey:@"twitterID"]];
            }
            
            //NSLog(@"number bool isSelected before: %d",intValue);
            
            if(!intValue){
                //NSLog(@"NO - isSelected is NOT active, so make active");
                [[self.collectionData objectAtIndex:indexPath.row] setObject:@YES forKey:@"isSelected"];
                cell.selectionHighlightImageView.hidden = NO;
                // add tweet address
                [self.pushthoughtTextView replaceRange:self.pushthoughtTextView.selectedTextRange withText:tweetAddressFrontSpace ];
            }  else {
                //NSLog(@"YES - isSelected is active, make inactive");
                [[self.collectionData objectAtIndex:indexPath.row] setObject:@NO forKey:@"isSelected"];
                cell.selectionHighlightImageView.hidden = YES;
                // remove tweet address
                if ([self.pushthoughtTextView.text rangeOfString:tweetAddress options:NSCaseInsensitiveSearch].location == NSNotFound) {
                    //NSLog(@"string does not contain address for:%@",tweetAddress);
                } else {
                    self.pushthoughtTextView.text = [self.pushthoughtTextView.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %@",tweetAddress] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self.pushthoughtTextView.text length])];
                    self.pushthoughtTextView.text = [self.pushthoughtTextView.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",tweetAddress] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self.pushthoughtTextView.text length])];
                    // to do: add lines to take away spaces if there are any
                    //NSLog(@"string contains address:%@",tweetAddress);
                }
            }
            [self.collectionView reloadData];
            [self textViewDidChange:self.pushthoughtTextView];
            
        } else {
            //NSLog(@"Touch point is NOT in collectionView");
        }

        //NSLog(@"point %@ local point:%@",NSStringFromCGPoint(p),NSStringFromCGPoint(pLocal));
        
        //UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        //CGPoint pointInCell = [tap locationInView:cell];
        
        // Deselect the row
        //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        //if(CGRectContainsPoint(cell.frame, pointInCell)) {
        //[self performSegueWithIdentifier:@"showFedRepVC" sender:self];
        //}
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // adjust based on category
    return self.collectionData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FedRepCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    // adjust based on category
    NSMutableDictionary *dictionary = [self.collectionData objectAtIndex:indexPath.row];
    [self.collectionView addSubview:cell];
    return [cell configCollectionCell:(NSMutableDictionary*)dictionary];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // adjust based on category
    
    NSMutableDictionary *dictionary = [self.collectionData objectAtIndex:indexPath.row];
    if([dictionary valueForKey:@"bioguide_id"]){
        return CGSizeMake(120, 114);
    } else {
        return CGSizeMake(160, 114);
    }
}

#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showFedRepPhone"]){
        FedRepPhoneTableViewController *fedRepPhoneTVC = segue.destinationViewController;
        fedRepPhoneTVC.tableViewController = self;
        fedRepPhoneTVC.selectedProgram = self.selectedProgram;
        fedRepPhoneTVC.selectedSegment = self.selectedSegment;
        fedRepPhoneTVC.actionsForSegment = self.actionsForSegment;
        fedRepPhoneTVC.sentActionsForSegment = self.sentActionsForSegment;
        fedRepPhoneTVC.selectedActionDict = self.selectedActionDict;
        fedRepPhoneTVC.fedRepList = self.fedRepList;
        fedRepPhoneTVC.collectionData = self.collectionData;
        fedRepPhoneTVC.segmentedControlValue = (int)self.segmentedControlCommunicationType.selectedSegmentIndex;
        NSLog(@"selected segment index on tweet:%ld",self.segmentedControlCommunicationType.selectedSegmentIndex);
        NSLog(@"selected segment index on phone:%ld",self.segmentedControlCommunicationType.selectedSegmentIndex);
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
