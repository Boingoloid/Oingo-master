//
//  FederalRepActionDashboardViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 12/17/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "FederalRepActionDashboardViewController.h"
#import "FedRepCell.h"
#import "FedRepCollectionCell.h"
#import "FetchDataFedReps.h"


@interface FederalRepActionDashboardViewController () <UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@end

@implementation FederalRepActionDashboardViewController

static NSString * const reuseIdentifier = @"Cell";



- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"FedrepAction Firing");
    
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
    

    
    // Fetch Federal Rep data
    FetchDataFedReps *fetchData = [[FetchDataFedReps alloc]init];
    fetchData.viewController = self;
    [fetchData fetchRepsWithZip:@"94107"];
    
    // Fetch hashtag data
    [self getHashtagData];
    
    //insert twitter address first in collectionView
    // Format Push Thought suggestion
    self.pushthoughtTextView.text = [self.selectedActionDict valueForKey:@"messageText"];
    self.pushthoughtTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.pushthoughtTextView.layer.borderWidth = 0.5;
    self.pushthoughtTextView.layer.cornerRadius = 3;
    self.pushthoughtTextView.clipsToBounds = YES;
    
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
    self.tableView.layer.borderColor = [[UIColor colorWithRed:13/255.0 green:81/255.0 blue:183/255.0 alpha:1] CGColor];
    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.cornerRadius = 3;
    self.tableView.clipsToBounds = YES;
    

    // Format Sent Message Data -----------------------------------------------------------------------------------
    NSArray *filteredActionList;
    filteredActionList = [self.actionsForSegment filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"messageCategory = %@", @"Local Representative"]];
    NSLog(@"printing array count:%lu  value:%@",(unsigned long)filteredActionList.count,filteredActionList);
    
    
    NSArray *filteredSentActionList;
    filteredSentActionList = [self.sentActionsForSegment filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"messageCategory = %@", @"Local Representative"]];
    NSLog(@"printing sent array count:%lu  value:%@",(unsigned long)filteredSentActionList.count,filteredSentActionList);
    
    self.filteredActionsForSegment = (NSMutableArray*)filteredActionList;
    self.filteredSentActionsForSegment = (NSMutableArray*)filteredSentActionList;
    
    
    // Adjust for default count
    NSString *defaultMessage =[[self.filteredActionsForSegment objectAtIndex:0] valueForKey:@"messageText"];
    NSMutableDictionary *defaultMessageDictionary = [[NSMutableDictionary alloc]initWithObjectsAndKeys:defaultMessage, @"messageText", 0, @"messageCount", nil];
    
    NSMutableArray *messageArray= [[NSMutableArray alloc]init];
    
    for(NSDictionary *sentMessageDict in self.filteredSentActionsForSegment){
        if([sentMessageDict valueForKey:@"isDefaultMessage"]){
            int newCount = [[defaultMessageDictionary valueForKey:@"messageCount"]intValue] +1;
            [defaultMessageDictionary setObject:[NSNumber numberWithInt:newCount] forKey:@"messageCount"];
        } else {
            [sentMessageDict setValue:[NSNumber numberWithInt:0] forKey:@"messageCount"];
            [messageArray addObject:(NSDictionary*)sentMessageDict];
        }
    }
    
    NSMutableArray *tableDataArray = [[NSMutableArray alloc]init];
    [tableDataArray addObject:defaultMessageDictionary];
    [tableDataArray addObjectsFromArray:messageArray];
    self.filteredSentActionsForSegmentWithCount = tableDataArray;
    
    // Set self.tableData default to sent messages
    self.tableData = self.filteredSentActionsForSegmentWithCount;
    
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


