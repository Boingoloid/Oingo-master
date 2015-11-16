//
//  MakePhoneCallAPI.m
//  Oingo
//
//  Created by Matthew Acalin on 6/26/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import "MakePhoneCallAPI.h"
#import "CongressionalMessageItem.h"
#import "MessageItem.h"


@implementation MakePhoneCallAPI

-(void) dialPhoneNumber:(NSURL*)phoneUrl {
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        
        NSString *alertTitle = @"Phone Call";
        NSString *alertMessage = @"Remember to state your name and your sentiment.  Would you like to call?";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
        
        //Add cancel button
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSLog(@"Cancel action");
        }];
        [alertController addAction:cancelAction];
        
        //Add OK action button
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            [[UIApplication sharedApplication] openURL:phoneUrl];
            [self savePhoneCall:phoneUrl];
            NSLog(@"OK action");
        }];
        [alertController addAction:okAction];
        
        [self.messageTableViewController presentViewController:alertController animated:YES completion:nil];
    } else{
        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [calert show];
    }
}
-(void)savePhoneCall:(NSURL*)phoneURL{
    //  SAVING MESSAGE DATA TO PARSE
    PFUser *currentUser = [PFUser currentUser];
    
    PFObject *sentMessageItem = [PFObject objectWithClassName:@"sentMessages"];
    [sentMessageItem setObject:@"phoneCall" forKey:@"messageType"];
    [sentMessageItem setObject:[phoneURL absoluteString] forKey:@"phoneNumber"];
    [sentMessageItem setObject:[self.selectedSegment valueForKey:@"segmentID"] forKey:@"segmentID"];
    [sentMessageItem setObject:[currentUser valueForKey:@"username"] forKey:@"username"];
    NSString *userObjectID = currentUser.objectId;
    [sentMessageItem setObject:userObjectID forKey:@"userObjectID"];
    
    //if segment then skip, else don't
    if ([self.selectedContact isKindOfClass:[CongressionalMessageItem class]]) {
        NSLog(@"Saving congressional Message Item Class");
        NSString *bioguide_id = [self.selectedContact valueForKey:@"bioguide_id"];
        NSString *fullName = [self.selectedContact valueForKey:@"fullName"];
        [sentMessageItem setObject:bioguide_id forKey:@"contactID"];
        [sentMessageItem setObject:fullName forKey:@"contactName"];
    } else {
        NSLog(@"Regular Contact Item Class");
        NSString *contactID = [self.selectedContact valueForKey:@"contactID"];
        NSString *targetName = [self.selectedContact valueForKey:@"targetName"];
        [sentMessageItem setObject:contactID forKey:@"contactID"];
        [sentMessageItem setObject:targetName forKey:@"contactName"];
    }
    
    
    [sentMessageItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //save sent message to parse
        if(error){
            NSLog(@"error, message not saved");
        }
        else {
            NSLog(@"no error, message saved");
            [self.messageTableViewController viewDidLoad];
        }
    }];
    
}
@end
