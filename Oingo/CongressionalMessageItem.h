//
//  CongressionalMessageItem.h
//  Oingo
//
//  Created by Matthew Acalin on 6/22/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface CongressionalMessageItem : NSObject;


@property (nonatomic, retain) NSString *messageImageString;
@property (nonatomic, retain) NSString *bioguide_id;
//@property (nonatomic) NSTimeInterval date;
@property (nonatomic, retain) NSString *segmentID;
@property (nonatomic, retain) NSString *messageCategory;
@property (nonatomic, retain) NSString *messageText;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *fullName;
@property(nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, retain) NSString *inOffice;
@property (nonatomic, retain) NSString *gender;
@property (nonatomic, retain) NSString *birthday;
@property (nonatomic, retain) NSString *chamber;
@property (nonatomic, retain) NSString *district;
@property (nonatomic, retain) NSString *stateName;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *leadershipRole;
@property (nonatomic, retain) NSString *isMessage;
@property (nonatomic, retain) NSString *orderInCategory;
@property (nonatomic, assign) NSString *isGetLocationCell;


////social identifiers and contact info
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *website;
@property (nonatomic, retain) NSString *openCongressEmail;
@property (nonatomic, retain) NSString *youtubeID;
@property (nonatomic, retain) NSString *facebookID;
@property (nonatomic, retain) NSString *twitterID;
@property (nonatomic, retain) NSString *contactForm;
//will be separated in a different call and load later
//this should have a default photo

@end
