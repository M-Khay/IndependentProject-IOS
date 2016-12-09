//
//  INDPostInformation.m
//  INDSales
//  Created by Ashish on 01/12/16.

#import "INDPostInformation.h"
#import "Reachability.h"
#import "INDWebservices.h"
@interface INDPostInformation ()<UIPickerViewDelegate,UIPickerViewDataSource,UITextViewDelegate>
@property(strong, nonatomic)Reachability * internetReachability;
@property (strong, nonatomic) INDMessageVC *msgVC;
@property (strong, nonatomic) IBOutlet UITextView *otlTextView;
@property (strong, nonatomic) IBOutlet UIButton *otlRequestInfoButton;
@property (strong,nonatomic) MBProgressHUD* sendMessageHud;
@property (weak, nonatomic) IBOutlet UITextView *subjectOtl;
@property(strong,nonatomic) NSMutableArray *pickerDataSource;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;

@property (weak, nonatomic) IBOutlet UIPickerView *categoryPickerView;
@end

@implementation INDPostInformation

@synthesize msgVC,otlTextView,internetReachability,scrollview;
@synthesize otlRequestInfoButton,sendMessageHud,subjectOtl,mypopoverController,pickerDataSource;
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
    
    pickerDataSource=[[NSMutableArray alloc]init];
    
//    for (int i=0; i<[[INDConfigModel shared].category count]; i++) {
//        [pickerDataSource insertObject:[[INDConfigModel shared].requestInfoCategory objectAtIndex:i] atIndex:i];
//    }
    
    [scrollview setContentSize:CGSizeMake(scrollview.frame.size.width, scrollview.frame.size.height*3)];
    
    otlTextView.delegate=self;

    pickerDataSource=[NSMutableArray arrayWithArray:[INDConfigModel shared].requestInfoCategory];
    //[pickerDataSource addObject:@"Select The Category"];
    [pickerDataSource insertObject:@"Select The Category" atIndex:0];
    NSLog(@"picker data source=%@",pickerDataSource);
    [_categoryPickerView selectRow:0 inComponent:0 animated:YES];
    
    self.otlTextView.layer.cornerRadius = 15;
    self.otlTextView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.otlTextView.layer.borderWidth = 1;
    
    self.subjectOtl.layer.cornerRadius = 10;
    self.subjectOtl.layer.borderColor = [[UIColor blackColor] CGColor];
    self.subjectOtl.layer.borderWidth = 1;     // reachability
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
	[self.internetReachability startNotifier];
    [self networkStatus:[self.internetReachability currentReachabilityStatus]];
    [_categoryPickerView reloadAllComponents];
    

    
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (isiPhone5) {
        CGPoint scrollPoint = CGPointMake(0,textView.frame.origin.y-70);
        
        [scrollview setContentOffset:scrollPoint animated:YES];
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (isiPhone5) {
        CGPoint scrollPoint = CGPointMake(0,0);
        
        [scrollview setContentOffset:scrollPoint animated:YES];
    }
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
    }
    else
    {
        [self addMsgVC:@"Internet connection not available"];
        
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
            
            self.msgVC.view.frame = CGRectMake(0,0,500,0);
            self.msgVC.view.frame = CGRectMake(0,0,500,50);
        } completion:^(BOOL finished) {
            
            msgVC.secondMsgLabel.textAlignment=NSTextAlignmentCenter;
            msgVC.secondMsgLabel.textColor=[UIColor whiteColor];
            [msgVC.secondMsgLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:24]];

            msgVC.secondMsgLabel.text=message;

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
            
            self.msgVC.view.frame = CGRectMake(0,0,500,50);
            
            self.msgVC.view.frame = CGRectMake(0,0,500,0);
            //self.msgVC.msgLabel.hidden = TRUE;
            self.msgVC.secondMsgLabel.hidden = TRUE;
            
        } completion:^(BOOL finished) {
            
            [self.msgVC.view removeFromSuperview];
            [self.msgVC removeFromParentViewController];
        }];
    }
    
}


