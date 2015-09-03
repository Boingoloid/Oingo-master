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
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel:%@",phoneNumber]];
    //code for making call, can't test in simulator
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Fill in message for guidance on making phone call." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [calert show];
    } else
    {
        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [calert show];
    }

}
@end
