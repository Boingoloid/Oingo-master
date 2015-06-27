//
//  EmailComposerViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 6/26/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailComposerViewController : UIViewController
- (void)showMailPicker:(NSString*)email withMessage:(NSString*)message;
@end
