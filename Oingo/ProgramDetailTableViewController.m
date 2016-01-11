//
//  ProgramDetailTableViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 5/4/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "ProgramDetailTableViewController.h"
#import "ProgramsTableViewController.h"
#import <Parse/Parse.h>
#import "PFTwitterUtils+NativeTwitter.h"
#import "ProgramDetailTableViewCell.h"
#import "Segment.h"
#import "Program.h"
#import "MessageTableViewController.h"
#import <UIKit/UIKit.h>
#import "WebViewController.h"
#import "ActionDashboardTableViewController.h"


@interface ProgramDetailTableViewController () <UIGestureRecognizerDelegate>

@end

@implementation ProgramDetailTableViewController

Segment *segment;


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [super viewDidAppear:animated];
//    [self.tableView setNeedsLayout];  //may not need these as I'm doing it in the cells individually.
//    [self.tableView layoutIfNeeded]; //may not need these as I'm doing it in the cells individually.
//    [self.tableView reloadData];

}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
//    [self.tableView setNeedsDisplay];
//    [self.tableView setNeedsLayout];
//    [self.tableView layoutIfNeeded];
    [self.tableView reloadData];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    
    
    //Separator style for tableview
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    //Pulling data for tablecell from Parse (filtered by selected program i.e. List of all associated with the Daily Show.)
    PFQuery *query = [PFQuery queryWithClassName:@"Segments"];
    [query whereKey:@"programTitle" equalTo:[self.selectedProgram valueForKey:@"programTitle"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.segmentList = objects;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self prepSegmentSections:self.segmentList];
            });
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    // Format table header
    self.tableHeaderView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.tableHeaderView.layer.borderWidth = 2;
    self.tableHeaderView.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    self.tableHeaderView.layer.cornerRadius = 3;
    self.tableHeaderView.clipsToBounds = YES;
    NSString* padding = @"  "; // # of spaces
    self.programTitleHeaderLabel.text = [NSString stringWithFormat:@"%@%@%@", padding,[self.selectedProgram valueForKey:@"programTitle"], padding];
    

    //Create gesture recognizer,
    UITapGestureRecognizer *tapRocognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture:)]; //connect recognizer to action method.
    tapRocognizer.delegate = self;
    tapRocognizer.numberOfTapsRequired = 1;
    tapRocognizer.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:tapRocognizer];
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    UITableView *tableView = (UITableView *)gestureRecognizer.view;
    CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view];
    //if point is in the tableview then return YES
    if ([tableView indexPathForRowAtPoint:p]) {
        return YES;
    }
    return NO;
}


- (void)respondToTapGesture:(UITapGestureRecognizer *)tap
{
    if (UIGestureRecognizerStateEnded == tap.state) {
        // Capture useful data and deselect row
        UITableView *tableView = (UITableView *)tap.view;
        CGPoint p = [tap locationInView:tap.view];
        NSIndexPath* indexPath = [tableView indexPathForRowAtPoint:p];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        ProgramDetailTableViewCell *cell = (ProgramDetailTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        CGPoint pointInCell = [tap locationInView:cell];
        
        if (CGRectContainsPoint(cell.linkToContentButton.frame, pointInCell)) {
            // user tapped link
            self.selectedLink = cell.linkToContentButton.titleLabel.text; //capture the link
            [self performSegueWithIdentifier:@"showWebViewController" sender:self];

        } else if (CGRectContainsPoint(cell.altPathButton.frame, pointInCell)){
            // user tapped altPath
            NSString *dateGroup = [self dateGroupForSection:indexPath.section];
            NSArray *rowIndecesInSection = [self.sections objectForKey:dateGroup];
            NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row]; //pulling the row indece from array above
            self.selectedSegment = [self.segmentList objectAtIndex:[rowIndex intValue]];
            [self performSegueWithIdentifier:@"showActionDashboard" sender:self];
        } else {
            NSString *dateGroup = [self dateGroupForSection:indexPath.section];
            NSArray *rowIndecesInSection = [self.sections objectForKey:dateGroup];
            NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row]; //pulling the row indece from array above
            self.selectedSegment = [self.segmentList objectAtIndex:[rowIndex intValue]];
            [self performSegueWithIdentifier:@"showMessages" sender:self];
        }
    }
}

