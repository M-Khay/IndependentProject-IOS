//
//  INDTheme2CustomCell.m
//  INDSales
//
//////  Created by Kush on 13/11/16.
//

#import "INDTheme2CustomCell.h"

@implementation INDTheme2CustomCell
@synthesize otlEmailBtn,otlPhoneBtn,otl_firstName,otl_PhotoImageView,otl_theme2View,otl_companyName,otl_ImageBackground,otlCountryLbl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder {
    if ( !(self = [super initWithCoder:aDecoder]) ) return nil;
    
    // Your code goes here!
    
//    self.otl_theme2View .layer.borderWidth = 3.0f;
//    self.otl_theme2View.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.backgroundColor=[UIColor lightGrayColor];
//    
//    CAGradientLayer *grad = [CAGradientLayer layer];
//    grad.frame = self.otl_theme2View.bounds;
//    grad.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:.5] CGColor], nil];
//    
//    [self.otl_theme2View.layer insertSublayer:grad atIndex:0];
//    
//    
//    self.otl_theme2View.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.otl_theme2View.layer.shadowOpacity = 0.7f;
//    self.otl_theme2View.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
//    self.otl_theme2View.layer.shadowRadius = 5.0f;
//    self.otl_theme2View.layer.masksToBounds = NO;
//    
//    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.otl_theme2View.bounds];
//    self.otl_theme2View.layer.shadowPath = path.CGPath;
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    UITouch *touch = [touches anyObject];
//    if ([touch view] == otl_theme2View){
//  //  self.otl_theme2View.alpha = 0.4;
//        self.otl_theme2View.backgroundColor=[UIColor darkGrayColor];
//    }
//}
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    //Restore the alpha to its original state.
//    UITouch *touch = [touches anyObject];
//    if ([touch view] == otl_theme2View){
//   // self.otl_PhotoImageView.alpha = 1;
//        self.otl_theme2View.backgroundColor=[UIColor lightGrayColor];
//
//    }
//}


@end
