//
//  CustomCell.h
//  iDocViewer
//
//  Created by Kush on 15/10/16.
//
@class INDDataModel;

@protocol CustomCellDelegate <NSObject>
@optional
- (void)shareFileWithObject:(INDDataModel*)file;
-(void)addToFavouriteWithObject:(INDDataModel*)file;
-(void)removeFromFavouriteListWithObject:(INDDataModel*)file;
-(void)getCellIndex:(long)cellIndex;
-(void)removeFavouriteFiles:(INDDataModel*)file;
-(void)saveFavouriteFiles:(INDDataModel*)file;
-(void)addPasswordToFile:(INDDataModel*)file;
-(void)removePasswordFromFile:(INDDataModel*)file;

@end


#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "INDDataModel.h"

@interface CustomCell : UITableViewCell<MBProgressHUDDelegate>
{
   
//BOOL checkboxSelected;
}
@property (weak) id<CustomCellDelegate> customCellDelegateObj;

@property (weak, nonatomic) IBOutlet UILabel *otl_FileName;
@property (weak, nonatomic) IBOutlet UIImageView *otl_ImgView;
@property (weak, nonatomic) IBOutlet UIButton *otl_BtnFavourite;
@property (weak, nonatomic) IBOutlet UIButton *otl_BtnShare;
@property (weak, nonatomic) IBOutlet UILabel *otl_FileSize;
@property (strong, nonatomic) IBOutlet UILabel *otl_CreationDate;
@property (weak, nonatomic) NSIndexPath *cellIndexPath;
//@property ( nonatomic)int favFlag;
@property (strong,nonatomic) NSString *path;
@property (strong, nonatomic) IBOutlet UIImageView *otl_ImageViewLock;
@property(nonatomic)  BOOL isLocked;
@property (strong, nonatomic) IBOutlet UIButton *otl_LockButton;
@property (strong, nonatomic) UIButton *favButton;
@property (strong, nonatomic) UIButton *lockButton;
@property (strong, nonatomic) INDDataModel *file;



- (IBAction)onClickShareFile:(id)sender;

- (IBAction)onClickAddToFavourite:(id)sender;
- (IBAction)onClickLockFile:(id)sender;


//-(void) getIndexPath;
@end
