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


@interface ProgramsTableViewController () <UISearchResultsUpdating,UISearchControllerDelegate,UISearchDisplayDelegate, UISearchBarDelegate>
//- (IBAction)uploadPhotos:(id)sender;  //Bulk congress photo upload, don't delete

@end

@implementation ProgramsTableViewController

Program *program;
NSUInteger numberOfRows = 0;


-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;  // optional
    self.navigationController.navigationBar.translucent = YES;

    
    


}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    [self.searchController setDelegate:self];
    
    

    self.searchController.dimsBackgroundDuringPresentation = NO;

    
    [self.searchController.searchBar setDelegate:self];
    self.searchController.searchBar.scopeButtonTitles = @[@"Title",@"Network"];
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    self.searchController.searchBar.barTintColor = [UIColor blackColor];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewdidload being called");
    
    PFQuery *query = [PFQuery queryWithClassName:@"Programs"];
//    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];  //This causes crash
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.programListFromDatabase = objects;
            self.programList = objects;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

}

typedef enum
{
    searchScopeProgramTitle = 0,
    searchScopeNetwork = 1
} ProgramListSearchScope;

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    
    [self searchForText:searchString scope:(int)self.searchController.searchBar.selectedScopeButtonIndex];
//    [self searchForText:searchString];
    [self.searchController.searchBar sizeToFit];
    [self.tableView reloadData];
    
}

//- (void)searchForText:(NSString *)searchText
- (void)searchForText:(NSString *)searchText scope:(ProgramListSearchScope)scopeOption
{
    if (self.programList)
    {
        NSString *predicateFormat = @"%K BEGINSWITH [cd] %@";
        NSString *searchAttribute = @"programTitle";
        
        if (scopeOption == 1)
        {
            searchAttribute = @"programNetwork";
        }
        
        NSLog(@"searchTest:%@",searchText);
        
        NSArray *filteredArray;
        
        if([searchText  isEqual: @""]){
            NSLog(@"YES search is empty");
            filteredArray = self.programListFromDatabase;
        } else {
            filteredArray = [self.programListFromDatabase filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:predicateFormat,searchAttribute, searchText]];
        }
        self.programList = (NSMutableArray*)filteredArray;
    }
}


//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
//    searchBar.showsScopeBar = YES;
//    [searchBar sizeToFit];
//    [searchBar setShowsCancelButton:YES animated:YES];
//    
//    return YES;
//}
//
//- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
//    searchBar.showsScopeBar = NO;
////    [searchBar sizeToFit];
////    [searchBar setShowsCancelButton:NO animated:YES];
//    
//    return YES;
//}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

        return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return self.programList.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProgramsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        program = [self.programList objectAtIndex:indexPath.row];
        [cell configProgramCell:program indexPath:indexPath];
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

#pragma mark - Data Entry
// DON'T DELETE - CONGRESS BULK UPLOAD
// Method for uploading congress photos to Parse.
// Add the below method to a button and run.
//- (IBAction)uploadPhotos:(id)sender {
//    
//    NSLog(@"hey");
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
//    NSArray *contents = [fileManager contentsOfDirectoryAtURL:bundleURL
//                                   includingPropertiesForKeys:@[]
//                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
//                                                        error:nil];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension ENDSWITH 'jpg'"];
//    for (NSString *path in [contents filteredArrayUsingPredicate:predicate]) {
//        NSLog(@"path name:%@",path);
//        
//        NSString *theFileName = [path lastPathComponent];
//        NSString *bioguideID = [[path lastPathComponent] stringByDeletingPathExtension];
//        
//        NSLog(@"the file name:%@",theFileName);
//        NSLog(@"bioguide:%@",bioguideID);
//        
//        UIImage *imageFile = [UIImage imageNamed:theFileName];
//        NSLog(@"image:%@",imageFile);
//        
//        NSData *imageData = UIImageJPEGRepresentation(imageFile, 1.0f);
//        PFFile *imageFileParse = [PFFile fileWithName:theFileName data:imageData];
//        
//        PFObject *imageObject = [PFObject objectWithClassName:@"CongressImages"];
//        imageObject[@"bioguideID"] = bioguideID;
//        imageObject[@"imageName"] = theFileName;
//        imageObject[@"imageFile"] = imageFileParse;
//        [imageObject saveInBackground];
//        
//        [NSThread sleepForTimeInterval:1];
//    }
//}


@end
