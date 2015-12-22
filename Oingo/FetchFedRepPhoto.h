//
//  FetchFedRepPhoto.h
//  Oingo
//
//  Created by Matthew Acalin on 12/21/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FedRepCollectionCell.h"
#import "FederalRepActionDashboardViewController.h"

@interface FetchFedRepPhoto : NSObject

@property(nonatomic) FedRepCollectionCell *cell;
@property(nonatomic) FederalRepActionDashboardViewController *viewController;

-(void)fetchPhotos:(NSArray*)array;

@end