- (IBAction)onRequestInfoButtonAction:(UIButton *)sender
{
    [otlTextView resignFirstResponder];
    
    
    
    if ([internetReachability currentReachabilityStatus]!=NotReachable) {
        
        if (self.validateInputValues){
            
            
            NSString *webServiceUrlPath=[NSString stringWithFormat:@"%@indegene_sales_app/requestinfo.jsp",baseUrl];
           
            
            NSDictionary* postData=@{@"login":[INDConfigModel shared].userName ,@"requestinfo":otlTextView.text,@"subject":subjectOtl.text,@"category":[NSString stringWithString:[self pickerView:_categoryPickerView titleForRow:[self.categoryPickerView selectedRowInComponent:0] forComponent:1]]};
            
            NSLog(@"request info post data=%@",postData);
            
            //subject + category
            
            
            INDWebServiceModel* requestInfoWebService=[[INDWebServiceModel alloc] initWithDelegate:self url:[NSURL URLWithString:webServiceUrlPath] NameOfWebService:requestinfo];
            NSLog(@"web service request=%@",requestInfoWebService);
            
            [requestInfoWebService setPostData:postData];
            [[INDWebservices shared] startWebserviceOperation:requestInfoWebService];
            
            sendMessageHud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            sendMessageHud.mode=MBProgressHUDModeIndeterminate;
            sendMessageHud.delegate=self;
            sendMessageHud.labelText=@"Sending";
            
        }
        
    }
    else
    {
        NSLog(@"Internet connection not avalible");
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"Request Information";
  // NSLog(@"title for row =%@",[self pickerView:_categoryPickerView titleForRow:0 forComponent:1]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark-Web services
-(void)completionOperationWithSuccess:(id)operation responseData:(id)responseObject webServiceOperationObject:(INDWebServiceModel *)webServiceOperationObject
{
    if (webServiceOperationObject.serviceName==requestinfo)
    {
        //do operation
        NSLog(@"response object=%@",responseObject);
        
        sendMessageHud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        sendMessageHud.mode = MBProgressHUDModeCustomView;
        sendMessageHud.labelText = @"Message sent successful";
        [sendMessageHud show:YES];
        [sendMessageHud hide:YES afterDelay:2];
    }
    
}



-(void)completionOperationWithFailure:(id)operation error:(NSError *)error webServiceOperationObject:(INDWebServiceModel *)webServiceOperationObject
{
    if (webServiceOperationObject.serviceName==requestinfo) {
        
        sendMessageHud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"close.png"]];
        sendMessageHud.mode = MBProgressHUDModeCustomView;
        sendMessageHud.delegate = self;
        sendMessageHud.labelText = @"Failed to send the message";
        sendMessageHud.delegate=nil;
        [sendMessageHud show:YES];
        [sendMessageHud hide:YES afterDelay:2];
    }
}

-(void)hudWasHidden:(MBProgressHUD *)hud
{
    if ([hud.labelText isEqualToString:@"Message sent successful"]) {
        if (isiPhone5) {
            [self.navigationController popViewControllerAnimated:YES];
        }else
            [mypopoverController dismissPopoverAnimated:YES];
    }
   
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView: (UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component {
    //NSLog(@"%d",[INDConfigModel shared].requestInfoCategory.count);
    //return [INDConfigModel shared].requestInfoCategory.count;
    return pickerDataSource.count;
}

//-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    [self.categoryPickerView selectedRowInComponent:1]=row;
//}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [pickerDataSource objectAtIndex:row];
}


# pragma mark- validation

-(BOOL)validateSubject
{
    if ([self.subjectOtl.text isEqualToString:@""])
    {
        return YES;
    }
    else
        return NO;
}
-(BOOL)validateInputTextField
{
    if ([self.otlTextView.text isEqualToString:@""])
    {
        return YES;
        
    }
    else
        return NO;
}
-(BOOL)validateSelectedCatrgory:(NSUInteger)selectedRow
{
    if ([[self pickerView:_categoryPickerView titleForRow:selectedRow forComponent:1] isEqualToString:@"Select The Category"])
    {
        return YES;
        
    }
    else
        return NO;
}

-(BOOL)validateInputValues
{
    NSLog(@"validateInputValues");
    
    BOOL validateFlag = YES;
    
    if ([ self validateSelectedCatrgory:[self.categoryPickerView selectedRowInComponent:0]]) {
        
        [self addMsgVC:@"Please Select The Category"];
        validateFlag = NO;
        
        [self performSelector:@selector(removeMsgVC) withObject:self afterDelay:2.0];
    }
    
   else if ([self validateSubject])
    {
        [self addMsgVC:@"Please Enter Subject"];
        validateFlag = NO;
        
        [self performSelector:@selector(removeMsgVC) withObject:self afterDelay:2.0];
    }
 
    
  else if ([self validateInputTextField])
       
    {
        [self addMsgVC:@"Please Enter Text"];
        validateFlag = NO;
        
        [self performSelector:@selector(removeMsgVC) withObject:self afterDelay:2.0];
    }
    
    return validateFlag;
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
