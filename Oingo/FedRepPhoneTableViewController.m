//
//  FedRepPhoneTableViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 1/19/16.
//  Copyright © 2016 Oingo Inc. All rights reserved.
//

#import "FedRepPhoneTableViewController.h"
#import "FedRepPhoneTableViewCell.h"

@interface FedRepPhoneTableViewController () <UIGestureRecognizerDelegate>

@end

@implementation FedRepPhoneTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.segmentedControlCommunicationType.selectedSegmentIndex = 1;
    
     [self.navigationItem setHidesBackButton:YES];
    
    
    // Format prompt label
    self.promptView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.promptView.layer.borderWidth = 0.5;
    self.promptView.layer.cornerRadius = 3;
    self.promptView.clipsToBounds = YES;
    
    // Create gesture recognizer
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture:)]; //connect recognizer to action method.
    tapRecognizer.delegate = self;
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [tapRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapRecognizer];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        //CGPoint pLocal = [tap locationInView:self.tableView];
        //self.selectedActionDict = [self.actionOptionsArray objectAtIndex:indexPath.row];
        //NSLog(@"selected Action dict:%@",self.selectedActionDict);
        
        if (CGRectContainsPoint(self.tableView.frame, p)){
            NSLog(@"tableView touched");
            FedRepPhoneTableViewCell *cell = (FedRepPhoneTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            CGPoint pointInCell = [tap locationInView:cell];

        
            if (CGRectContainsPoint(cell.phoneTouchArea.frame, pointInCell)){
                NSLog(@"phone area touched!!!!!!!");
                //NSDictionary *dictionary = [self.fedRepList objectAtIndex:indexPath.row];
                NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel://%@",cell.phoneNumberDC.text]];
                if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
                    [[UIApplication sharedApplication] openURL:phoneUrl];
                } else {
                    //phone not available
                    NSLog(@"phone not available");
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Call facility is not available." preferredStyle:UIAlertControllerStyleAlert];
                
                    //Add OK action button
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                            NSLog(@"OK action");
                    }];
                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
            }
        }
    }
}
//#pragma mark - Phone Call API
//-(void)showPhoneCallAlert:(NSString*)phoneString{
//    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel://%@",phoneString]];
//    
//    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
//        
//        NSString *alertTitle = @"Phone Call";
//        NSString *alertMessage = @"Remember to state your name and your sentiment.  Would you like to call?";
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
//        
//        //Add cancel button
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//            NSLog(@"Cancel action");
//        }];
//        [alertController addAction:cancelAction];
//        
//        //Add OK action button
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//            
//            [[UIApplication sharedApplication] openURL:phoneUrl];
//            [self savePhoneCall:phoneUrl];
//            
//            NSLog(@"OK action");
//            
//        }];
//        [alertController addAction:okAction];
//        
//        [self presentViewController:alertController animated:YES completion:nil];
//    } else{
//        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
//        [calert show];
//    }
//    
//    //    MakePhoneCallAPI *makePhoneCallAPI = [[MakePhoneCallAPI alloc] init];
//    //    makePhoneCallAPI.selectedProgram = self.selectedProgram;
//    //    makePhoneCallAPI.selectedSegment = self.selectedSegment;
//    //    makePhoneCallAPI.selectedContact = self.selectedContact;
//    //    [makePhoneCallAPI dialPhoneNumber:(NSURL*)phoneUrl];
//    
//}
//-(void)savePhoneCall:(NSURL*)phoneURL{
//    //  SAVING MESSAGE DATA TO PARSE
//    PFUser *currentUser = [PFUser currentUser];
//    
//    PFObject *sentMessageItem = [PFObject objectWithClassName:@"sentMessages"];
//    [sentMessageItem setObject:@"phoneCall" forKey:@"messageType"];
//    [sentMessageItem setObject:[phoneURL absoluteString] forKey:@"phoneNumber"];
//    [sentMessageItem setObject:[self.selectedSegment valueForKey:@"segmentID"] forKey:@"segmentID"];
//    [sentMessageItem setObject:[currentUser valueForKey:@"username"] forKey:@"username"];
//    NSString *userObjectID = currentUser.objectId;
//    [sentMessageItem setObject:userObjectID forKey:@"userObjectID"];
//    
//    //if segment then skip, else don't
//    if ([self.selectedContact isKindOfClass:[CongressionalMessageItem class]]) {
//        NSLog(@"Saving congressional Message Item Class");
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
//    
//    [sentMessageItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //save sent message to parse
//        if(error){
//            NSLog(@"error, message not saved");
//        }
//        else {
//            NSLog(@"no error, message saved");
//            [self viewDidLoad];
//        }
//    }];
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.fedRepList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FedRepPhoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSMutableDictionary *dictionary = [self.fedRepList objectAtIndex:indexPath.row];

    return [cell configCell:(NSMutableDictionary*)dictionary];

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (IBAction)segmentedControlCommunicationTypeClick:(id)sender {
    if(self.segmentedControlCommunicationType.selectedSegmentIndex == 0){
        [self.navigationController popViewControllerAnimated:NO];
    }
    self.tableViewController.segmentedControlCommunicationType.selectedSegmentIndex = 0;
}
@end
