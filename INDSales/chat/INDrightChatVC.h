//
//  INDrightChatVC.h
//  INDSales
//
//  Created by parth on 23/04/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INDContactModel.h"

@interface INDrightChatVC : UIViewController<UISplitViewControllerDelegate>
-(void)selectUser:(NSString *)user;
@property (nonatomic,strong)NSString* userName;

@end
