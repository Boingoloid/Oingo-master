//
//  ActionDashboardTableViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 12/11/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "ActionDashboardTableViewController.h"
#import "LocalRepActionTableViewCell.h"
#import "FederalRepActionDashboardViewController.h"

@interface ActionDashboardTableViewController () <UIGestureRecognizerDelegate,CLLocationManagerDelegate>

@end

@implementation ActionDashboardTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Format the header view
    self.tableHeaderView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.tableHeaderView.layer.borderWidth = 1;
    self.tableHeaderView.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    self.tableHeaderView.layer.cornerRadius = 3;
    self.tableHeaderView.clipsToBounds = YES;
    
    // Hide separators in table
    self.tableView.separatorColor = [UIColor clearColor];
    
    // Assign header label values
    self.segmentTitleLabel.text = [self.selectedSegment valueForKey:@"segmentTitle"];
    self.programTitleLabel.text = [NSString stringWithFormat:@"%@ / episode %@",[self.selectedProgram valueForKey:@"programTitle"],[self.selectedSegment valueForKey:@"episode"]];
    
    
    // Get Action data from Parse!
    [self fetchActionsForSegment];
    
    // Get Sent Action data from Parse!
    if([PFUser currentUser]){
        [self fetchSentActionsForSegment];
    }
    
    // Create gesture recognizer
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture:)]; //connect recognizer to action method.
    tapRecognizer.delegate = self;
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [tapRecognizer setCancelsTouchesInView:NO];
    [self.tableView addGestureRecognizer:tapRecognizer];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    UITableView *tableView = (UITableView *)gestureRecognizer.view;
    CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view];
    if ([tableView indexPathForRowAtPoint:p]) {
        return YES;
        
    }
    return NO;
}

- (void)respondToTapGesture:(UITapGestureRecognizer *)tap {
    //*******
    //This is what we use for user touches in the cells
    //It grabs point coordinate of touch as finger lifted
    //******************
    
    if (UIGestureRecognizerStateEnded == tap.state) {
        // Collect data about tap location
        UITableView *tableView = (UITableView *)tap.view;
        CGPoint p = [tap locationInView:tap.view];
        NSIndexPath* indexPath = [tableView indexPathForRowAtPoint:p];
        NSLog(@"position with indexpath:%@",indexPath);
        
//        
//        // Deselect the row
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        
        // Gathering info about cell touched
        UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        CGPoint pointInCell = [tap locationInView:cell];

        
        //if(CGRectContainsPoint(cell.frame, pointInCell)) {
            
            [self performSegueWithIdentifier:@"showBuildMessage" sender:self];
        //}
    }
}




#pragma mark - Fetching Data

-(void) fetchActionsForSegment {
    //[FetchDataParse fetchActionsForSegment:self.selectedSegment];
    //NSLog(@"selectedSegment:%@",self.selectedSegment);
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"segmentID" equalTo:[self.selectedSegment valueForKey:@"segmentID"]];
    [query orderByDescending:@"actionCategory"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.actionsForSegment = objects;
                [self createActionOptionsList:objects];
                //NSLog(@"Actions: %@",self.actionsForSegment);
                [self.tableView reloadData];
            });
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void) fetchSentActionsForSegment {
    PFUser *currentUser = [PFUser currentUser];
    
    //get message data for segment menu
    PFQuery *query = [PFQuery queryWithClassName:@"sentMessages"];
    [query whereKey:@"segmentID" equalTo:[self.selectedSegment valueForKey:@"segmentID"]];
    [query whereKey:@"userObjectID" equalTo:currentUser.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.sentActionsForSegment = objects;
                NSUInteger count = [objects count];
                self.countUsersLabel.text = [NSString stringWithFormat:@"%ld",count];
                self.countThoughtsLabel.text = [NSString stringWithFormat:@"%ld",count * 3];
                NSLog(@"count:%ld",count);
                //NSLog(@"sentActions: %@",self.sentActionsForSegment);
            });
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


#pragma mark - Data Manipulation Action Options List


