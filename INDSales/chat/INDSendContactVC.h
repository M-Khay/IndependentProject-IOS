//
//  INDSendContactVC.h
//  INDSales
//
//  Created by parth on 06/05/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "INDContactModel.h"

@protocol sendContactCard <NSObject>

@optional

-(void)sendContact:(INDContactModel*)contact;

@end

@interface INDSendContactVC : UIViewController
@property(weak,nonatomic)id delegate;
@end
