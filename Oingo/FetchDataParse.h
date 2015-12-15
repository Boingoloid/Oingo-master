//
//  FetchDataParse.h
//  Oingo
//
//  Created by Matthew Acalin on 12/14/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Segment.h"
#import "ActionDashboardTableViewController.h"

@interface FetchDataParse : NSObject

+(void)fetchActionsForSegment:(Segment*)segment;

@end
