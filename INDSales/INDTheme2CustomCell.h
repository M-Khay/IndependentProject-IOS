//
//  INDTheme2CustomCell.h
//  INDSales
//
//////  Created by Kush on 13/11/16.
//

#import <UIKit/UIKit.h>

@interface INDTheme2CustomCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *otl_PhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *otl_firstName;
@property (weak, nonatomic) IBOutlet UIButton *otlPhoneBtn;
@property (weak, nonatomic) IBOutlet UIButton *otlEmailBtn;
@property (weak, nonatomic) IBOutlet UILabel *otlCountryLbl;
@property (weak, nonatomic) IBOutlet UILabel *designationOtl;

@property (weak, nonatomic) IBOutlet UIView *otl_theme2View;
@property (weak, nonatomic) IBOutlet UILabel *otl_companyName;
@property (strong, nonatomic) IBOutlet UIImageView *otl_ImageBackground;
@end
