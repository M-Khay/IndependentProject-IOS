//
//  INDAddCustomerVC.m
//  INDSales
//
//////  Created by Kush on 13/11/16.
//

#import "INDAddCustomerVC.h"
#import "MMPickerView.h"

@interface INDAddCustomerVC ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *firstnameTextField;
@property (strong, nonatomic) IBOutlet UITextField *lastnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *countryCodeTextField;

@property (strong, nonatomic) IBOutlet UITextField *companyTextField;
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;

@property (strong, nonatomic) IBOutlet UITextField *AlternatenumberTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UIButton *addBtn;
@property (strong, nonatomic) IBOutlet UIView *otl_PhotoMenuView;
@property (strong, nonatomic) IBOutlet UITextField *designationTextField;

@property (strong, nonatomic) IBOutlet UITextField *otherinfoTextField;
@property(assign,nonatomic)BOOL newMedia;

@property (strong, nonatomic) INDMessageVC *msgVC;
@property (strong, nonatomic) IBOutlet UIImageView *otl_ImageView;
@property (strong,nonatomic) UIPopoverController *popoverController;
@property (weak, nonatomic) IBOutlet UITextField *otlCountryLbl;
@property (strong,nonatomic) NSData *savedImageData;
@property (strong, nonatomic) IBOutlet UIScrollView *contactScrollView;

@end

@implementation INDAddCustomerVC
@synthesize addNewOrSave,customerDetail,otl_PhotoMenuView,otl_ImageView,savedImageData;
@synthesize firstnameTextField,lastnameTextField,companyTextField,phoneTextField,AlternatenumberTextField,emailTextField,otherinfoTextField,newMedia,popoverController,otlCountryLbl,countryCodeTextField,designationTextField,contactScrollView;

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
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:otl_ImageView.bounds];
    otl_ImageView.layer.shadowPath = path.CGPath;
    
    otl_PhotoMenuView.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
    
    
    
    if (addNewOrSave!=saveExisting) {
        addNewOrSave=addNew;
        
    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:customerDetail.photoPath])
    {
        otl_ImageView.image=[UIImage imageWithContentsOfFile:customerDetail.photoPath];
    }
    else
    {
        otl_ImageView.image=[UIImage imageNamed:@"avtar.png"];
    }
    
    if (addNewOrSave==saveExisting) {
        firstnameTextField.text=customerDetail.firstname;
        lastnameTextField.text=customerDetail.lastname;
        companyTextField.text=customerDetail.company;
        phoneTextField.text=customerDetail.phone;
        AlternatenumberTextField.text=customerDetail.alternatenumber;
        emailTextField.text=customerDetail.email;
        otherinfoTextField.text=customerDetail.otherinfo;
        [_addBtn setTitle:@"Save" forState:UIControlStateNormal];
        savedImageData=[NSData dataWithContentsOfFile:customerDetail.photoPath];
        otlCountryLbl.text=customerDetail.country;
        countryCodeTextField.text=customerDetail.countryCode;
        designationTextField.text=customerDetail.designation;
        
    }
    
    otl_ImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    otl_ImageView.layer.shadowOpacity = 0.7f;
    otl_ImageView.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
    otl_ImageView.layer.shadowRadius = 5.0f;
    otl_ImageView.layer.masksToBounds = NO;
    
    otlCountryLbl.delegate=self;
    emailTextField.delegate=self;
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (isiPhone5) {
        [contactScrollView setContentSize:CGSizeMake(contactScrollView.frame.size.width, contactScrollView.frame.size.height+150)];
    }
    
    if (otlCountryLbl==textField) {
        [self textFieldDidEndEditing:emailTextField];
        [self textFieldDidEndEditing:firstnameTextField];
        [self textFieldDidEndEditing:lastnameTextField];
        [self textFieldDidEndEditing:companyTextField];
        [self textFieldDidEndEditing:phoneTextField];
        [self textFieldDidEndEditing:AlternatenumberTextField];
        [self textFieldDidEndEditing:designationTextField];
        [self textFieldDidEndEditing:otherinfoTextField];
        [self textFieldDidEndEditing:countryCodeTextField];
        return NO;
    }
    else return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}


