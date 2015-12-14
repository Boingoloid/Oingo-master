//
//  ActionDashboardTableViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 12/11/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "ActionDashboardTableViewController.h"
#import "LocalRepActionTableViewCell.h"

@interface ActionDashboardTableViewController ()

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
    
    [self fetchActionsForSegment];
    
    if([PFUser currentUser]){
        [self fetchSentActionsForSegment];
    }
}


-(void) fetchActionsForSegment {
    NSLog(@"selectedSegment:%@",self.selectedSegment);
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"segmentID" equalTo:[self.selectedSegment valueForKey:@"segmentID"]];
    [query orderByDescending:@"actionCategory"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.actionsForSegment = objects;
                [self createActionOptionsList:objects];
                NSLog(@"Actions: %@",self.actionsForSegment);
                [self.tableView reloadData];
            });
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void) createActionOptionsList:(NSArray*)objects{
    NSLog(@"creating options list");
    NSString *category = @"";
    NSMutableArray *actionOptionsArray = [[NSMutableArray alloc]init];
    
    // go through the array and every time cat changes, pull out the message Category
    for (NSDictionary *dictionary in objects){
        NSLog(@"print dict:%@",dictionary);
        NSString *dictionaryCategory = [dictionary valueForKey:@"actionCategory"];
        if (![category isEqualToString:dictionaryCategory]){
            category = dictionaryCategory;

            [actionOptionsArray addObject:dictionary];
        }
        
    }
    NSLog(@"action array:%@",actionOptionsArray);
    
    
    
    
    
    // next steps
//    1) put local rep first
//    2) change cell headline based on action cat
    
    
    
    // Search if get location cell is there and if so delete it
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
        NSLog(@"actionOptionsArray Reorder :%@",actionOptionsArray);
    }
    

    
    
    

    self.actionOptionsArray = actionOptionsArray;
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
                //NSLog(@"sentActions: %@",self.sentActionsForSegment);
            });
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
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
    LocalRepActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
