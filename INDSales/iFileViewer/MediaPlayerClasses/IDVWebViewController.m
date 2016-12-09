//
//  IDVWebViewController.m
//  iDocViewer
//
//  Created by Krishna on 17/10/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import "IDVWebViewController.h"

@interface IDVWebViewController ()
{
    MBProgressHUD *HUD;
}

@end

@implementation IDVWebViewController
@synthesize otl_WebView,webVIewPinchGesture,oneTapGesture;
@synthesize selectedRowIndexNumbr,path;
@synthesize otl_BackButton,otl_NavbarView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    oneTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    oneTapGesture.delegate=self;
    oneTapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:oneTapGesture];
    [self.navigationItem setTitle:[path lastPathComponent]];
    
  
    if([[DatasourceSingltonClass sharedInstance].webViewFlag isEqualToString:@"unsupportedFiles"])
    {
    NSURL *url = [NSURL URLWithString:path];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [otl_WebView loadRequest:requestObj];
    }
    else
    {
        
        [otl_WebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
    }
    
    otl_WebView.delegate=self;
  //  otl_WebView.scrollView.contentOffset=self.otl_WebView.center;
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate=self;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
    }
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Loading";

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)OrientationChange
{
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
      //  imageVIew.frame=CGRectMake(84, 224, 600, 600);
        //   scrollview.frame=CGRectMake(0, 0, 768, 1024);
        
    }
    else
    {
       // imageVIew.frame=CGRectMake(224, 84, 600, 600);
        //  scrollview.frame=CGRectMake(0, 0, 1024, 768);
    }
    
}

- (void)handleSingleTapGesture:(UITapGestureRecognizer *)recognizer
{
    static int count=2;
    
    count ++;
    if(count %2==1 ) {
       // [[self navigationController] setNavigationBarHidden:YES animated:YES];
        self.otl_BackButton.hidden=YES;
        self.otl_NavbarView.hidden=YES;
    }
    else  {
       // [[self navigationController] setNavigationBarHidden:NO animated:YES];
        self.otl_BackButton.hidden=NO;
        self.otl_NavbarView.hidden=NO;

        }
    }


- (IBAction)onClickGoBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    HUD.hidden=NO;

    [HUD show:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [HUD show:NO];
    HUD.hidden=YES;
   /* NSString *bodyStyleVertical = @"document.getElementsByTagName('body')[0].style.verticalAlign = 'center';";
    NSString *bodyStyleHorizontal = @"document.getElementsByTagName('body')[0].style.horizontalAlign = 'center';";
    NSString *mapStyle = @"document.getElementById('mapid').style.margin = 'auto';";

    [webView stringByEvaluatingJavaScriptFromString:bodyStyleVertical];
    [webView stringByEvaluatingJavaScriptFromString:bodyStyleHorizontal];
    [webView stringByEvaluatingJavaScriptFromString:mapStyle];
    NSString *bodyStyle = @"document.getElementsByTagName('body')[0].style.textAlign = 'center';";
    [webView stringByEvaluatingJavaScriptFromString:bodyStyle]; */
}
-(void)webView:(UIWebView *)webview didFailLoadWithError:(NSError *)error {
    HUD.hidden=YES;
    if (error.code == NSURLErrorNotConnectedToInternet){
        NSLog(@"You are not connected");
    }
    else if(error.code==kCFURLErrorUnsupportedURL)
    {
         NSLog(@"unsupported url");
    }
    else if(error.code==kCFURLErrorUserAuthenticationRequired)
    {
        NSLog(@"authentication required ");
    }
    else if(error.code==kCFURLErrorResourceUnavailable)
    {
        NSLog(@"ResourceUnavailable ");
    }
    else if(error.code==kCFURLErrorTimedOut)
    {
        NSLog(@"The request timed out");
    }
    
    else
    {
        NSLog(@"could not open error=%@",error);
    }
    
}
@end
