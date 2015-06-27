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
#import "Campaign.h"
#import "Program.h"
#import "MessageTableViewController.h"
#import <UIKit/UIKit.h>
#import "WebViewController.h"


@interface ProgramDetailTableViewController () <UIGestureRecognizerDelegate>

@end

@implementation ProgramDetailTableViewController

Campaign *campaign;

- (void) viewWillAppear:(BOOL)animated {


    
//Separator style for tableview
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    //Pulling data for tablecell from Parse (filtered by selected program i.e. List of all associated with the Daily Show.)
    PFQuery *query = [PFQuery queryWithClassName:@"Campaigns"];
    
    [query whereKey:@"programTitle" equalTo:[self.selectedProgram valueForKey:@"programTitle"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.campaignList = objects;
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
//        NSLog(@"%@",NSStringFromCGPoint(p));
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
        return self.campaignList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProgramDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    campaign = [self.campaignList objectAtIndex:indexPath.row];
    [cell configCampaignCell:campaign];
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
        campaign = self.campaignList[indexPath.row];
        MessageTableViewController *viewController = [segue destinationViewController];
        viewController.selectedCampaign = campaign;
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
