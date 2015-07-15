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


@interface ProgramDetailTableViewController () <UIGestureRecognizerDelegate>

@end

@implementation ProgramDetailTableViewController

Segment *segment;

- (void) viewWillAppear:(BOOL)animated {
//Separator style for tableview
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    //Pulling data for tablecell from Parse (filtered by selected program i.e. List of all associated with the Daily Show.)
    PFQuery *query = [PFQuery queryWithClassName:@"Segments"];
    [query whereKey:@"programTitle" equalTo:[self.selectedProgram valueForKey:@"programTitle"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.segmentList = objects;
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
        UITableView *tableView = (UITableView *)tap.view;
        CGPoint p = [tap locationInView:tap.view];
        NSLog(@"%@",NSStringFromCGPoint(p));
        NSIndexPath* indexPath = [tableView indexPathForRowAtPoint:p];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        ProgramDetailTableViewCell *cell = (ProgramDetailTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        self.selectedLink = cell.linkToContentButton.titleLabel.text; //capture the link
        CGPoint pointInCell = [tap locationInView:cell];
        if (CGRectContainsPoint(cell.linkToContentButton.frame, pointInCell)) {
            // user tapped image
            [self performSegueWithIdentifier:@"showWebViewController" sender:self];
        } else {
            // user tapped cell
            [self performSegueWithIdentifier:@"showMessages" sender:self];
        }
    }
}

//-(void)prepSections:messageList {
//    NSLog(@"Prep sections triggered");
//    
//    //add message to this list
//    [self separateMessagesFromContacts:messageList]; //create self.messageList and self.contactList
//    [self createMenuList]; //creates self.menuList
//    [self addLocalRepLocationCaptureCell: self.menuList]; //edits self.menuList
//    
//    self.menuList = [self sortMessageListWithContacts:self.menuList];
//    NSLog(@"menu right before prep sections%@",self.menuList);
//    
//    if(self.sections){
//        [self.sections removeAllObjects];
//        [self.sectionToCategoryMap removeAllObjects];
//    }else {
//        self.sections = [NSMutableDictionary dictionary];
//        self.sectionToCategoryMap = [NSMutableDictionary dictionary];
//    }
//    //Loops through every messageItem in the messageList and creates 2 dictionaries with index values and categories.
//    NSInteger section = 0;
//    NSInteger rowIndex = 0; //now 1
//    for (MessageItem  *messageItem in self.menuList) {
//        NSString *category = [messageItem valueForKey:@"messageCategory"]; //retrieves category for each message -1st regulator
//        NSMutableArray *objectsInSection = [self.sections objectForKey:category]; //assigns objectsInSection value of sections for current category
//        if (!objectsInSection) {
//            objectsInSection = [NSMutableArray array];  //if new create array
//            // this is the first time we see this category - increment the section index
//            // sectionToCategoryMap literally it ends up (Regulator = 0)
//            [self.sectionToCategoryMap setObject:category forKey:[NSNumber numberWithInt:(int)section++]]; // zero
//        }
//        [objectsInSection addObject:[NSNumber numberWithInt:(int)rowIndex++]]; //adds index number to objectsInSection temp array.
//        [self.sections setObject:objectsInSection forKey:category]; //overwrite 1st object with new objects (2 regulatory objects).
//    }
//    
//    // Assign prep section variables back to view controller
//    self.messageTableViewController.sections = (NSMutableDictionary*)self.sections;
//    self.messageTableViewController.sectionToCategoryMap = (NSMutableDictionary*)self.sectionToCategoryMap;
//    self.messageTableViewController.messageList = self.menuList;
//    self.messageTableViewController.menuList = self.menuList;
//    self.messageTableViewController.messageOptionsList = self.messageOptionsList;
//    
//    [self.messageTableViewController.tableView reloadData];
//    
//}
//
//-(NSMutableArray*)sortMessageListWithContacts:(NSMutableArray*)messageListWithContacts {
//    
//    NSSortDescriptor *isMessage = [[NSSortDescriptor alloc] initWithKey:@"isMessage" ascending:NO];
//    NSSortDescriptor *messageCategory = [[NSSortDescriptor alloc]initWithKey:@"messageCategory" ascending:NO];
//    NSSortDescriptor *orderInCategory = [[NSSortDescriptor alloc]initWithKey:@"orderInCategory" ascending:YES];
//    
//    if([[messageListWithContacts firstObject] valueForKey:@"orderInCategory"]  ){
//        isMenuWithCustomOrdering = YES;
//        NSLog(@"custom ordering");
//        NSArray *sortDescriptors = [NSArray arrayWithObjects:messageCategory, isMessage, orderInCategory, nil];
//        NSArray *messageListWithContactsSorted = [messageListWithContacts sortedArrayUsingDescriptors:sortDescriptors];
//        return (NSMutableArray*)messageListWithContactsSorted;
//    } else {
//        NSLog(@" NOT custom ordering");
//        NSArray *sortDescriptors = [NSArray arrayWithObjects: messageCategory,isMessage, nil];
//        NSArray *messageListWithContactsSorted = [messageListWithContacts sortedArrayUsingDescriptors:sortDescriptors];
//        return (NSMutableArray*)messageListWithContactsSorted;
//    }
//}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
        return self.segmentList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProgramDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    segment = [self.segmentList objectAtIndex:indexPath.row];
    [cell configSegmentCell:segment];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    
//    if(CGRectContainsPoint(self.linkLabel.frame, theLocationOfTheTouch)){
        //the subview has been touched, do what you want
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
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        segment = self.segmentList[indexPath.row];
        MessageTableViewController *viewController = [segue destinationViewController];
        viewController.selectedSegment = segment;
        viewController.selectedLink = self.selectedLink;
        viewController.selectedProgram = self.selectedProgram;
        
        
    }
    if ([segue.identifier isEqualToString:@"showWebViewController"]){
        WebViewController *webViewController =  [segue destinationViewController];
        webViewController.selectedLink = self.selectedLink;
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



@end
