
//
//  INDCustomerDetailViewController.h
//  INDSales
//
//  Created by parth on 03/03/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Customer.h"
@interface INDCustomerDetailViewController : UIViewController

@property(strong,nonatomic)Customer* customerDetails;

@property (nonatomic, strong) UIImage * cutomerThumbImage;

@end
