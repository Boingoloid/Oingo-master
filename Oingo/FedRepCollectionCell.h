//
//  FedRepCollectionCell.h
//  Oingo
//
//  Created by Matthew Acalin on 12/21/15.
//  Copyright © 2015 Oingo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FedRepCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *squareImageView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (nonatomic) BOOL isSelected;
@property (weak, nonatomic) IBOutlet UIImageView *selectionHighlightImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstName;


-(FedRepCollectionCell*)configCollectionCell:(NSMutableDictionary*)dictionary;

@end
