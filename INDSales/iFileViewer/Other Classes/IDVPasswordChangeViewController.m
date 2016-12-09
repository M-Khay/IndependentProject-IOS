//
//  IDVPasswordChangeViewController.m
//  iDocViewer
//
//  Created by Krishna on 19/12/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import "IDVPasswordChangeViewController.h"
#define NUMBERS_ONLY @"1234567890"
#define CHARACTER_LIMIT 4
@interface IDVPasswordChangeViewController ()

@end

@implementation IDVPasswordChangeViewController
@synthesize otl_TxtConfirmNewPassword,otl_TxtNewPassword,otl_TxtOldPassword;
@synthesize otl_TxtPassword,otl_LblMessage,otl_PasswordChangeSubmit,otl_BtnPasswordSubmit,otl_BtnPasswordCancel,otl_BtnChangePassword,otl_BtnPasswordChangeCancel;
@synthesize otl_PasswordView,otl_SecurityQuestionView,otl_SetPasswordView;
@synthesize otl_TxtPasswordInSetPasswordVIew,otl_TxtConfirmPasswordInSetPasswordVIew,otl_TxtSecurityQ1PasswordView,otl_TxtSecurityQ2PasswordView,otl_BtnCancelInSetPassword,otl_BtnSubmitInSetPaword,otl_LblChangePassword;
@synthesize otl_BtnForgotPasscode;
@synthesize otl_TxtSecurityQ1_InSecurityQView,otl_TxtSecurityQ2_InSecurityQView;

@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    scrollView.scrollEnabled = YES;
    scrollView.contentSize = scrollView.bounds.size;
    // [otl_TxtPassword becomeFirstResponder];
    
    self.otl_TxtOldPassword.hidden=YES;
    self.otl_TxtNewPassword.hidden=YES;
    self.otl_TxtConfirmNewPassword.hidden=YES;
    self.otl_PasswordChangeSubmit.hidden=YES;
    self.otl_BtnPasswordChangeCancel.hidden=YES;
    
    self.otl_BtnPasswordCancel.hidden=NO;
    self.otl_BtnPasswordSubmit.hidden=NO;
    self.otl_LblMessage.hidden=NO;
    self.otl_TxtPassword.hidden=NO;
    self.otl_BtnChangePassword.hidden=NO;
    
    
    self.otl_TxtConfirmNewPassword.secureTextEntry=YES;
    self.otl_TxtNewPassword.secureTextEntry=YES;
    self.otl_TxtOldPassword.secureTextEntry=YES;
    self.otl_TxtPassword.secureTextEntry=YES;
    
    self.otl_TxtConfirmNewPassword.keyboardType=UIKeyboardTypeNumberPad;
    self.otl_TxtNewPassword.keyboardType=UIKeyboardTypeNumberPad;
    self.otl_TxtOldPassword.keyboardType=UIKeyboardTypeNumberPad;
    self.otl_TxtPassword.keyboardType=UIKeyboardTypeNumberPad;
    self.otl_TxtNewPassword.delegate=self;
    self.otl_TxtNewPassword.tag=1;
    self.otl_TxtConfirmNewPassword.delegate=self;
    self.otl_TxtConfirmNewPassword.tag=2;
    self.otl_TxtPasswordInSetPasswordVIew.delegate=self;
    self.otl_TxtPasswordInSetPasswordVIew.tag=3;
    self.otl_TxtPasswordInSetPasswordVIew.secureTextEntry = YES;
    
    self.otl_TxtConfirmPasswordInSetPasswordVIew.delegate=self;
    self.otl_TxtConfirmPasswordInSetPasswordVIew.secureTextEntry=YES;
    self.otl_LblChangePassword.hidden=YES;
    
    self.otl_PasswordView.layer.borderWidth = 3.0f;
    self.otl_PasswordView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.otl_SetPasswordView.layer.borderWidth = 3.0f;
    self.otl_SetPasswordView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.otl_SecurityQuestionView.layer.borderWidth = 3.0f;
    self.otl_SecurityQuestionView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.otl_TxtSecurityQ1_InSecurityQView.delegate=self;
    self.otl_TxtSecurityQ2_InSecurityQView.delegate=self;
    self.otl_TxtSecurityQ1PasswordView.delegate=self;
    self.otl_TxtSecurityQ2PasswordView.delegate=self;
    self.otl_TxtPassword.delegate=self;

    BOOL isSetPass = [[ NSUserDefaults standardUserDefaults ] boolForKey:@"setPasscode" ];
    
    if (isSetPass)
    {
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [scrollView addSubview:otl_PasswordView];
        }
        else
        {
            [self.view addSubview:otl_PasswordView];
        }

        [self.otl_TxtPassword becomeFirstResponder];
        otl_PasswordView.hidden=NO;
        otl_SetPasswordView.hidden=YES;
        otl_SecurityQuestionView.hidden=YES;
    }
    else
    {
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [scrollView addSubview:otl_SetPasswordView];
        }
        else
        {
            [self.view addSubview:otl_SetPasswordView];
        }
        
        [self.otl_TxtPasswordInSetPasswordVIew becomeFirstResponder];
        otl_PasswordView.hidden=YES;
        otl_SetPasswordView.hidden=NO;
        otl_SecurityQuestionView.hidden=YES;
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;

    }
    
    [self addKeyboardNotificationHandler];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layoutPasswordViews];
}