-(void) createActionOptionsList:(NSArray*)objects{
    //NSLog(@"creating options list");
    NSString *category = @"";
    NSMutableArray *actionOptionsArray = [[NSMutableArray alloc]init];
    
    // Loop, create unique list of actionCategories
    for (NSDictionary *dictionary in objects){
        //NSLog(@"print dict:%@",dictionary);
        NSString *dictionaryCategory = [dictionary valueForKey:@"actionCategory"];
        if (![category isEqualToString:dictionaryCategory]){
            category = dictionaryCategory;
            [actionOptionsArray addObject:dictionary];
        }
    }
    
    
    //Pull Regulator actionCategory to top
    NSUInteger indexReg = [actionOptionsArray indexOfObjectPassingTest:
                        ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                            return [[dict objectForKey:@"actionCategory"] isEqual:@"Regulator"];
                        }];
    if(indexReg == NSNotFound){
        NSLog(@"did not find 'regulator' line");
    } else {
        NSDictionary *movingActionDict = [actionOptionsArray objectAtIndex:indexReg];
        [actionOptionsArray insertObject:movingActionDict atIndex:0];
        [actionOptionsArray removeObjectAtIndex:indexReg+1];
    }

    
    //Pull Local Represetative actionCategory to top
    NSUInteger index = [actionOptionsArray indexOfObjectPassingTest:
                        ^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                            return [[dict objectForKey:@"actionCategory"] isEqual:@"Local Representative"];
                        }];
    if(index == NSNotFound){
        NSLog(@"did not find 'local rep' line");
    } else {
        NSDictionary *movingActionDict = [actionOptionsArray objectAtIndex:index];
        [actionOptionsArray insertObject:movingActionDict atIndex:0];
        [actionOptionsArray removeObjectAtIndex:index+1];
        //NSLog(@"actionOptionsArray Reorder :%@",actionOptionsArray);
    }
    
    self.actionOptionsArray = actionOptionsArray;
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

    return [self.actionOptionsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Create cell
    LocalRepActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Turn off selection highlighting
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Configure the cell...
    NSMutableDictionary *actionDict = [[NSMutableDictionary alloc]init];
    actionDict = [self.actionOptionsArray objectAtIndex:indexPath.row];
    return [cell configLocalRepActionCell:(NSMutableDictionary*)actionDict];
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showBuildMessage"]){
        FederalRepActionDashboardViewController *fedRepActionVC = segue.destinationViewController;
        fedRepActionVC.tableViewController = self;
        fedRepActionVC.selectedProgram = self.selectedProgram;
        fedRepActionVC.selectedSegment = self.selectedSegment;
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end

// sample http request, rest-api call ----------------------------------
//    - (IBAction)fetchGreeting;
//    {
//        NSURL *url = [NSURL URLWithString:@"http://rest-service.guides.spring.io/greeting"];
//        NSURLRequest *request = [NSURLRequest requestWithURL:url];
//        [NSURLConnection sendAsynchronousRequest:request
//                                           queue:[NSOperationQueue mainQueue]
//                               completionHandler:^(NSURLResponse *response,
//                                                   NSData *data, NSError *connectionError)
//         {
//             if (data.length > 0 && connectionError == nil)
//             {
//                 NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
//                                                                          options:0
//                                                                            error:NULL];
//                 self.greetingId.text = [[greeting objectForKey:@"id"] stringValue];
//                 self.greetingContent.text = [greeting objectForKey:@"content"];
//             }
//         }];
//    }
//

//    [[[FBSDKGraphRequest alloc]
//      initWithGraphPath:@"me/feed"
//      parameters: parameters
//      HTTPMethod:@"POST"]
//     //list of parameters: https://developers.facebook.com/docs/graph-api/reference/
//     //
//
//     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//         if (!error) {
//             NSLog(@"Post id:%@", result[@"id"]);
//             [self saveSentMessageSegment:result[@"id"]];
//             [self.messageTableViewController.navigationController popViewControllerAnimated:YES];
//         }
//     }];


// Uncomment the following line to preserve selection between presentations.
// self.clearsSelectionOnViewWillAppear = NO;

// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
// self.navigationItem.rightBarButtonItem = self.editButtonItem;
