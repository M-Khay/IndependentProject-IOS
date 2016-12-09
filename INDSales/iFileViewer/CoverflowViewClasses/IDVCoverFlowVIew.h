//
//  IDVCoverFlowVIew.h
//  iDocViewer
//////  Created by Kush on 13/11/16.
//
@class INDDataModel;
@protocol IDVCoverFlowViewDelegate <NSObject>
@optional
-(void)showSettingOptions;
-(void)coverFlowDidSelectAtindexPath:(NSIndexPath*)indexPath;
//-(void)coverFlowDidSelectAtindexPathForFavSection:(NSIndexPath *)indexPath;
//-(void)sharefileFromCollectionviewWithFilePath:(NSString*)file;
-(void)updateCoverFlowDataSource;
-(void)shareFileWithObject:(INDDataModel*)file;
-(void)deleteFileAtIndex:(int)index;
-(void)saveFavouriteFiles:(INDDataModel*)file;
-(void)removeFavouriteFiles:(INDDataModel*)file;

@end

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "IDVCoverFlowTableCustomCell.h"
#import "DatasourceSingltonClass.h"
#import "IDVViewController.h"
#import "INDDataModel.h"


@interface IDVCoverFlowVIew : UIView <UITableViewDataSource,UITableViewDelegate,iCarouselDataSource, iCarouselDelegate,UITableViewDataSource,UITableViewDelegate,CoverFLowCustomCellDelegate>

//icarousel
@property (weak, nonatomic) iCarousel *carousel;
@property (weak, nonatomic) UILabel *sizeLabel;
@property(weak,nonatomic) UIButton *favouriteBtn;
@property(weak,nonatomic) UIButton *shareBtn;
@property (unsafe_unretained,nonatomic) BOOL wrap;
@property(weak,nonatomic) UIImageView *imageViewForPreview;
@property(unsafe_unretained, assign) NSUInteger currentIndex;
//carousel

@property (strong, nonatomic) NSString *currentDirectoryPath;
@property(strong,nonatomic) NSMutableArray *coverFlowDataSource;
@property(strong,nonatomic) NSString *imgString;
@property(strong,nonatomic) NSString* pathForCurrentFile;
@property(weak,nonatomic) UITableView *tableView;
@property(weak,nonatomic) UILabel *otl_FilesNameLabel;
@property(strong,nonatomic) NSString* pathForCurrentFileInTableView;
@property(strong,nonatomic) NSDateFormatter *formatter;
@property(strong,nonatomic) NSString* directoryPathInDidSelect;
@property(strong,nonatomic) NSString* directoryPathInCarouselDidSelect;
@property(unsafe_unretained, nonatomic) int deleteIndex;
@property(nonatomic,strong) NSString *sortingOrderByName;
@property(nonatomic,strong) NSString *sortingOrderByDate;
@property(nonatomic,strong) NSString *sortingOrderBySize;

@property(weak, nonatomic) id<IDVCoverFlowViewDelegate>idvCoverFlowViewDelegateObj;
@property (nonatomic, weak) UINavigationController *navController;

-(void)initialization;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

@property (strong, nonatomic) NSArray *arrOfFetchedLockedfiles;
@property (strong, nonatomic) NSArray *arrOfFetchedFavouritefiles;
@property (strong, nonatomic) NSArray *thumbnailArray;

@end