- (void)layoutPasswordViews
{
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        otl_PasswordView.center = self.view.center;
        otl_SetPasswordView.center = self.view.center;
        otl_SecurityQuestionView.center = self.view.center;
    }
    else
    {
        otl_PasswordView.center = scrollView.center;
        CGRect viewFrame = otl_PasswordView.frame;
        viewFrame.origin.y = 20.0;
        otl_PasswordView.frame = viewFrame;
        
        otl_SetPasswordView.center = scrollView.center;
        viewFrame = otl_SetPasswordView.frame;
        viewFrame.origin.y = 20.0;
        otl_SetPasswordView.frame = viewFrame;
        
        otl_SecurityQuestionView.center = scrollView.center;
        viewFrame = otl_SecurityQuestionView.frame;
        viewFrame.origin.y = 20.0;
        otl_SecurityQuestionView.frame = viewFrame;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickCancelPassword:(id)sender
{
    //[self dismissViewControllerAnimated:YES completion:nil];
    
    [self.view removeFromSuperview];
    [self.otl_PasswordView removeFromSuperview];
    self.otl_PasswordView=nil;
    [self.delegate cancelPasswordModelViewController];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)onClickSubmitPassword:(id)sender
{
    if ([otl_TxtPassword.text isEqualToString:@""])
    {
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:otl_PasswordView animated:YES];
        HUD.delegate = self;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
        }
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"Please Enter The Passcode";
        
        [ HUD hide:YES afterDelay:1];
        
    }
    else if([[[ NSUserDefaults standardUserDefaults ] objectForKey:@"passcode"] isEqualToString:otl_TxtPassword.text])
    {
        
        [self.delegate submitPasswordChangeDelegateMethod];
        [self.view removeFromSuperview];
        [self.delegate didSubmitPassword];
    }
    else
    {
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:otl_PasswordView animated:YES];
        HUD.delegate = self;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
        }
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"Incorrect Passcode";
        
        [ HUD hide:YES afterDelay:1];
    }
    
}

