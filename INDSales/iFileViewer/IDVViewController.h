//
//  IDVViewController.h
//  iDocViewer
//
//////  Created by Kush on 13/11/16.
//  Copyright (c) 2013 Indegene. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
//#import "AFURLConnectionOperation.h"
#import "CustomCell.h"
#import "Reachability.h"
#import "IDVWebViewController.h"
//#import "IDVImageViewController.h"
#import "FavouriteFiles.h"
#import "HistoryFiles.h"
#import "PasswordFiles.h"
#import "IDVFavouriteViewController.h"
#import "IDVMediaPlayerViewController.h"
#import "IDVHistoryDataViewController.h"
#import "MBProgressHUD.h"
#import "INSettingViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "IDVTextViewController.h"
#import "IDVCoverFlowVIew.h"
#import "DatasourceSingltonClass.h"
#import "IDVCollectionVIew.h"
#import "IDVCollectionVIewCustomCell.h"
#import "INSettingViewController.h"
#import "IDVSortOptionsViewController.h"
#import<MediaPlayer/MediaPlayer.h>
#import "UIImage+fixOrientation.h"
#import "INDFileViewerConstants.h"
//#import "Transition Delegate/TransitionDelegate.h"

//#import "PDFTouch.h"
//#import "YLPDFViewController.h"
//#import "YLDocument.h"
@class IDVCollectionVIew;
@class IDVCoverFlowVIew;
@class IDVFavouriteViewController;
@class IDVWebViewController;
@class IDVHistoryDataViewController;
@class IDVPasswordChangeViewController;
@class IDVSortOptionsViewController;
@class IDVTextViewController;
@class INSettingViewController;
@class HistoryFiles;
@class FavouriteFiles;
@class PasswordFiles;
@class iCarousel;
@class ZipArchive;
@class BIDragDropCollectionViewFlowLayout;
@class IDVMediaPlayerViewController;

@interface IDVViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,CustomCellDelegate,UIPopoverControllerDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate, IDVHistoryDelegate,IDVCoverFlowViewDelegate,IDVCollectionViewDelegate,CollectionViewCellDelegate,SettingClassDelegate,SortingClassDelegate,FavouriteVCDelegate,MBProgressHUDDelegate,MPMediaPickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>


@property (strong,nonatomic) AFHTTPRequestOperation  *operation;
@property (weak, nonatomic) IBOutlet UITableView *otlTableView;

@property(nonatomic,strong)Reachability *reachability;
@property(strong,nonatomic)NSString *directoryPathForCell;
@property (nonatomic,strong) UIPopoverController *historyPopoverController;
@property(strong,nonatomic) NSIndexPath *indexPathInDidselect;

@property(nonatomic)BOOL isNotCalledFirstTime;
@property(nonatomic) int viewTag;
@property(strong,nonatomic) NSMutableArray *MIMETYPE;
@property(strong,nonatomic) NSMutableArray *docFileExtensions;

@property (strong, nonatomic) IBOutlet UIButton *otl_sortButton;
@property (strong, nonatomic) IBOutlet UIButton *otl_EditButton;

@property (weak, nonatomic) IBOutlet UILabel *otl_DownloadLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *otl_DownloadProgressview;
@property (strong, nonatomic) IBOutlet UILabel *otl_downloadProgressLabel;
//@property (weak, nonatomic) IBOutlet UIView *otl_downloadProgressHolderViewIPhone;
//@property (weak, nonatomic) IBOutlet UIButton *otl_buttonDownloadProgress;
@property (strong, nonatomic) NSString *currentDirectoryPath;
@property(strong,nonatomic) NSString *viewStyle;
@property(strong,nonatomic) NSString *fileToShare;
@property(nonatomic) int deleteFileIndex;
@property (strong,nonatomic)UITextField *textURL;
//- (IBAction)onClickShowDownloadProgressBar:(id)sender;
//- (IBAction)onClickDismissDownloadProgressBar:(id)sender;

///@@@@
@property (weak, nonatomic) IBOutlet UIButton *otl_MultipleDelButton;
- (IBAction)onClickAllowMultipleDeletion:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *otl_CancelMultipleSelection;
- (IBAction)onClickCancelMultipleSelection:(id)sender;
///@@@
- (IBAction)onClickEditMode:(id)sender;
- (IBAction)onClickSortData:(id)sender;
-(void)downloadFromGivenLink:(NSString*)url;

-(void)cancel;
-(void)pause;
-(void)resume;

@end
