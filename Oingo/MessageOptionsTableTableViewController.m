//
//  MessageOptionsTableTableViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 5/29/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "MessageOptionsTableTableViewController.h"
#import "MessageTableViewController.h"
#import "MessageTableViewCell.h"

@interface MessageOptionsTableTableViewController ()

@end

@implementation MessageOptionsTableTableViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSLog(@"self.menulist%@",self.menuList);
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell1"];
    NSLog(@"self.messageOptionsList:%@",self.messageOptionsList);
    
    NSString *selectedCategory= [self.messageTableViewController categoryForSection:self.originIndexPath.section];
    NSMutableArray *messageTextList = [[NSMutableArray alloc]init];


    for (NSDictionary *dictionary in self.messageOptionsList) {
        NSString *messageCategory = [dictionary valueForKey:@"messageCategory"];
        if([messageCategory isEqualToString:selectedCategory]) {
            [messageTextList addObject:dictionary];
        }
    }

    self.messageOptionsListFiltered = messageTextList;
    
    NSLog(@"data as it's coming in index:%@, category:%@,  message text list Filtered%@",self.originIndexPath, self.category,messageTextList);
    


    self.tableView.estimatedRowHeight = 50.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    
    NSLog(@"self.menulist first object %@",[self.menuList firstObject]);
    NSLog(@"self.menulist 2nd object %@",[self.menuList objectAtIndex:1]);
    NSLog(@"messageoptions first object %@",[self.messageOptionsList firstObject]);
    NSLog(@"messageOptions second object %@",[self.messageOptionsList objectAtIndex:1]);

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.messageOptionsListFiltered count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
    // Configure the cell...
    NSString *messageText = [[self.messageOptionsListFiltered objectAtIndex:[indexPath row]] valueForKey:@"messageText"];
    cell.textLabel.text = messageText;
    return cell;
}



-(void)tableView:(UITableView *)tableView  didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *selectedMessage = [[self.messageOptionsListFiltered objectAtIndex:[indexPath row]] valueForKey:@"messageText"];
    NSDictionary *unloadMessage = [self.messageTableViewController.messageList  objectAtIndex:[self.originRowIndex intValue]];
//    
//    NSLog(@"self.originrowindex:%@",self.originRowIndex);
//    NSLog(@"unload message%@",unloadMessage);
//    NSLog(@"message options%@",self.messageOptionsListFiltered);
    
    [self.messageOptionsListFiltered insertObject:unloadMessage atIndex:1];
    [[self.messageTableViewController.menuList objectAtIndex:[self.originRowIndex intValue]] setValue:selectedMessage forKey:@"messageText"];
    NSLog(@"showing the indexpath selected:%@, to be changed:%@, and the selected message:%@",indexPath,self.originIndexPath,selectedMessage);
    
//    NSLog(@"self.messageOptionFiltered %@",self.messageOptionsListFiltered);
//    NSLog(@"self.menulist first object %@",[self.menuList firstObject]);
//    NSLog(@"self.menulist 2nd object %@",[self.menuList objectAtIndex:1]);
//    NSLog(@"messageoptions first object %@",[self.messageOptionsList firstObject]);
//    NSLog(@"messageOptions second object %@",[self.messageOptionsList objectAtIndex:1]);
    

    [self.navigationController popViewControllerAnimated:YES];
[self.messageTableViewController.tableView reloadData];
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