- (IBAction)onClickSubmitNewPassword:(id)sender
{
    
    if ([otl_TxtOldPassword.text isEqualToString:@""]||[otl_TxtNewPassword.text isEqualToString:@""]||[otl_TxtConfirmNewPassword.text isEqualToString:@""])
    {
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:otl_PasswordView animated:YES];
        HUD.delegate = self;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
        }
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"Please Fill All The Fields";
        
        [ HUD hide:YES afterDelay:1];
        
    }
    else if([[[ NSUserDefaults standardUserDefaults ] objectForKey:@"passcode"] isEqualToString:otl_TxtOldPassword.text])
    {
        if([[[ NSUserDefaults standardUserDefaults ] objectForKey:@"passcode"] isEqualToString:otl_TxtOldPassword.text])
        {
            if([otl_TxtNewPassword.text isEqualToString:otl_TxtConfirmNewPassword.text])
            {
                NSString *inputText = otl_TxtNewPassword.text;
                
                
                [[ NSUserDefaults standardUserDefaults ] setObject:inputText forKey:@"passcode"];
                [self dismissViewControllerAnimated:YES completion:nil];
                [self.view removeFromSuperview];
                [self.delegate didSubmitPassword];
                [self.delegate didChangePassword];
                
            }
            else
            {
                MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:otl_PasswordView animated:YES];
                HUD.delegate = self;
                if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
                {
                    HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
                }
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = @"Password Mismatch";
                
                [ HUD hide:YES afterDelay:1];
            }
        }
    }
    else
    {
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:otl_PasswordView animated:YES];
        HUD.delegate = self;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
        }
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"Incorrect Old Password";
        
        [ HUD hide:YES afterDelay:1];
    }
    
    //    [self.delegate changePassword];
    
}

- (IBAction)onClickCancelChangePassword:(id)sender
{
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.view removeFromSuperview];
    [self.otl_PasswordView removeFromSuperview];
    self.otl_PasswordView=nil;
    [self.delegate cancelPasswordModelViewController];
    
}

- (IBAction)onClickShowSecurityQView:(id)sender
{
    otl_PasswordView.hidden=YES;
    otl_SetPasswordView.hidden=YES;
    otl_SecurityQuestionView.hidden=NO;
    
    if (otl_SetPasswordView.superview)
    {
        [otl_SetPasswordView removeFromSuperview];
    }
    
    if (otl_PasswordView.superview)
    {
        [otl_PasswordView removeFromSuperview];
    }

    otl_SecurityQuestionView.center = self.view.center;
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        CGRect securityViewFrame = otl_SecurityQuestionView.frame;
        securityViewFrame.origin.y = 20.0;
        otl_SecurityQuestionView.frame = securityViewFrame;
        
        [scrollView addSubview:otl_SecurityQuestionView];
    }
    else
    {
        otl_SecurityQuestionView.center = self.view.center;
        [self.view addSubview:otl_SecurityQuestionView];
    }
   // [self.otl_TxtSecurityQ1_InSecurityQView becomeFirstResponder];
    [self addKeyboardNotificationHandler];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutPasswordViews];
}

#pragma mark -
#pragma mark Keyboard Notifications Handler
#pragma mark -

-(void)addKeyboardNotificationHandler
{
    __weak IDVPasswordChangeViewController *weakSelf = self;
    __weak UIView *currentTopView = nil;
    
    if(otl_SetPasswordView.superview)
    {
        currentTopView = self.otl_SetPasswordView;
    }
    else if(otl_SecurityQuestionView.superview)
    {
        currentTopView = self.otl_SecurityQuestionView;
    }
    else if(otl_PasswordView.superview)
    {
        currentTopView = self.otl_PasswordView;
    }
   
    
    //Notification for keyboard show and hide handling
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note){
                                                      
                                                      NSDictionary* info = [note userInfo];
                                                      CGSize kbSize = [weakSelf.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] toView:nil].size;
                                                      NSTimeInterval duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
                                                      UIViewAnimationCurve curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
                                                      
                                                      CGFloat hiddenPortion = ((currentTopView.frame.origin.y + currentTopView.bounds.size.height) - (scrollView.bounds.size.height - kbSize.height));
                                                      
                                                      if (hiddenPortion > 0)
                                                      {
                                                          if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                                                          {
                                                              [UIView animateWithDuration:duration
                                                                                    delay:0.0
                                                                                  options:UIViewAnimationOptionBeginFromCurrentState | curve
                                                                               animations:^{
                                                                                   
                                                                                   weakSelf.scrollView.contentSize = CGSizeMake(weakSelf.scrollView.bounds.size.width, weakSelf.scrollView.bounds.size.height + hiddenPortion);
                                                                               }
                                                                               completion:nil];
                                                          }
                                                          else
                                                          {
                                                              hiddenPortion = ((currentTopView.frame.origin.y + currentTopView.bounds.size.height) - (self.view.bounds.size.height - kbSize.height));
                                                              hiddenPortion += 65.0;
                                                              CGRect topViewFrame = currentTopView.frame;
                                                              topViewFrame.origin.y -= hiddenPortion;

                                                              if (hiddenPortion > 0)
                                                              {
                                                                  [UIView animateWithDuration:duration
                                                                                        delay:0.0
                                                                                      options:UIViewAnimationOptionBeginFromCurrentState | curve
                                                                                   animations:^{
                                                                                       
                                                                                       currentTopView.frame = topViewFrame;
                                                                                   }
                                                                                   completion:nil];
                                                              }
                                                          }
                                                      }
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note){
                                                      
                                                      [UIView animateWithDuration:0.25 animations:^(void){
                                                          
                                                          if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                                                          {
                                                              [UIView animateWithDuration:0.25 animations:^(void){
                                                                  
                                                                  weakSelf.scrollView.contentSize = scrollView.bounds.size;
                                                              }];
                                                          }
                                                          else
                                                          {
                                                              currentTopView.center = self.view.center;
                                                          }
                                                      }];
                                                  }];
}

