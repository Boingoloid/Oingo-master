//
//  MakePhoneCallAPI.m
//  Oingo
//
//  Created by Matthew Acalin on 6/26/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "MakePhoneCallAPI.h"
#import "MessageTableViewController.h"


@implementation MakePhoneCallAPI

-(void) dialPhoneNumber:(NSString*)phoneNumber {
//    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel:%@",phoneNumber]];
//    //code for making call, can't test in simulator
//    
//    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
//        
//        NSString *alertTitle = @"Phone Call";
//        NSString *alertMessage = @"Remember to state your name and your sentiment.  Would you like to call?";
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//            NSLog(@"Cancel action");
//        }];
//        [alertController addAction:cancelAction];
//
//        //Add OK action button
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//        NSLog(@"OK action");
//        
//            
//            
//        }];
//        [alertController addAction:okAction];
//        
//        [self presentViewController:alertController animated:YES completion:nil];
//    
//    } else
//    {
//        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
//        [calert show];
//    }

}
@end
