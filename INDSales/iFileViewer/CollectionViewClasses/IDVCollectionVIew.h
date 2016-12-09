//
//  IDVCollectionVIew.h
//  iDocViewer
//
///  Created by Kush on 04/10/16.

@class INDDataModel;
@protocol IDVCollectionViewDelegate <NSObject>
@optional
-(void)collectionViewDidSelectAtindexPath:(NSIndexPath*)indexPath;
-(void)updateCollectionDataSource;
-(void)shareFileWithObject:(INDDataModel*)file;
-(void)deleteFileAtIndex:(int)index;
-(void)saveFavouriteFiles:(INDDataModel*)file;
-(void)removeFavouriteFiles:(INDDataModel*)file;
- (void)CollectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath;
- (BOOL)CollectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath;

@end


#import <UIKit/UIKit.h>
#import "IDVCollectionVIewCustomCell.h"
#import "IDVImageViewController.h"
#import "IDVWebViewController.h"
#import "IDVTextViewController.h"
#import "IDVMediaPlayerViewController.h"
#import "ZipArchive.h"
#import "MBProgressHUD.h"
#import "DatasourceSingltonClass.h"
#import "BIDragDropCollectionViewFlowLayout.h"
#import "INDDataModel.h"

@interface IDVCollectionVIew : UIView<UICollectionViewDataSource,UICollectionViewDelegate,MyMenuDelegate,CollectionViewCellDelegate,UIGestureRecognizerDelegate,BIDragDropCollectionViewDataSource,BIDragDropCollectionViewDelegateFlowLayout>
@property(strong,nonatomic) UICollectionView *collectionView;
@property(strong,nonatomic) NSMutableArray *collectionViewDataSource;
@property (strong, nonatomic) NSString *currentPath;
@property(nonatomic)BOOL isNotCalledFirstTime;


@property (strong, nonatomic) NSString *imgString;
@property (strong, nonatomic) NSString *pathForCurrentFile;
@property (strong, nonatomic) NSString *directoryPathInDidSelect;
@property(strong,nonatomic) UINavigationController *navController;
//@property(nonatomic) int deleteFileIndex;
//@property(strong,nonatomic) UIButton *deleteButton;
@property(nonatomic) int deleteIndex;
@property(nonatomic) BOOL isDeletionModeActive;
@property(strong,nonatomic)id<IDVCollectionViewDelegate>idvCollectionViewDelegate;
-(void)initialization;
//-(void) dataFetchMethod;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

@property (strong, nonatomic) NSArray *arrOfFetchedLockedfiles;
@property (strong, nonatomic) NSArray *arrOfFetchedFavouritefiles;

@property (strong,nonatomic)BIDragDropCollectionViewFlowLayout *collectionViewFlowlayoutDragDrop;
@property(strong,nonatomic) UIButton *editButton;
@property(strong,nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) NSArray *thumbnailArray;

//@property(strong,nonatomic) NSMutableArray *arrOfFavFiles;
-(void) activateDeletionMode;

@end