/*
- (void)keyboardWillShow:(NSNotification *)note
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft || interfaceOrientation==UIInterfaceOrientationLandscapeRight)
    {
        CGRect newTextFieldFrame;
        
        if(otl_SetPasswordView.hidden==NO)
        {
            newTextFieldFrame = self.otl_SetPasswordView.frame;
        }
        else if(otl_SecurityQuestionView.hidden==NO)
        {
            newTextFieldFrame = self.otl_SecurityQuestionView.frame;
        }
        else if(otl_PasswordView.hidden==NO)
        {
            newTextFieldFrame = self.otl_PasswordView.frame;
        }
        
        NSDictionary *userInfo = note.userInfo;
        NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
        
        CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect keyboardFrameForTextField = [self.view.superview convertRect:keyboardFrame fromView:nil];
        
        // CGRect newTextFieldFrame = self.otl_SetPasswordView.frame;
        newTextFieldFrame.origin.y = keyboardFrameForTextField.origin.y - newTextFieldFrame.size.height;
        if (!otl_PasswordView.hidden)
        {
            newTextFieldFrame.origin.y -= 60.0;
        }
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
            
            if(otl_SetPasswordView.hidden==NO)
            {
                self.otl_SetPasswordView.frame=newTextFieldFrame;
            }
            else if(otl_SecurityQuestionView.hidden==NO)
            {
                self.otl_SecurityQuestionView.frame=newTextFieldFrame;
            }
            else if(otl_PasswordView.hidden==NO)
            {
                self.otl_PasswordView.frame = newTextFieldFrame;
            }
            // self.otl_SetPasswordView.frame = newTextFieldFrame;
        }
                         completion:nil];
    }
}

- (void)keyboardWillHide:(NSNotification *)note
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft || interfaceOrientation==UIInterfaceOrientationLandscapeRight)
    {
        CGRect newTextFieldFrame;
        if(otl_SetPasswordView.hidden==NO)
        {
            newTextFieldFrame = self.otl_SetPasswordView.frame;
        }
        else if(otl_SecurityQuestionView.hidden==NO)
        {
            newTextFieldFrame = self.otl_SecurityQuestionView.frame;
        }
        else if(otl_PasswordView.hidden==NO)
        {
            newTextFieldFrame = self.otl_PasswordView.frame;
        }
        
        NSDictionary *userInfo = note.userInfo;
        NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
        
        CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect keyboardFrameForTextField = [self.view.superview convertRect:keyboardFrame fromView:nil];
        
        //  CGRect newTextFieldFrame = self.otl_SetPasswordView.frame;
        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            newTextFieldFrame.origin.y = keyboardFrameForTextField.origin.y - newTextFieldFrame.size.height-50;
        }
        else
        {
            newTextFieldFrame.origin.y = keyboardFrameForTextField.origin.y - newTextFieldFrame.size.height-250;
        }
        
        // newTextFieldFrame.origin.y -= 104;   //For TabBar
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
            if(otl_SetPasswordView.hidden==NO)
            {
                self.otl_SetPasswordView.frame=newTextFieldFrame;
            }
            else if(otl_SecurityQuestionView.hidden==NO)
            {
                self.otl_SecurityQuestionView.frame=newTextFieldFrame;
            }
            else if(otl_PasswordView.hidden==NO)
            {
                self.otl_PasswordView.frame=newTextFieldFrame;
            }
            // self.otl_SetPasswordView.frame = newTextFieldFrame;
        }
                         completion:nil];
    }
}
 */

