//
//  IDVFavouriteViewController.h
//  iDocViewer
//
//  Created by Krishna on 21/10/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//
@protocol FavouriteVCDelegate <NSObject>

@optional
-(void)updateTableAfterFavFileDeleted;
-(void)updateTable;
@end

#import <UIKit/UIKit.h>
#import "IDVFavouriteCustomCell.h"
#import "IDVWebViewController.h"
#import "IDVImageViewController.h"
#import "IDVMediaPlayerViewController.h"
#import "FavouriteFiles.h"
#import "ZipArchive.h"
#import "MBProgressHUD.h"
#import "iCarousel.h"
#import "DatasourceSingltonClass.h"
#import "IDVNewFolderViewController.h"
#import "BIDragDropCollectionViewFlowLayout.h"
#import "IDVSortOptionsViewController.h"
#import "INDFileViewerConstants.h"

@interface IDVFavouriteViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,FavouriteCustomCellDelegate,MBProgressHUDDelegate,IDVCollectionViewDelegate,IDVCoverFlowViewDelegate,UIPopoverControllerDelegate,NewFolderDelegate,SortingClassDelegate,UIActionSheetDelegate,UITextFieldDelegate>
{
  //   BOOL isNotCalledFirstTime;
   // int viewTag;
}
@property(strong,nonatomic) id <FavouriteVCDelegate> favouriteVCDelegate;
@property (weak, nonatomic) IBOutlet UITableView *otl_TableView;

//@property (strong, nonatomic) NSString *rootDirectoryPath;

@property (strong, nonatomic) NSString *currentDirectoryPath;
//@property (strong,nonatomic) NSMutableArray *arrOfFavouriteFilePath;
@property(strong,nonatomic)NSString *directoryPathForCell;


@property(strong,nonatomic)  UIImageView *imageViewForPreview;
@property(strong,nonatomic) NSMutableArray *arrOfFileSize;
@property(assign)   NSUInteger currentIndex;
@property(strong,nonatomic) NSMutableArray *arrOfFileName;
@property(strong,nonatomic) NSMutableArray *arrOficonImage;

@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGesture;
@property (assign, nonatomic) BOOL isLongPressForTableView;
@property (strong, nonatomic) NSIndexPath *selectedindexPath;
@property (strong, nonatomic) UIMenuController *menuController;

@property (strong, nonatomic) UIMenuItem *menuItemPaste;
@property(strong,nonatomic) UISegmentedControl* segmentedControl;
@property(strong,nonatomic)  UIButton *addButton;
@property(nonatomic)BOOL isNotCalledFirstTime;
@property(nonatomic) int viewTag;
@property(strong,nonatomic) UIPopoverController *popoverController;
@property(strong,nonatomic) NSString *directoryPathInDidSelect;
@property(strong,nonatomic) NSIndexPath *indexPathInDidselect;
@property(strong,nonatomic) NSString *fileToShare;
@property(strong,nonatomic)  NSString *deletingFilePath;
@property(nonatomic) int deleteFileIndex;
@property(strong,nonatomic) UIPopoverController *soringPopover;
@property (strong, nonatomic) IBOutlet UIButton *otl_EditButton;

@property (weak, nonatomic) IBOutlet UIButton *otl_MultipleDelButton;
@property (weak, nonatomic) IBOutlet UIButton *otl_CancelMultipleSelection;
- (IBAction)onClickAllowMultipleDeletion:(id)sender;
- (IBAction)onClickCancelMultipleSelection:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *otl_sortButton;
- (IBAction)onClickSortData:(id)sender;
- (IBAction)onClickEditMode:(id)sender;





@end
