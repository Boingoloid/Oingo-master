//
//  UpdateDefaults.h
//  Oingo
//
//  Created by Matthew Acalin on 7/9/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateDefaults : NSObject
-(void) updateLocationDefaultsFromUser;
-(void)saveCoordinatesToDefaultsWithLatitude:(double)latitude andLongitude:(double)longitude;
-(void)saveZipCodeToDefaultsWithZip:zipCode;
-(void)saveLocationDefaultsToUser;
-(void)deleteCoordinates;
@end