- (IBAction)onClickChangePassword:(id)sender
{
    
    if (otl_SetPasswordView.superview)
    {
        [otl_SetPasswordView removeFromSuperview];
    }
    
    //    if (otl_PasswordView.superview)
    //    {
    //        [otl_PasswordView removeFromSuperview];
    //    }
    
    [otl_TxtOldPassword becomeFirstResponder];
    
    self.otl_TxtOldPassword.hidden=NO;
    self.otl_TxtNewPassword.hidden=NO;
    self.otl_TxtConfirmNewPassword.hidden=NO;
    self.otl_PasswordChangeSubmit.hidden=NO;
    self.otl_BtnPasswordChangeCancel.hidden=NO;
    self.otl_LblChangePassword.hidden=NO;
    
    self.otl_BtnPasswordCancel.hidden=YES;
    self.otl_BtnPasswordSubmit.hidden=YES;
    self.otl_LblMessage.hidden=YES;
    self.otl_TxtPassword.hidden=YES;
    self.otl_BtnChangePassword.hidden=YES;
    
}
- (IBAction)otl_BtnPasswordChageSubmit:(id)sender
{
    
}

#pragma mark textfield delegate method

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    // Check for non-numeric characters
    if(textField.tag==3)
    {
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS_ONLY] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        
        if(![string isEqualToString:filtered])
        {
            
            MBProgressHUD *unzipHud = [MBProgressHUD showHUDAddedTo:otl_SetPasswordView animated:YES];
            unzipHud.delegate=self;
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                unzipHud.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
            }
            unzipHud.mode = MBProgressHUDModeCustomView;
            unzipHud.labelText = @"Passcode should be numeric";
            [unzipHud hide:YES afterDelay:1];
            
            return NO;
        }
        if((newLength > CHARACTER_LIMIT))
        {
            
            MBProgressHUD *unzipHud = [MBProgressHUD showHUDAddedTo:otl_SetPasswordView animated:YES];
            unzipHud.delegate=self;
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                unzipHud.labelFont=[UIFont fontWithName:@"Helvetica" size:10];
            }
            unzipHud.mode = MBProgressHUDModeCustomView;
            unzipHud.labelText = @"Passcode cannot be more than 4 digits";
            [unzipHud hide:YES afterDelay:1];
            
            return NO;
        }
        return YES;
    }
    else
    {
        return YES;
    }
}


- (IBAction)onClickSubmitInSetPasswordView:(id)sender
{
    if ([otl_TxtPasswordInSetPasswordVIew.text isEqualToString:@""]|| [otl_TxtConfirmPasswordInSetPasswordVIew.text isEqualToString:@""])
    {
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:otl_SetPasswordView animated:YES];
        HUD.delegate = self;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:10];
        }
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"Please fill  both the passcode fields";
        
        [ HUD hide:YES afterDelay:1];
        
    }
    
    
    else if(![otl_TxtPasswordInSetPasswordVIew.text isEqualToString: otl_TxtConfirmPasswordInSetPasswordVIew.text ])
    {
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:otl_SetPasswordView animated:YES];
        HUD.delegate = self;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
        }
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"Password Mismatch";
        
        [ HUD hide:YES afterDelay:1];
        
    }
    
    else if([otl_TxtSecurityQ1PasswordView.text isEqualToString:@""]||[otl_TxtSecurityQ2PasswordView.text isEqualToString:@""])
    {
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:otl_SetPasswordView animated:YES];
        HUD.delegate = self;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:10];
        }
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"Please Answer Both the security questions";
        
        [ HUD hide:YES afterDelay:1];
    }
    
    else
    {
        NSString *inputText = otl_TxtPasswordInSetPasswordVIew.text;
        //// validating here...
        
        [[ NSUserDefaults standardUserDefaults ] setObject:inputText forKey:@"passcode"];
        
        // isPosswordSet=NO;
        [[ NSUserDefaults standardUserDefaults ] setBool:YES forKey:@"setPasscode"];
        [[ NSUserDefaults standardUserDefaults ] setObject:otl_TxtSecurityQ1PasswordView.text forKey:@"SecurityQ1"];
        [[ NSUserDefaults standardUserDefaults ] setObject:otl_TxtSecurityQ2PasswordView.text forKey:@"SecurityQ2"];
        [self.delegate didSubmitPassword];
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:otl_SetPasswordView animated:YES];
        HUD.delegate = self;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
        }
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"Password is set successfully";
        
        [ HUD hide:YES afterDelay:1];
        //[self dismissViewControllerAnimated:NO completion:nil];
        [self.view removeFromSuperview];
    }
    
}

