//
//  INDSelectCategory.h
//  INDSales
//
//  Created by Piyush on 4/1/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol didSelectCategory <NSObject>

@optional

-(void)categoryDidSelected:(NSString*)category;

@end

@interface INDSelectCategory : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *otlTableView;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (weak,nonatomic)id<didSelectCategory>delegate;

@end
