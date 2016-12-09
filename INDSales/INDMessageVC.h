//
//  INDMessageVC.h
//  INDSales
//
//////  Created by Kush on 13/11/16.
//

#import <UIKit/UIKit.h>

@interface INDMessageVC : UIViewController
@property(nonatomic, strong) IBOutlet UILabel* msgLabel;
@property(strong,nonatomic) UILabel *secondMsgLabel;
-(void)setTextToLabel:(NSString*)text;
@end
