//
//  IDVCoverFlowTableCustomCell.h
//  iDocViewer
////  Created by Kush on 09/11/16.

//
@class INDDataModel;
@protocol CoverFLowCustomCellDelegate <NSObject>

@optional
-(void)saveFavouriteFilesAtPath:(INDDataModel*)file;
-(void)removeFavouriteFilesAtPath:(INDDataModel*)file;
-(void)shareFileAtPath:(INDDataModel*)file;
@end


#import <UIKit/UIKit.h>
#import "INDDataModel.h"

@interface IDVCoverFlowTableCustomCell : UITableViewCell

@property(weak, nonatomic)id<CoverFLowCustomCellDelegate> coverFlowCustomCellDelegate;

@property (strong, nonatomic) IBOutlet UILabel *otl_LblColumn1;

@property (strong, nonatomic) IBOutlet UILabel *otl_LblColumn2;

@property (strong, nonatomic) IBOutlet UILabel *otl_LblColumn3;
@property (strong, nonatomic) IBOutlet UIButton *otl_FavouriteBtn;
@property (strong, nonatomic) IBOutlet UIButton *otl_ShareBtn;
@property (strong, nonatomic) IBOutlet UIImageView *otl_ImageViewLock;
//@property (strong, nonatomic) IBOutlet UIButton *otl_ShareBtn;
//@property(nonatomic)int favFlag;
@property(strong,nonatomic) NSString *path;
@property(strong, nonatomic) INDDataModel *file;
@property (strong, nonatomic) UIButton *favButton;


- (IBAction)onClickAddToFavourite:(id)sender;
- (IBAction)onClickShare:(id)sender;

@end
