//
//  UpdateDefaults.h
//  Oingo
//
//  Created by Matthew Acalin on 7/9/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateDefaults : NSObject
// Default BOOL
+(BOOL)isLocationInDefaults;
+(BOOL)isZipCodeInDefaults;
+(BOOL)isCoordinatesInDefaults;

// User BOOL
+(BOOL)isLocationInUser;


+(void)updateLocationDefaultsFromUser;
+(NSString*)getZipFromDefaults;
-(void)saveCoordinatesToDefaultsWithLatitude:(double)latitude andLongitude:(double)longitude;
-(void)saveZipCodeToDefaultsWithZip:zipCode;
+(void)saveLocationDefaultsToUser;
-(void)saveMessageListWithCongressDefault:(NSArray*)messageList;
-(void)deleteMessageListFromCongressDefault;
+(void)deleteCoordinates;
@end
