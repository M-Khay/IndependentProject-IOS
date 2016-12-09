//
//  IDVCollectionVIewCustomCell.h
//  iDocViewer
//
//  Created by Kush on 04/11/16.
//
@class IDVCollectionVIewCustomCell;
@class INDDataModel;

@protocol MyMenuDelegate <NSObject>
@optional
- (void) delete:(id)sender forCell:(IDVCollectionVIewCustomCell *)cell;
@end

@protocol CollectionViewCellDelegate <NSObject>

@optional
-(void)saveFavouriteFilesAtPath:(INDDataModel*)file;
-(void)removeFavouriteFilesAtPath:(INDDataModel*)file;
-(void)shareFileAtPath:(INDDataModel*)file;
@end

#define MARGIN 2
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DatasourceSingltonClass.h"
#import <AVFoundation/AVFoundation.h>
@interface IDVCollectionVIewCustomCell : UICollectionViewCell

@property (weak, nonatomic) id<CollectionViewCellDelegate> collectionViewCellDelegate;
@property (weak, nonatomic) id<MyMenuDelegate> delegate;


@property (strong, nonatomic) IBOutlet UIImageView *otl_ImageView;
@property (strong, nonatomic) IBOutlet UILabel *otl_LblSize;
@property (strong, nonatomic) IBOutlet UILabel *otl_CreationDate;
@property (strong, nonatomic) IBOutlet UIButton *otl_BtnFavourite;
@property (strong, nonatomic) IBOutlet UIButton *otl_BtnShare;
@property (strong, nonatomic) IBOutlet UILabel *otl_LblFileName;
@property (strong, nonatomic) IBOutlet UIImageView *otl_imageLock;
@property (strong, nonatomic) IBOutlet UIView *otl_stripView;

@property(nonatomic,strong) NSString *path;
@property(strong,nonatomic) INDDataModel *file;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *favButton;
@property (strong, nonatomic) UILabel* label;
//@property(nonatomic)int favFlag;


- (IBAction)onClickAddToFavourite:(id)sender;
- (IBAction)onClickShare:(id)sender;


@end
