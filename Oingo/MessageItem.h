//
//  MessageItem.h
//  Oingo
//
//  Created by Matthew Acalin on 5/11/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageItem : NSObject

@property (nonatomic) NSTimeInterval date;
@property (nonatomic, retain) NSString *segmentID;
@property (nonatomic) int16_t mood;
@property (nonatomic, retain) NSString *messageText;
@property (nonatomic, retain) NSString *messageImage;
@property (nonatomic, retain) NSString *twitterID;
@property (nonatomic, retain) NSString *messageCategory;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *isGetLocationCell;
@property (nonatomic, retain) NSString *contactID;

@property (nonatomic) bool isTweetSent;


@end