- (IBAction)onClickCancel_InSetPasswordView:(id)sender
{
    // [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.view removeFromSuperview];
    [self.delegate cancelPasswordModelViewController];
}



- (IBAction)onClickSubmitInSecurityView:(id)sender
{
    if ([otl_TxtSecurityQ1_InSecurityQView.text isEqualToString:@""]||[otl_TxtSecurityQ2_InSecurityQView.text isEqualToString:@""])
    {
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:otl_SecurityQuestionView animated:YES];
        HUD.delegate = self;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:10];
        }
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"Please Answer Both the security questions";
        
        [ HUD hide:YES afterDelay:1];
        
    }
    else if([[[ NSUserDefaults standardUserDefaults ] objectForKey:@"SecurityQ1"] isEqualToString:otl_TxtSecurityQ1_InSecurityQView.text])
    {
        if([[[ NSUserDefaults standardUserDefaults ] objectForKey:@"SecurityQ2"] isEqualToString:otl_TxtSecurityQ2_InSecurityQView.text])
        {
            
            //[self dismissViewControllerAnimated:YES completion:nil];
            //$$$$
            
            otl_PasswordView.hidden=YES;
            otl_SetPasswordView.hidden=NO;
            otl_SecurityQuestionView.hidden=YES;
            
            if (otl_PasswordView.superview)
            {
                [otl_PasswordView removeFromSuperview];
            }
            
            if (otl_SecurityQuestionView.superview)
            {
                [otl_SecurityQuestionView removeFromSuperview];
            }

            [self.otl_TxtOldPassword becomeFirstResponder];
            
            otl_SetPasswordView.center=self.view.center;
            
            [self.view addSubview:otl_SetPasswordView];
            
            //$$$
        }
        else
        {
            MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:otl_SecurityQuestionView animated:YES];
            HUD.delegate = self;
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:10];
            }
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = @"Second security question is incorrect";
            
            [ HUD hide:YES afterDelay:1];
        }
    }
    else
    {
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:otl_SecurityQuestionView animated:YES];
        HUD.delegate = self;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:10];
        }
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"First security question is incorrect";
        
        [ HUD hide:YES afterDelay:1];
    }
}

- (IBAction)onClickCancel_InSecurityQView:(id)sender
{
    // [self dismissViewControllerAnimated:YES completion:nil];
    [self.view removeFromSuperview];
    [otl_SecurityQuestionView removeFromSuperview];
    self.otl_SecurityQuestionView=nil;
    [self.delegate cancelPasswordModelViewController];
    
}

#pragma mark- dismiss keyboard
/*- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 
 UITouch *touch = [[event allTouches] anyObject];
 
 if (![[touch view] isKindOfClass:[UITextField class]]) {
 if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
 {
 [self.scrollView endEditing:YES];
 }
 else
 {
 [self.view endEditing:YES];
 }
 }
 [super touchesBegan:touches withEvent:event];
 } */

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}
/*- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UIView * txt in self.view.subviews){
        if ([txt isKindOfClass:[UITextField class]] && [txt isFirstResponder]) {
            [txt resignFirstResponder];
        }
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}*/
@end