-(void)viewWillAppear:(BOOL)animated
{
    //   [self.navigationItem setHidesBackButton:YES];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)addCustomer:(id)sender {
    [self.view endEditing:YES];
    
    if (isiPhone5) {
        [contactScrollView setContentSize:CGSizeMake(contactScrollView.frame.size.width, contactScrollView.frame.size.height)];
    }
    
    if(self.validateInputValues)
    {
        if (![self.firstnameTextField.text isEqualToString:@""]&&![self.companyTextField.text isEqualToString:@""]) {
            
            NSManagedObjectContext *managedObjectContext  = [APP_DELEGATE managedObjectContext];
            
            NSError *error = nil;
            NSString *customerPhotoPath;
            
            if (addNewOrSave==addNew) {
                NSManagedObject *newManagedObject =[NSEntityDescription insertNewObjectForEntityForName:@"Customer" inManagedObjectContext:managedObjectContext];
                [newManagedObject setValue:self.firstnameTextField.text forKey:@"firstname"];
                [newManagedObject setValue:self.lastnameTextField.text forKey:@"lastname"];
                [newManagedObject setValue:self.companyTextField.text forKey:@"company"];
                [newManagedObject setValue:self.phoneTextField.text forKey:@"phone"];
                [newManagedObject setValue:self.emailTextField.text forKey:@"email"];
                [newManagedObject setValue:self.AlternatenumberTextField.text forKey:@"alternatenumber"];
                [newManagedObject setValue:self.otherinfoTextField.text forKey:@"otherinfo"];
                [newManagedObject setValue:self.designationTextField.text forKey:@"designation"];
                [newManagedObject setValue:self.otlCountryLbl.text forKey:@"country"];
                [newManagedObject setValue:self.countryCodeTextField.text forKey:@"countryCode"];
                
                BOOL isDIR=YES;
                
                NSInteger customer_ID = [[NSUserDefaults standardUserDefaults] integerForKey:@"customer_ID"];
                NSString* customerID = [NSString stringWithFormat:@"%i", customer_ID];
                
                NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                
                NSString *fileName=[documentsPath stringByAppendingPathComponent:@"Customer_Photos"];
                
                customerPhotoPath = [fileName stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",customerID,@"png"]];
                
                customer_ID++;
                
                [[NSUserDefaults standardUserDefaults]setInteger:customer_ID forKey:@"customer_ID"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if(![[NSFileManager defaultManager] fileExistsAtPath:fileName isDirectory:&isDIR])
                {
                    [[NSFileManager defaultManager] createDirectoryAtPath:fileName withIntermediateDirectories:YES attributes:nil error:&error];
                }
                
                
                [newManagedObject setValue:customerPhotoPath forKey:@"photoPath"];
                
            }
            else
            {
                customerDetail.firstname=self.firstnameTextField.text;
                customerDetail.lastname=self.lastnameTextField.text;
                customerDetail.company=self.companyTextField.text;
                customerDetail.phone=self.phoneTextField.text;
                customerDetail.email=self.emailTextField.text;
                customerDetail.alternatenumber=self.AlternatenumberTextField.text;
                customerDetail.otherinfo=self.otherinfoTextField.text;
                customerDetail.country=self.otlCountryLbl.text;
                customerPhotoPath=customerDetail.photoPath;
                customerDetail.countryCode=self.countryCodeTextField.text;
                customerDetail.designation=self.designationTextField.text;
            }
            
            if (savedImageData!=nil) {
                [savedImageData writeToFile:customerPhotoPath atomically:YES];
            }
            
            if (![managedObjectContext save:&error])
            {
                
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }
    }
}
//-(void)resetCustomerFields
//{
//    self.firstnameTextField.text = @"";
//    self.lastnameTextField.text = @"";
//    self.companyTextField.text = @"";
//    self.phoneTextField.text = @"";
//    self.emailTextField.text = @"";
//    self.AlternatenumberTextField.text = @"";
//    self.otherinfoTextField.text = @"";
//    self.otl_ImageView.image=[UIImage imageNamed:@"avtar.png"];
//    self.otlCountryLbl.text=@"";
//    self.countryCodeTextField.text=@"";
//}

- (IBAction)selectCountry:(UITextField *)sender {
    
    if (isiPhone5) {
        [contactScrollView setContentSize:contactScrollView.frame.size];
    }
    NSError* jsonError;
    NSArray* object=[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"countryCode" ofType:@"json"]] options:NSJSONReadingAllowFragments error:&jsonError];
    [MMPickerView pickerUseForCountry:YES];
    [MMPickerView showPickerViewInView:self.view
                           withObjects:object
                           withOptions:@{MMselectedObject:[object objectAtIndex:87]}
               objectToStringConverter:^NSString *(id object) {
                
                   return [object objectForKey:@"name"];

               }
                            completion:^(id selectedObject) {
                                NSDictionary* dic=selectedObject;
                                
                                self.otlCountryLbl.text=[dic objectForKey:@"name"];
                                self.countryCodeTextField.text=[dic objectForKey:@"dial_code"];
                            }];
    
    
}

-(void)addMSG:(NSString*)Message
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    
    self.msgVC = (INDMessageVC *)[storyboard instantiateViewControllerWithIdentifier:@"INDMessageVC"];
    
    
    [self addChildViewController:self.msgVC];
    
    [UIView animateWithDuration:0.50 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        
        
        if(isiPhone5)
        {
            self.msgVC.view.frame = CGRectMake(0,60,320,0);
            
            self.msgVC.view.frame = CGRectMake(0,60,320,50);
        }
        else
        {
            self.msgVC.view.frame = CGRectMake(0,60,768,0);
            
            self.msgVC.view.frame = CGRectMake(0,60,768,50);
        }
        
    } completion:^(BOOL finished) {
        
        [self.msgVC setTextToLabel:Message];
    }];
    
    
    [self.view addSubview:self.msgVC.view];
    
    [self.msgVC didMoveToParentViewController:self];
    
    
    [self performSelector:@selector(removeMsgVC) withObject:self afterDelay:2.0];
}


