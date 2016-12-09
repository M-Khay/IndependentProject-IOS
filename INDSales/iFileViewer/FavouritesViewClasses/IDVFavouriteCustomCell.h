//
//  IDVFavouriteCustomCell.h
//  iDocViewer
//
//  Created by Krishna on 21/10/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//
@class INDDataModel;
@protocol FavouriteCustomCellDelegate <NSObject>

@optional
- (void)shareFileWithObject:(INDDataModel*)file;
-(void)removeFavouriteFiles:(INDDataModel*)file;
-(void)saveFavouriteFiles:(INDDataModel*)file;

@end

#import <UIKit/UIKit.h>
#import "INDDataModel.h"

@interface IDVFavouriteCustomCell : UITableViewCell<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *otl_ImageView;

@property (weak, nonatomic) IBOutlet UILabel *otl_TextFileName;
@property (weak, nonatomic) IBOutlet UILabel *otl_TextFileSize;
@property (strong, nonatomic) IBOutlet UILabel *otl_TextFileCreationDate;
@property (weak, nonatomic) IBOutlet UIButton *otl_BtnShare;

@property (weak) id<FavouriteCustomCellDelegate> favCustomCellDelegateObj;
@property (strong,nonatomic) NSString *path;
@property (strong,nonatomic) INDDataModel *file;
@property (strong, nonatomic) IBOutlet UIImageView *otl_imageLock;



- (IBAction)onClickShare:(id)sender;

@end
