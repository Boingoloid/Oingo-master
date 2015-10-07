//
//  EmailItem.h
//  Oingo
//
//  Created by Matthew Acalin on 10/6/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmailItem : NSObject

@property (nonatomic) NSTimeInterval date;
@property (nonatomic, retain) NSString *segmentID;
@property (nonatomic, retain) NSString *messageText;
//@property (nonatomic, retain) NSString *messageImage;
@property (nonatomic, retain) NSString *messageCategory;
@property (nonatomic, retain) NSString *emailRecipients;
@property (nonatomic, retain) NSString *linkToEmail;
@property (nonatomic, retain) NSString *emailSubject;
@end
