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
@property (nonatomic, retain) NSString *campaignID;
@property (nonatomic) int16_t mood;
@property (nonatomic, retain) NSString *messageText;
@property (nonatomic, retain) NSString *messageImage;
@property (nonatomic, retain) NSString *messageTarget;
@property (nonatomic, retain) NSString *messageCategory;

@end