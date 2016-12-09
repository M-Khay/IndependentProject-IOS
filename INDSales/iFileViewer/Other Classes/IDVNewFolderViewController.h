//
//  IDVNewFolderViewController.h
//  iDocViewer
//
//  Created by Krishna on 25/11/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

@protocol NewFolderDelegate <NSObject>

@optional
-(void)createNewFolderWithName:(NSString*)name;
-(void)cancelNewFolderPopover;

@end
#import <UIKit/UIKit.h>

@interface IDVNewFolderViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *otl_FolderName;

- (IBAction)onClickSetPassword:(id)sender;
- (IBAction)onClickCancel:(id)sender;

@property(strong,nonatomic) id<NewFolderDelegate> delegate;
@end
