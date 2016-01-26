//
//  FedRepCollectionCell.m
//  Oingo
//
//  Created by Matthew Acalin on 12/21/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import "FedRepCollectionCell.h"
#import <Parse/Parse.h>

@implementation FedRepCollectionCell


-(FedRepCollectionCell*)configCollectionCell:(NSMutableDictionary*)dictionary{
    NSLog(@"print dict in cell:%@",dictionary);
    self.selectionHighlightImageView.hidden = YES;

    NSNumber *number = [dictionary objectForKey:@"isSelected"];

    
    int intValue = [number intValue];
                  
    if(!intValue){
        self.selectionHighlightImageView.hidden = YES;
    }  else {
        self.selectionHighlightImageView.hidden = NO;
    }
    
    // Format selectionHighlight ImageView
    self.selectionHighlightImageView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    self.selectionHighlightImageView.layer.borderWidth = 2;
    self.selectionHighlightImageView.layer.shadowRadius = 5;
    self.selectionHighlightImageView.layer.shadowColor = [[UIColor whiteColor] CGColor];
    self.selectionHighlightImageView.layer.cornerRadius = 3;
    self.selectionHighlightImageView.clipsToBounds = YES;
    
    // Full name
    NSString *nickName = [dictionary valueForKey:@"nickname"];
    NSString *firstName = [dictionary valueForKey:@"first_name"];
    NSString *lastName = [dictionary valueForKey:@"last_name"];
    NSString *fullName;

    // Substitute nickName if they have one
    if(![dictionary valueForKey:@"nickName"]){
        firstName = [NSString stringWithFormat:@"%@",firstName];
        fullName = [NSString stringWithFormat:@"%@",lastName];
    } else {
        firstName = [NSString stringWithFormat:@"%@",nickName];
        fullName = [NSString stringWithFormat:@"%@",lastName];
    }
    self.firstName.text = firstName;
    self.name.text = fullName;
    
    
    // Title and Placeholder Image load based on chamber
    NSString *chamber = [dictionary valueForKey:@"chamber"];
    //NSString *state = [dictionary valueForKey:@"state"];
    //NSString *district = [dictionary valueForKey:@"district"];
    if([chamber isEqualToString:@"senate"]) {
        //self.title.text = [NSString stringWithFormat:@"Senator,%@",state];
        self.imageView.image = [UIImage imageNamed:@"Seal_of_Senate_Cropped.png"];
    } else {
        //self.title.text = [NSString stringWithFormat:@"Rep, %@ / d:%@",state,district];
        self.imageView.image = [UIImage imageNamed:@"Seal_of_Congress_Cropped.png"];
    }
    
    // Load Rep Image
    self.imageView.hidden = NO;
    self.squareImageView.hidden = YES;
    self.imageView.image = [dictionary valueForKey:@"image"];
    self.imageView.layer.cornerRadius = 2;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.borderColor = [[UIColor blackColor]CGColor];
    self.imageView.layer.borderWidth = 1;
    
    // Content View
    self.contentView.layer.borderColor = [[UIColor blackColor]CGColor];
    self.contentView.layer.borderWidth = 0;
    self.contentView.layer.cornerRadius = 3;
    self.contentView.clipsToBounds = YES;
    self.layer.cornerRadius = 3;
    self.clipsToBounds = YES;
    // TwitterID
//    NSString *twitterID = [actionDict valueForKey:@"twitter_id"];
//    self.twitterID.text = [NSString stringWithFormat:@"@%@",twitterID];
    
    NSString *category = [dictionary valueForKey:@"messageCategory"];
    NSString *objectCategory = [dictionary objectForKey:@"messageCategory"];
    NSLog(@"category:%@ - objectCategory:%@",category,objectCategory);


    if(![dictionary valueForKey:@"bioguide_id"]){
        self.imageView.hidden = YES;
        self.squareImageView.hidden = NO;
        
        self.firstName.text = [dictionary valueForKey:@"targetName"];
        self.name.text = [dictionary valueForKey:@"targetTitle"];

        
        PFFile *theImage = [dictionary objectForKey:@"messageImage"];
        NSData *imageData = [theImage getData];
        self.squareImageView.image = [UIImage imageWithData:imageData];
        
    }

    return self;
}


@end
