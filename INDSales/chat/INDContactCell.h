//
//  INDContactCell.h
//  INDSales
//
//  Created by parth on 07/05/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INDContactCell : UITableViewCell
@property(strong,nonatomic)UIImageView* contactBubbleIV;
@property(strong,nonatomic)NSString* contactName;
@property(strong,nonatomic)UIButton* button;
@property(strong,nonatomic)UILabel* whenLabel;
@property(assign,nonatomic)BOOL sent;


@end
