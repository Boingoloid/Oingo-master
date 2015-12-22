//
//  FedRepCollectionCell.m
//  Oingo
//
//  Created by Matthew Acalin on 12/21/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "FedRepCollectionCell.h"

@implementation FedRepCollectionCell


-(FedRepCollectionCell*)configCollectionCell:(NSMutableDictionary*)dictionary{
    
    // Full name
    NSString *nickName = [dictionary valueForKey:@"nickname"];
    NSString *firstName = [dictionary valueForKey:@"first_name"];
    NSString *lastName = [dictionary valueForKey:@"last_name"];
    NSString *fullName;
    NSLog(@"%@ %@ %@ %@",nickName,firstName,lastName,fullName);
    if(![dictionary valueForKey:@"nickName"]){
        fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
    } else {
        fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
    }
    self.name.text = [NSString stringWithFormat:@"%@ /",fullName];
    
    // Title and Placeholder Image load based on chamber
    NSString *chamber = [dictionary valueForKey:@"chamber"];
    NSString *state = [dictionary valueForKey:@"state"];
    NSString *district = [dictionary valueForKey:@"district"];
    if([chamber isEqualToString:@"senate"]) {
        self.title.text = [NSString stringWithFormat:@"Senator,%@",state];
        self.imageView.image = [UIImage imageNamed:@"Seal_of_Senate_Cropped.png"];
    } else {
        self.title.text = [NSString stringWithFormat:@"Rep, %@ / d:%@",state,district];
        self.imageView.image = [UIImage imageNamed:@"Seal_of_Congress_Cropped.png"];
    }
    
    // Load Rep Image
    self.imageView.image = [dictionary valueForKey:@"image"];
    
    // TwitterID
//    NSString *twitterID = [actionDict valueForKey:@"twitter_id"];
//    self.twitterID.text = [NSString stringWithFormat:@"@%@",twitterID];

    return self;
}


@end