- (IBAction)cancelCustomer:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}





# pragma mark- validation methods


- (BOOL)validateEmail:(NSString*)candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,10}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}
-(BOOL)validatePhoneNumber:(NSString *)phoneNo
{
    NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:phoneNo];
}


-(BOOL)validateCompanyName
{
    if (![self.companyTextField.text isEqualToString:@""])
    {
        return YES;
        
    }
    else
        return NO;
}

-(BOOL)validateEmail
{
    if (![self.emailTextField.text isEqualToString:@""])
    {
        if ([self validateEmail:self.emailTextField.text])
            return YES;
        else
            return NO;
    }
    else
        return NO;
}
-(BOOL)validatePhoneNo
{
    NSString* phoneno=[NSString stringWithFormat:@"%@%@",countryCodeTextField.text,phoneTextField.text];
    if (![phoneno isEqualToString:@""])
    {
        if ([self validatePhoneNumber:phoneno])
            return YES;
        else
            return NO;
    }
    else
        return NO;
}
-(BOOL)validateAlternatePhoneNo
{
    if (![self.AlternatenumberTextField.text isEqualToString:@""])
    {
        if ([self validatePhoneNumber:self.AlternatenumberTextField.text])
            return YES;
        else
            return NO;
    }
    else
        return NO;
}


-(BOOL)validateInputValues
{
    
    BOOL validateFlag = YES;
    
    if ([self.firstnameTextField.text isEqualToString:@""])
    {
        [self addMsgVC:@"Enter First Name"];
        validateFlag = NO;
        
        [self performSelector:@selector(removeMsgVC) withObject:self afterDelay:2.0];
        
    }
    
    else if ([self.companyTextField.text isEqualToString:@""])
    {
        [self addMsgVC:@"Enter Company Name"];
        validateFlag = NO;
        
        [self performSelector:@selector(removeMsgVC) withObject:self afterDelay:2.0];
        
        
    }
    else if ([self.otlCountryLbl.text isEqualToString:@""])
    {
        [self addMsgVC:@"Select country name"];
        validateFlag = NO;
        
        [self performSelector:@selector(removeMsgVC) withObject:self afterDelay:2.0];
        
    }
    else if (![self validatePhoneNo]&&(![[NSString stringWithFormat:@"%@%@",self.countryCodeTextField.text,self.phoneTextField.text] isEqualToString:@""]))
    {
        [self addMsgVC:@"Invalid Phone number"];
        validateFlag = NO;
        
        [self performSelector:@selector(removeMsgVC) withObject:self afterDelay:2.0];
        
    }
    
    else if (![self validateAlternatePhoneNo]&&(![self.AlternatenumberTextField.text isEqualToString:@""]))
    {
        [self addMsgVC:@"Invalid Alternate Phone Number"];
        validateFlag = NO;
        
        [self performSelector:@selector(removeMsgVC) withObject:self afterDelay:2.0];
        
    }
    
    
    else if (![self validateEmail])
    {
        [self addMsgVC:@"Invalid Email"];
        validateFlag = NO;
        
        [self performSelector:@selector(removeMsgVC) withObject:self afterDelay:2.0];
        
    }
    return validateFlag;
    
    
}

