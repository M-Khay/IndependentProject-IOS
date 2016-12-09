//
//  INDRSSFeedLinkInfVC.m
//  INDSales
//
//  Created by Piyush on 3/5/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import "INDRSSFeedLinkInfVC.h"

@interface INDRSSFeedLinkInfVC ()
@property(strong,nonatomic) MBProgressHUD *HUD;
@property(strong, nonatomic)Reachability * internetReachability;
@property (strong, nonatomic) INDMessageVC *msgVC;
@end

@implementation INDRSSFeedLinkInfVC

@synthesize otlWebView,feedLink,HUD;
@synthesize msgVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    otlWebView.delegate=self;
    HUD.delegate=self;
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"Loading";
    HUD.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:HUD];
    [self loadingWebView];
    
    // reachability
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
	[self.internetReachability startNotifier];
    [self networkStatus:[self.internetReachability currentReachabilityStatus]];
    
    
  }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadingWebView
{
    NSURL *url = [NSURL URLWithString:feedLink];
    NSLog(@"url=%@",url);
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [otlWebView loadRequest:requestObj];
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
   [HUD show:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [HUD hide:YES];

}

- (void) reachabilityChanged:(NSNotification *)note
{
    [self networkStatus:[[note object] currentReachabilityStatus]];
    
}

-(void)networkStatus:(NetworkStatus)networkStatus
{
    if (!(networkStatus==NotReachable))
    {
        [self removeMsgVC];
        [self loadingWebView];
        [HUD show:YES];
        
    }
    else
    {
        [self addMsgVC:@"Internet connection not available"];
        
        [HUD hide:YES];
    }
}



-(void)addMsgVC:(NSString*)message
{
    if(![[self.view subviews]containsObject:msgVC.view])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
        
        self.msgVC = (INDMessageVC *)[storyboard instantiateViewControllerWithIdentifier:@"INDMessageVC"];
        
        
        [self addChildViewController:self.msgVC];
        
        [UIView animateWithDuration:0.50 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.msgVC.view.frame = CGRectMake(0,60,768,0);
            
            self.msgVC.view.frame = CGRectMake(0,60,768,50);
            
        } completion:^(BOOL finished) {
            
            [self.msgVC setTextToLabel:message];
        }];
        
        [self.view addSubview:self.msgVC.view];
        
        [self.msgVC didMoveToParentViewController:self];
        
    }
}

-(void)removeMsgVC
{
    
    
    if([[self.view subviews]containsObject:msgVC.view])
    {
        [UIView animateWithDuration:0.50 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.msgVC.view.frame = CGRectMake(0,60,768,50);
            
            self.msgVC.view.frame = CGRectMake(0,60,768,0);
            self.msgVC.msgLabel.hidden = TRUE;
            
        } completion:^(BOOL finished) {
            
            [self.msgVC.view removeFromSuperview];
            [self.msgVC removeFromParentViewController];
        }];
    }
    
}

#pragma mark- orientation methods
-(BOOL)shouldAutorotate
{
    // forcing the rotate IOS6 Only
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


@end

