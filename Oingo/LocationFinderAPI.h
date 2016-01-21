//
//  LocationFinderAPI.h
//  Oingo
//
//  Created by Matthew Acalin on 7/2/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageTableViewController.h"

@interface LocationFinderAPI : NSObject
@property(nonatomic) MessageTableViewController *viewController;
-(void) findUserLocation;
@end
