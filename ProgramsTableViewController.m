//
//  ProgramsTableViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 4/25/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "ProgramsTableViewController.h"
#import "ProgramsTableViewCell.h"
#import <Parse/Parse.h>
#import "PFTwitterUtils+NativeTwitter.h"
#import "ProgramDetailTableViewController.h"
#import "ProgramDetailTableViewCell.h"
#import "Program.h"


@interface ProgramsTableViewController ()


@end

@implementation ProgramsTableViewController

Program *program;
BOOL isFinished = NO;
NSUInteger numberOfRows = 0;


-(void)viewWillAppear:(BOOL)animated {
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;  // optional
    self.navigationController.navigationBar.translucent = YES;

    PFQuery *query = [PFQuery queryWithClassName:@"Programs"];
//    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];  //This causes crash
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.programList = objects;
            dispatch_async(dispatch_get_main_queue(), ^{
                isFinished = YES;
                [self.tableView reloadData];
            });
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    //isFinished BOOL used to flag when async query had returned data.
    if (!isFinished) {
        return 0;
    } else {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    if (!isFinished) {
        return 0;
    } else {
        return self.programList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProgramsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

        program = [self.programList objectAtIndex:indexPath.row];
        [cell configProgramCell:program indexPath:indexPath isFinished:isFinished];
        return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:0 animated:0];

            
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
    if ([segue.identifier isEqualToString:@"showProgramDetail"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow]; //get selected index#
        self.selectedProgram = self.programList[indexPath.row];
        ProgramDetailTableViewController *viewController = [segue destinationViewController];
        viewController.selectedProgram = self.selectedProgram;
    }
}

@end
