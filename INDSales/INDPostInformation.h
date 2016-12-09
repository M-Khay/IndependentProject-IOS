//
//  INDPostInformation.h
//  INDSales
//
//////  Created by Kush on 13/11/16.
//

#import <UIKit/UIKit.h>
#import "INDWebServiceModel.h"
#import "MBProgressHUD.h"

@interface INDPostInformation : UIViewController<webServiceResponceProtocol,MBProgressHUDDelegate>

@property(strong,nonatomic)UIPopoverController* mypopoverController;
@end
