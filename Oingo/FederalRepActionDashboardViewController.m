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
    
    // Set tableViewDelegate
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Set CollectionView delegate and Flow layout
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.collectionView setContentInset:UIEdgeInsetsMake(-20, 10, -20, 0)];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    flowLayout.minimumInteritemSpacing = 3;
    flowLayout.minimumLineSpacing = 3;
    [flowLayout setHeaderReferenceSize:CGSizeMake(0, 100)];
    [flowLayout setFooterReferenceSize:CGSizeMake(0, 100)];
    self.collectionView.collectionViewLayout = flowLayout;
    self.collectionView.allowsSelection = YES;
    self.collectionView.allowsMultipleSelection = YES;
    
    
    //Fetch Federal Rep data
    FetchDataFedReps *fetchData = [[FetchDataFedReps alloc]init];
    fetchData.viewController = self;
    [fetchData fetchRepsWithZip:@"92807"];
    
//    // Fetch Sent Action data
//    
//    NSString *selectedSegmentID = [self.selectedSegment valueForKey:@"segmentID"];
//    
//    PFQuery *query = [PFQuery queryWithClassName:@"sentMessages"];
//    [query whereKey:@"segmentID" equalTo:selectedSegmentID];
//    [query whereKey:@"messageType" equalTo:@"twitter"];
//    [query whereKey:@"messageCategory" equalTo:@"Local Representative"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.sentMessagesForSegment = (NSMutableArray*)objects;
//                
//                
//            });
//        }
//    }];
    
    
            
    // Set TextView Delegate
    self.textView.delegate=self;
    
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
    
    // Format TableView
    self.tableView.layer.borderColor = [[UIColor colorWithRed:13/255.0 green:81/255.0 blue:183/255.0 alpha:1] CGColor];
    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.cornerRadius = 3;
    self.tableView.clipsToBounds = YES;
    
    
    
    // Create gesture recognizer
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture:)]; //connect recognizer to action method.
    tapRecognizer.delegate = self;
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [tapRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapRecognizer];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.filteredSentActionsForSegmentWithCount count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Create cell
    FedRepCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FedRepCell" forIndexPath:indexPath];
    cell.viewController = self;
    [self.tableView addSubview:cell];
    
    // Turn off selection highlighting
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Configure the cell...
    NSMutableDictionary *dictionary = [self.filteredSentActionsForSegmentWithCount objectAtIndex:indexPath.row];

    
    [cell layoutIfNeeded];
    return [cell configCell:(NSMutableDictionary*)dictionary];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    FedRepCell *cell = (FedRepCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.pushthoughtTextView.text = cell.tableViewPrimaryLabel.text;
    
//    if(self.tableSegmentControl.selectedSegmentIndex == 0){
//        self.messageTextView.text = cell.messageTextLabel.text;
//    } else {
//        [self.messageTextView replaceRange:self.messageTextView.selectedTextRange withText:[NSString stringWithFormat:@" %@",cell.messageTextLabel.text]];
//    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.placeholderTextLabel.hidden = YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.placeholderTextLabel.hidden = ([textView.text length] > 0);
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.placeholderTextLabel.hidden = ([textView.text length] > 0);
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
        NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:p];
        //self.selectedActionDict = [self.actionOptionsArray objectAtIndex:indexPath.row];
        //NSLog(@"selected Action dict:%@",self.selectedActionDict);
        if (CGRectContainsPoint(self.collectionView.frame, p)) {
            NSLog(@"Touch point is in collectionView");
        } else {
            NSLog(@"Touch point is NOT in collectionView");
        }
        
        NSLog(@"class check: %@",[tap.view class]);
        
//        UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//        CGPoint pointInCell = [tap locationInView:cell];
        
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
    [self.collectionView addSubview:cell];

    NSMutableDictionary *dictionary = [self.fedRepList objectAtIndex:indexPath.row];
    //NSLog(@"dictionary for FedRep Coll Cell %@:",dictionary);
    
    return [cell configCollectionCell:(NSMutableDictionary*)dictionary];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
    
}


 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

-(BOOL)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
//    FedRepCollectionCell *fedRepCollectionCell = collectionView
    return YES;
}

#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 112);
}

@end
