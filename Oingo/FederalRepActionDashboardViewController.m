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


@interface FederalRepActionDashboardViewController () <UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end

@implementation FederalRepActionDashboardViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    // Format placeholderTextLabel
    
    
    // tableview data
    self.actionsForSegment; // apply prdicate
    
    
    //        NSString *predicateFormat = @"%K CONTAINS [cd] %@";
    //    NSString *searchAttribute = @"programTitle";
    //            filteredArray = [self.programListFromDatabase filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:predicateFormat,searchAttribute, searchText]];
    
    
    
    // Format TableView
    self.tableView.layer.borderColor = [[UIColor colorWithRed:13/255.0 green:81/255.0 blue:183/255.0 alpha:1] CGColor];
    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.cornerRadius = 3;
    self.tableView.clipsToBounds = YES;
    
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
    
    return [self.tableData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Create cell
    FedRepCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FedRepCell" forIndexPath:indexPath];
    cell.viewController = self;
    [self.tableView addSubview:cell];
    
    // Turn off selection highlighting
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Configure the cell...
    NSMutableDictionary *dictionary = [self.fedRepList objectAtIndex:indexPath.row];
    NSLog(@"fedreplist:%@",self.fedRepList);
    
    [cell layoutIfNeeded];
    return [cell configCell:(NSMutableDictionary*)dictionary];
    
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


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.fedRepList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FedRepCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    [self.collectionView addSubview:cell];

    NSMutableDictionary *dictionary = [self.fedRepList objectAtIndex:indexPath.row];
    NSLog(@"dictionary for FedRep Coll Cell %@:",dictionary);
    
    return [cell configCollectionCell:(NSMutableDictionary*)dictionary];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 112);
}

@end
