//
//  INSettingViewController.h
//  TestPopover
//
//  Created by parth on 28/10/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//
@protocol SettingClassDelegate <NSObject>
@optional
- (void)showFavourites;
-(void)showHelpContent;
-(void)contactUs;
-(void)showPasswordSection;
-(void)setBackgroundAudioOnOff;
-(void)fetchMediaFiles;
@end

#import <UIKit/UIKit.h>
#import "IDVFavouriteViewController.h"
#import "IDVMediaPlayerViewController.h"

@interface INSettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *otl_tableView;
@property(weak) id<SettingClassDelegate> settingDelegateObj;

- (IBAction)onClickDismissVC:(id)sender;

@end