-(void) getHashtagData{
    
    //**************  This should  be moved to Cloud Code at some point.  Pointless to do all this work as the UI is loading when I just need the grouped/summed table
    //get message data for segment menu
    NSString *selectedSegmentID = [self.selectedSegment valueForKey:@"segmentID"];
    PFQuery *queryHashtags = [PFQuery queryWithClassName:@"Hashtags"];
    [queryHashtags whereKey:@"segmentID" equalTo:selectedSegmentID];
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
        self.tableData = (NSMutableArray*)self.filteredSentActionsForSegmentWithCount;
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
    
    // Turn off selection highlighting
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Configure the cell...
    NSMutableDictionary *dictionary = [self.tableData objectAtIndex:indexPath.row];

    
    [cell layoutIfNeeded];
    return [cell configCell:(NSMutableDictionary*)dictionary];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    FedRepCell *cell = (FedRepCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if(self.segmentedControlTableView.selectedSegmentIndex == 0){
        self.pushthoughtTextView.text = cell.tableViewPrimaryLabel.text;
    } else {
        [self.pushthoughtTextView replaceRange:self.pushthoughtTextView.selectedTextRange withText:[NSString stringWithFormat:@" %@",cell.tableViewPrimaryLabel.text]];
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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


- (void)textViewDidChange:(UITextView *)textView{
    if(textView == self.pushthoughtTextView){
        NSLog(@"YES");
        NSString *string = self.pushthoughtTextView.text;
        int count = 0;
        
        //search for tweet addreses in pushthoughtTextView
        
        for (NSDictionary *dictionary in self.fedRepList){
            NSString *tweetAddress = [NSString stringWithFormat:@"@%@",[dictionary valueForKey:@"twitter_id"]];
            
            if ([string rangeOfString:tweetAddress options:NSCaseInsensitiveSearch].location == NSNotFound) {
                NSLog(@"string does not contain address for:%@",tweetAddress);
                [[self.fedRepList objectAtIndex:count] setObject:@NO forKey:@"isSelected"];
                count = count + 1;
            } else {
                NSLog(@"string contains address:%@",tweetAddress);
                [[self.fedRepList objectAtIndex:count] setObject:@YES forKey:@"isSelected"];
                count = count +1;
            }
            NSLog(@"fedreplist:%@",self.fedRepList);
            [self.collectionView reloadData];
        }
        
    }
    
}
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
        } else if (CGRectContainsPoint(self.collectionView.frame, p)) {
            //NSLog(@"Touch point is in collectionView");
            NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:pLocal];
            //NSLog(@"collectionview cell indexpath: %@",indexPath);
            FedRepCollectionCell *cell = (FedRepCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            
            
            //[[self.fedRepList objectAtIndex:indexPath.row] setObject:@YES forKey:@"isSelected"];
            
            NSDictionary *dictionary = [self.fedRepList objectAtIndex:indexPath.row];
            NSNumber *number = [dictionary valueForKey:@"isSelected"];
            int intValue = [number intValue];
            
            NSLog(@"number bool isSelected before: %d",intValue);
            
            if(!intValue){
                NSLog(@"NO - isSelected is NOT active, so make active");
                [[self.fedRepList objectAtIndex:indexPath.row] setObject:@YES forKey:@"isSelected"];
                cell.selectionHighlightImageView.hidden = NO;
                // add tweet address
                
                NSString *tweetAddressFrontSpace = [NSString stringWithFormat:@" @%@",[dictionary valueForKey:@"twitter_id"]];
                [self.pushthoughtTextView replaceRange:self.pushthoughtTextView.selectedTextRange withText:tweetAddressFrontSpace ];
            }  else {
                NSLog(@"YES - isSelected is active, make inactive");
                [[self.fedRepList objectAtIndex:indexPath.row] setObject:@NO forKey:@"isSelected"];
                cell.selectionHighlightImageView.hidden = YES;
                
                // remove tweet address
                NSString *tweetAddress = [NSString stringWithFormat:@"@%@",[dictionary valueForKey:@"twitter_id"]];
                if ([self.pushthoughtTextView.text rangeOfString:tweetAddress options:NSCaseInsensitiveSearch].location == NSNotFound) {
                    NSLog(@"string does not contain address for:%@",tweetAddress);
                } else {
                    self.pushthoughtTextView.text = [self.pushthoughtTextView.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %@",tweetAddress] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self.pushthoughtTextView.text length])];
                    self.pushthoughtTextView.text = [self.pushthoughtTextView.text stringByReplacingOccurrencesOfString:tweetAddress withString:@""];
                    // to do: add lines to take away spaces if there are any
                    NSLog(@"string contains address:%@",tweetAddress);
                }
            }
            [self.collectionView reloadData];
            
        } else {
            //NSLog(@"Touch point is NOT in collectionView");
        }

        //NSLog(@"point %@ local point:%@",NSStringFromCGPoint(p),NSStringFromCGPoint(pLocal));
        
        //UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        //CGPoint pointInCell = [tap locationInView:cell];
        
        // Deselect the row
        //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        //if(CGRectContainsPoint(cell.frame, pointInCell)) {
        //[self performSegueWithIdentifier:@"showBuildMessage" sender:self];
        //}
    }
}



#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.fedRepList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FedRepCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Turn on selection highlighting
    // Configure the cell

    NSMutableDictionary *dictionary = [self.fedRepList objectAtIndex:indexPath.row];
    
    [self.collectionView addSubview:cell];
//    if(indexPath.row == 0){
//        cell.isSelected = YES;
//        cell.selectionHighlightImageView.hidden = NO;
//    }
    
    return [cell configCollectionCell:(NSMutableDictionary*)dictionary];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
    
}


 // Uncomment this method to specify if the specified item should be highlighted during tracking
// - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//	return YES;
// }

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */


#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(120, 114);
}


@end
