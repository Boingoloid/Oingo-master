//
//  MessagePanelTableViewCell.h
//  Oingo
//
//  Created by Matthew Acalin on 11/13/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessagePanelViewController.h"

@interface MessagePanelTableViewCell : UITableViewCell

@property (nonatomic) MessagePanelViewController *messagePanelViewController;
@property (weak, nonatomic) IBOutlet UILabel *messageTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageCountLabel;

@property (nonatomic) NSArray *tableArray;

@property (nonatomic) NSMutableArray *hashtagList;
@property (nonatomic) NSArray *messageOptionsList;
@property (nonatomic) NSArray *sentMessagesForSegment;
-(void)configureCellWithData:(NSDictionary*)dataDict;
//-(void)configureCellWithData:(NSArray*)tableData atIndexPath:indexPath;



@end
