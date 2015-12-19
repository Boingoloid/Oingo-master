//
//  FetchDataFedReps.h
//  Oingo
//
//  Created by Matthew Acalin on 12/18/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FederalRepActionDashboardViewController.h"

@interface FetchDataFedReps : NSObject

@property (nonatomic) FederalRepActionDashboardViewController *viewController;

-(void)fetchRepsWithZip:zipCode;

@end
