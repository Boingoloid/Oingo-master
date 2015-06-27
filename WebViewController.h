//
//  WebViewController.h
//  Oingo
//
//  Created by Matthew Acalin on 5/21/15.
//  Copyright (c) 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property(nonatomic) NSString *selectedLink;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
