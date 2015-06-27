//
//  Program.h
//  Oingo
//
//  Created by Matthew Acalin on 5/6/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ENUM(int16_t, THDiaryEntryMood) {
    THDiaryEntryMoodGood = 0,
    THDiaryEntryMoodAverage = 1,
    THDiaryEntryMoodBad = 2
};

@interface Program : NSObject

@property (nonatomic) NSTimeInterval date;
@property (nonatomic, retain) NSString *programTitle;
@property (nonatomic) int16_t mood;
@property (nonatomic, retain) NSString *programDescription;
@property (nonatomic, retain) NSString *programImage;



@end
