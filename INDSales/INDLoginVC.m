//
//  INDLoginVC.m
//  INDSales
//
//////  Created by Kush on 13/11/16.
//

#import "INDLoginVC.h"
#import "INDContactVC.h"
#import "INDWebServiceModel.h"
#import "INDWebservices.h"
#import "INDConfigModel.h"

@interface INDLoginVC ()

@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView*activityView;

@property (strong, nonatomic) INDMessageVC *msgVC;

@end

@implementation INDLoginVC

- (IBAction)SubmitAction:(id)sender {
    
//    NSURL*url = [NSURL URLWithString:[NSString stringWithFormat:@"%@indegene_sales_app/login.jsp?login=%@&passwd=%@",baseUrl,self.usernameTextField.text, self.passwordTextField.text]];
    

    NSURL*url = [NSURL URLWithString:[NSString stringWithFormat:@"%@indegene_sales_app/login.jsp",baseUrl]];
    
    
    [INDConfigModel shared].userName=self.usernameTextField.text;
    [INDConfigModel shared].password=self.passwordTextField.text;
    
    INDWebServiceModel*webserviceModal = [[INDWebServiceModel alloc]initWithDelegate:self url:url NameOfWebService:LoginService];
    
    NSDictionary* login=@{@"login": self.usernameTextField.text,@"passwd":self.passwordTextField.text};
    [webserviceModal setPostData:login];
    
    [[INDWebservices shared] startWebserviceOperation:webserviceModal];
    [self.activityView startAnimating];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        //Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark WebserviceDelegates

-(void)completionOperationWithSuccess:(id)operation responseData:(id)responseObject webServiceOperationObject:(INDWebServiceModel *)webServiceOperationObject
{
   
    [self.activityView stopAnimating];
  
    if ([webServiceOperationObject serviceName]==LoginService) {
    
        NSError* error;
//        NSDictionary* loginResponce=[NSJSONSerialization JSONObjectWithData:[(AFHTTPRequestOperation*)operation responseObject] options:kNilOptions error:&error];
        
        NSDictionary* loginResponce=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        
        UIStoryboard *storyboard;
        
        if (isiPhone5) {
            storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            
        }else
        {
            storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
        }
        
        if ([[loginResponce objectForKey:@"result"]isEqualToString:@"success"])
        {
            UITabBarController *tabBar = (UITabBarController *)[storyboard instantiateViewControllerWithIdentifier:@"TabBar"];
            
          /*  [self.navigationController presentViewController:tabBar animated:NO
                                                  completion:nil];*/

            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tabBar];
            navController.navigationBarHidden = YES;
            
            [self.navigationController presentViewController:navController
                                                    animated:NO
                                                  completion:nil];
            
            [INDConfigModel shared].category=[NSArray arrayWithArray:[[loginResponce objectForKey:@"category"]objectForKey:@"Competitive Intelligence "]];
            
            [INDConfigModel shared].requestInfoCategory=[NSArray arrayWithArray:[[loginResponce objectForKey:@"category"]objectForKey:@"Request for Information"]];
            
        }
        else
        {
         
             self.msgVC = (INDMessageVC *)[storyboard instantiateViewControllerWithIdentifier:@"INDMessageVC"];
            
            
            [self addChildViewController:self.msgVC];
            
            [UIView animateWithDuration:0.50 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
               
                 self.msgVC.view.frame = CGRectMake(0,60,768,0);
                
                 self.msgVC.view.frame = CGRectMake(0,60,768,50);
               
            } completion:^(BOOL finished) {
                
                [self.msgVC setTextToLabel:@"Failure"];
                
            }];
            
            
            [self.view addSubview:self.msgVC.view];
            
            [self.msgVC didMoveToParentViewController:self];
            
            [self performSelector:@selector(removeMsgVC) withObject:self afterDelay:2.0];
        }
    }
    
}

-(void)removeMsgVC
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

-(void)completionOperationWithFailure:(id)operation error:(NSError *)error webServiceOperationObject:(INDWebServiceModel *)webServiceOperationObject
{
    [self.activityView stopAnimating];
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
