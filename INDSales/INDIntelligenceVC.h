//
//  INDIntelligenceVC.h
//  INDSales
//
//  Created by Ashish on 05/02/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INDWebServiceModel.h"
#import "MBProgressHUD.h"
#import "INDSelectCategory.h"
@interface INDIntelligenceVC : UIViewController<UITableViewDataSource,UITableViewDelegate,webServiceResponceProtocol,UITextFieldDelegate,MBProgressHUDDelegate,UIPopoverControllerDelegate>

@property(nonatomic, strong) INDSelectCategory* indSelectCategoryVC;

@end