-(void)prepSegmentSections:segmentList {
    
    if(self.sections){
        [self.sections removeAllObjects];
        [self.sectionToCategoryMap removeAllObjects];
    }else {
        self.sections = [NSMutableDictionary dictionary];
        self.sectionToCategoryMap = [NSMutableDictionary dictionary];
    }
    //Loops through every messageItem in the messageList and creates 2 dictionaries with index values and categories.
    NSInteger section = 0;
    NSInteger rowIndex = 0; //now 1
    for (NSDictionary *segmentItem in self.segmentList) {
        NSString *dateGroup = [segmentItem valueForKey:@"dateGroup"]; //retrieves category for each message -1st regulator
        NSMutableArray *objectsInSection = [self.sections objectForKey:dateGroup]; //assigns objectsInSection value of sections for current category
        if (!objectsInSection) {
            objectsInSection = [NSMutableArray array];  //if new create array
            // this is the first time we see this category - increment the section index
            // sectionToCategoryMap literally it ends up (Regulator = 0)
            [self.sectionToCategoryMap setObject:dateGroup forKey:[NSNumber numberWithInt:(int)section++]]; // zero
        }
        [objectsInSection addObject:[NSNumber numberWithInt:(int)rowIndex++]]; //adds index number to objectsInSection temp array.
        [self.sections setObject:objectsInSection forKey:dateGroup]; //overwrite 1st object with new objects (2 regulatory objects).
    }
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    [self.tableView reloadData];
}


-(NSMutableArray*)sortSegmentList:(NSMutableArray*)messageListWithContacts {
    
        // Sorts array by dateReleased
        NSSortDescriptor *dateReleased = [[NSSortDescriptor alloc]initWithKey:@"dateReleased" ascending:NO];
        //NSLog(@" NOT custom ordering");
        NSArray *sortDescriptors = [NSArray arrayWithObjects: dateReleased, nil];
        NSArray *segmentListSorted = [messageListWithContacts sortedArrayUsingDescriptors:sortDescriptors];
        return (NSMutableArray*)segmentListSorted;
}



#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *dateGroup= [self dateGroupForSection:indexPath.section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:dateGroup];
    NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row]; //pulling the row indece from array above
    
    
    ProgramDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    segment = [self.segmentList objectAtIndex:[rowIndex intValue]];
    [cell configSegmentCell:segment];
    [cell setNeedsDisplay];
    [cell layoutIfNeeded];
    
    return cell;
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 112;
//}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"Section %ld Row %ld", (long)[indexPath section], (long)[indexPath row]);
    return UITableViewAutomaticDimension;
}

#pragma mark - Sections

- (NSString *) dateGroupForSection:(NSInteger)section { //takes section # and returns name of section.
    return [self.sectionToCategoryMap objectForKey:[NSNumber numberWithInt:(int)section]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return (unsigned long)self.sections.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSString *dateGroup = [self dateGroupForSection:section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:dateGroup];
    return [rowIndecesInSection count];
}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(7, 0, tableView.frame.size.width -14 , 16)];
//    UILabel *sectionLabel = [[UILabel alloc] init];
//    sectionLabel.frame = CGRectMake(7, 0, tableView.frame.size.width -14, 16);
//    sectionLabel.backgroundColor = [UIColor colorWithRed:.96 green:.96 blue:.96 alpha:1];
//    sectionLabel.layer.borderWidth = .5;
//    sectionLabel.layer.borderColor = [[UIColor blackColor] CGColor];
//    sectionLabel.font = [UIFont boldSystemFontOfSize:11];
//    sectionLabel.textColor = [UIColor blackColor];
//    sectionLabel.layer.cornerRadius = 3;
//    sectionLabel.clipsToBounds = YES;
//    NSString* padding = @"  "; // # of spaces
//    sectionLabel.text = [NSString stringWithFormat:@"%@%@%@", padding, [self dateGroupForSection:section], padding];
//    [view addSubview:sectionLabel];
//    return view;
//}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //    NSString *category= [self categoryForSection:section];
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    if([category isEqualToString:@"Local Representative"] && ![defaults valueForKey:@"zipCode"] && ![defaults valueForKey:@"latitude"]) {
    //        return sectionHeaderHeight;
    //    } else if([category isEqualToString:@"Local Representative"]) {
    //        return localRepSectionHeaderHeight + 3;
    //    } else {
    return 0;
    //    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {  
    if ([segue.identifier isEqualToString:@"showMessages"]){
        segment = self.segmentList[self.indexPath.row];
        MessageTableViewController *messageTableViewController = [segue destinationViewController];
        messageTableViewController.selectedSegment = self.selectedSegment;
        messageTableViewController.selectedProgram = self.selectedProgram;
    }
    if ([segue.identifier isEqualToString:@"showWebViewController"]){
        WebViewController *webViewController =  [segue destinationViewController];
        webViewController.selectedLink = self.selectedLink;
        NSLog(@"selected link program detail %@:",webViewController.selectedLink);
    }
    if ([segue.identifier isEqualToString:@"showActionDashboard"]){
        ActionDashboardTableViewController *actionDashTVC = [segue destinationViewController];
        actionDashTVC.programDetailTVC = self;
        actionDashTVC.selectedProgram = self.selectedProgram;
        actionDashTVC.selectedSegment = self.selectedSegment;
    }
}



@end
