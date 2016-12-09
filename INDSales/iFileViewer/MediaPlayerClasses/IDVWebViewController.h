//
//  IDVWebViewController.h
//  iDocViewer
//
//  Created by Krishna on 17/10/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DatasourceSingltonClass.h"
#import "MBProgressHUD.h"


@interface IDVWebViewController : UIViewController<UIGestureRecognizerDelegate,MBProgressHUDDelegate,UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *otl_WebView;
@property(strong,nonatomic) UIPinchGestureRecognizer *webVIewPinchGesture;
@property(strong,nonatomic)UITapGestureRecognizer *oneTap;
@property(nonatomic) int selectedRowIndexNumbr;
@property(strong,nonatomic) NSString *path;
@property(strong,nonatomic) UITapGestureRecognizer *oneTapGesture;
- (IBAction)onClickGoBack:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *otl_BackButton;
@property (weak, nonatomic) IBOutlet UIView *otl_NavbarView;


@end
