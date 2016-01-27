//
//  EmailViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 1/24/16.
//  Copyright © 2016 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailViewController : UIViewController

@property (nonatomic) NSMutableDictionary *selectedSegment;
@property (nonatomic) NSMutableDictionary *selectedProgram;
@property (nonatomic) NSMutableDictionary *selectedAction;
@property (nonatomic) NSMutableArray *fedRepList;
@property (nonatomic) NSMutableArray *collectionData;
@property (nonatomic) NSString *sentEmailSubject;
@property (nonatomic) NSString *sentEmailBody;

@property (nonatomic) BOOL *isLinkIncluded;
- (void)showMailPickerWithAction:(NSMutableDictionary*)selectedAction;

@end
