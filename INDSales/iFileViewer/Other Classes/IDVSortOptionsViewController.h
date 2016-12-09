//
//  IDVSortOptionsViewController.h
//  iDocViewer
//
//  Created by Krishna on 28/01/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

@protocol SortingClassDelegate <NSObject>
@optional
- (void)sortByName;
-(void)sortBySize;
-(void)sortByCreationDate;
@end

#import <UIKit/UIKit.h>
#import "DatasourceSingltonClass.h"

@interface IDVSortOptionsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *otl_tableView;

@property(weak) id<SortingClassDelegate> sortingDelegateObj;

@end