-(void)addMsgVC:(NSString*)message
{
    
    if (![[self.view subviews]containsObject:self.msgVC]) {
        
        self.msgVC = (INDMessageVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"INDMessageVC"];
        
        
        [self addChildViewController:self.msgVC];
        
        [UIView animateWithDuration:0.50 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            
            
            if(isiPhone5)
            {
                self.msgVC.view.frame = CGRectMake(0,-10,320,0);
                
                self.msgVC.view.frame = CGRectMake(0,-10,320,40);
            }
            else
            {
                self.msgVC.view.frame = CGRectMake(0,60,768,0);
                
                self.msgVC.view.frame = CGRectMake(0,60,768,50);
            }
            
        } completion:^(BOOL finished) {
            
            [self.msgVC setTextToLabel:message];
        }];
        
        
        [self.view addSubview:self.msgVC.view];
        
        [self.msgVC didMoveToParentViewController:self];
        

    }
    
}


-(void)removeMsgVC
{
    
        [UIView animateWithDuration:0.50 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            if (isiPhone5) {
                self.msgVC.view.frame = CGRectMake(0,-10,320,40);
                
                self.msgVC.view.frame = CGRectMake(0,-10,320,0);
            }else
            {
                self.msgVC.view.frame = CGRectMake(0,60,768,40);
                
                self.msgVC.view.frame = CGRectMake(0,60,768,0);
            }
            
            
            self.msgVC.msgLabel.hidden = TRUE;
            
        } completion:^(BOOL finished) {
            
            [self.msgVC.view removeFromSuperview];
            [self.msgVC removeFromParentViewController];
        }];
        
}


- (IBAction)onClickAddPhoto:(id)sender
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        CGRect frame = otl_PhotoMenuView.frame;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.40];
        frame.origin.y =0;
        otl_PhotoMenuView.frame = frame;
        [UIView commitAnimations];
    }
    else
    {
        CGRect frame = otl_PhotoMenuView.frame;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.60];
        frame.origin.y = 60;
        otl_PhotoMenuView.frame = frame;
        [UIView commitAnimations];
    }
   
    
}


-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage  *imageToSave;

    imageToSave = [[info objectForKey:@"UIImagePickerControllerOriginalImage"]fixOrientation];

    
    if (newMedia)
    {
        UIImageWriteToSavedPhotosAlbum(imageToSave,self,@selector(image:finishedSavingWithError:contextInfo:),nil);
        
        otl_ImageView.image=imageToSave;
        savedImageData = UIImagePNGRepresentation(imageToSave);
        
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        otl_ImageView.image=imageToSave;
        
        savedImageData = UIImagePNGRepresentation(imageToSave);
        
        if(isiPhone5)
        {
            [picker dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            [self.popoverController dismissPopoverAnimated:NO];
  
        }
    }
    
    [self onClickHidePhotoMenuView:nil];
    //}
    
}
-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @""
                              message: @"Saved Successfully"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated: YES completion: nil];
}


- (IBAction)onClickHidePhotoMenuView:(id)sender
{
    CGRect frame = otl_PhotoMenuView.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.60];
    frame.origin.y = -400;
    otl_PhotoMenuView.frame = frame;
    [UIView commitAnimations];
    
}

- (IBAction)onClickCapturePhoto:(id)sender
{
    
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        
        UIImagePickerController* picker = [UIImagePickerController new];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes =
        [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        picker.delegate = self;
        picker.mediaTypes = [NSArray arrayWithObjects:
                             (NSString *) kUTTypeImage,
                             nil];
        
        [self presentViewController:picker animated:YES completion:nil];
    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message: @"Camera is not available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    newMedia=YES;
}

- (IBAction)onClickChoosePhoto:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        
        UIImagePickerController *picker= [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        
        
        
        if(isiPhone5)
        {
            [self presentViewController:picker animated:YES completion:nil];
        }
        else{
            self.popoverController = [[UIPopoverController alloc]
                                      initWithContentViewController:picker];
            self.popoverController.delegate = self;
            [popoverController presentPopoverFromRect:CGRectMake(0,8.0, 770, 127) inView:self.view  permittedArrowDirections:(UIPopoverArrowDirectionUp) animated:YES];

        }
        
        newMedia = NO;
    }
    
}

#pragma mark-Import Contacts

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
