//
//  SegmentDataViewController.m
//  Oingo
//
//  Created by Matthew Acalin on 12/2/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "SegmentDataViewController.h"

@interface SegmentDataViewController ()


@end

@implementation SegmentDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.segmentedControl.selectedSegmentIndex = 1;
    
//    UIButton *transparentButton = [[UIButton alloc] init];
//    [transparentButton setFrame:CGRectMake(0,0, 50, 40)];
//    [transparentButton setBackgroundColor:[UIColor whiteColor]];
//    [transparentButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationController.navigationBar addSubview:transparentButton];
//    
    // Do any additional setup after loading the view.
}

//- (IBAction)backAction:(id)sender {
//    NSLog(@"back button transparent");
//    [self.navigationController popViewControllerAnimated:NO];
//    [self.navigationController popViewControllerAnimated:NO];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)segmentedControlClick:(id)sender {
    if(self.segmentedControl.selectedSegmentIndex == 0){
        [self.navigationController popViewControllerAnimated:NO];
    } else {
        
    }
}

@end
