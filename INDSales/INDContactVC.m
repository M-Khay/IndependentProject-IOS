//
//  INDHomeVC.m
//  INDSales
//
//////  Created by Kush on 13/11/16.
//

#import "INDContactVC.h"
#import "IDVViewController.h"
#import "INDTabbarViewController.h"

@interface INDContactVC ()
@property (strong,nonatomic)UIActivityIndicatorView* activityView;
@end

@implementation INDContactVC
@synthesize activityView;
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
	// Do any additional setup after loading the view.
    
    activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityView setHidesWhenStopped:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationController.navigationBarHidden = YES;
    self.tabBarController.navigationItem.title = @"Home";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickShowDocuments:(UIButton *)sender
{
    activityView.center=self.view.center;
    
    [activityView startAnimating];
    
    [self.view addSubview:activityView];
    IDVViewController *idvVC;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
         idvVC=[[IDVViewController alloc]initWithNibName:@"IDVViewController_iPhone" bundle:nil];
    }
    else
    {
        idvVC=[[IDVViewController alloc]initWithNibName:@"IDVViewController" bundle:nil];
    }
   
    self.tabBarController.navigationController.navigationBarHidden = NO;
   [self.tabBarController.navigationController pushViewController:idvVC animated:YES];
    
//   [self.navigationController pushViewController:idvVC animated:YES];

}


-(void)viewDidDisappear:(BOOL)animated
{
    [activityView stopAnimating];
    [super viewDidDisappear:animated];
}

- (BOOL)canBecomeFirstResponder {
	return YES;
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
