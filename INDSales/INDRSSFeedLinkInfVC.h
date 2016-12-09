//
//  INDRSSFeedLinkInfVC.h
//  INDSales
//
//  Created by Piyush on 3/5/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INDRSSFeedLinkInfVC.h"
#import "MBProgressHUD.h"


@interface INDRSSFeedLinkInfVC : UIViewController<MBProgressHUDDelegate,UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *otlWebView;

@property(strong,nonatomic) NSString *feedLink;

@end
