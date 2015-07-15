//
//  Segment.h
//  Oingo
//
//  Created by Matthew Acalin on 5/5/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Segment : NSObject

@property (nonatomic) NSTimeInterval date;
@property (nonatomic, retain) NSString *programTitle;
@property (nonatomic) int16_t mood;
@property (nonatomic, retain) NSString *purposeSummary;
@property (nonatomic) NSString *linkToContent;
@property (nonatomic, retain) NSString *segmentImage;


@end
