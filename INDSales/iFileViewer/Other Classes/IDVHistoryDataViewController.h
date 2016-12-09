//
//  IDVHistoryDataViewController.h
//  iDocViewer
//
//  Created by Krishna on 18/10/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

@protocol IDVHistoryDelegate <NSObject>
@optional
-(void) ShowHistoryinTextBox:(NSString*)text;

@end

#import <UIKit/UIKit.h>
#import "IDVViewController.h"
#import "IDVHistoryCustomCell.h"

@interface IDVHistoryDataViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(strong,nonatomic) NSMutableArray *arrOfURLs;
@property(weak) id<IDVHistoryDelegate>idvHistoryDelegateObj;
@property (weak, nonatomic) IBOutlet UITableView *otl_tableView;


- (IBAction)onClickCancelVC:(id)sender;

- (IBAction)onClickClearHistory:(id)sender;

@end
