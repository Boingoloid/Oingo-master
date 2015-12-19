//
//  FederalRepActionDashboardViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 12/17/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "FederalRepActionDashboardViewController.h"
#import "FedRepCell.h"
#import "FetchDataFedReps.h"

@interface FederalRepActionDashboardViewController () <UITextViewDelegate,UITableViewDelegate,UITableViewDataSource>

@end

@implementation FederalRepActionDashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    FetchDataFedReps *fetchData = [[FetchDataFedReps alloc]init];
    fetchData.viewController = self;
    [fetchData fetchRepsWithZip:@"94107"];
    
    self.textView.delegate=self;
    
    self.textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.textView.layer.borderWidth = 0;
    self.textView.layer.cornerRadius = 15;
    self.textView.clipsToBounds = YES;

    
    
    self.pushthoughtTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.pushthoughtTextView.layer.borderWidth = 1;
    self.pushthoughtTextView.layer.cornerRadius = 3;
    self.pushthoughtTextView.clipsToBounds = YES;
    
    
    
    self.otherOptionsLabel.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.otherOptionsLabel.layer.borderWidth = 1;
    self.otherOptionsLabel.layer.cornerRadius = 15;
    self.otherOptionsLabel.clipsToBounds = YES;
    // Do any additional setup after loading the view.
    
    
    self.tableView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
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
    

    return self.fedRepList.count;
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
    NSLog(@"FIRING");
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

@end
