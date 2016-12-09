//
//  IDVPasswordChangeViewController.h
//  iDocViewer
//
//  Created by Krishna on 19/12/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//
@protocol PasswordChangeDelegate <NSObject>

@optional
-(void)didChangePassword;
-(void)cancelPasswordModelViewController;
-(void)didSubmitPassword;
-(void) submitPasswordChangeDelegateMethod;
@end

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
//#import "Transition Delegate/TransitionDelegate.h"
#import "DatasourceSingltonClass.h"
@interface IDVPasswordChangeViewController : UIViewController<MBProgressHUDDelegate,UITextFieldDelegate>

@property (strong, nonatomic) id<PasswordChangeDelegate>delegate;

@property (strong, nonatomic) IBOutlet UIView *otl_PasswordView;
@property (strong, nonatomic) IBOutlet UIView *otl_SetPasswordView;
@property (strong, nonatomic) IBOutlet UIView *otl_SecurityQuestionView;

#pragma mark- enter password view

@property (strong, nonatomic) IBOutlet UITextField *otl_TxtOldPassword;
@property (strong, nonatomic) IBOutlet UITextField *otl_TxtNewPassword;
@property (strong, nonatomic) IBOutlet UITextField *otl_TxtConfirmNewPassword;


@property (strong, nonatomic) IBOutlet UITextField *otl_TxtPassword;
@property (strong, nonatomic) IBOutlet UILabel *otl_LblMessage;
@property (strong, nonatomic) IBOutlet UIButton *otl_BtnPasswordSubmit;
@property (strong, nonatomic) IBOutlet UIButton *otl_BtnPasswordCancel;
@property (strong, nonatomic) IBOutlet UIButton *otl_PasswordChangeSubmit;
@property (strong, nonatomic) IBOutlet UIButton *otl_BtnPasswordChangeCancel;
@property (strong, nonatomic) IBOutlet UIButton *otl_BtnChangePassword;
@property (weak, nonatomic) IBOutlet UIButton *otl_BtnForgotPasscode;

- (IBAction)onClickCancelPassword:(id)sender;
- (IBAction)onClickSubmitPassword:(id)sender;
- (IBAction)onClickSubmitNewPassword:(id)sender;
- (IBAction)onClickCancelChangePassword:(id)sender;
- (IBAction)onClickShowSecurityQView:(id)sender;


#pragma mark- Set password view
@property (weak, nonatomic) IBOutlet UITextField *otl_TxtPasswordInSetPasswordVIew;

@property (weak, nonatomic) IBOutlet UITextField *otl_TxtConfirmPasswordInSetPasswordVIew;

@property (weak, nonatomic) IBOutlet UITextField *otl_TxtSecurityQ1PasswordView;
@property (weak, nonatomic) IBOutlet UITextField *otl_TxtSecurityQ2PasswordView;

@property (weak, nonatomic) IBOutlet UILabel *otl_LblSecurityQ;
@property (weak, nonatomic) IBOutlet UILabel *otl_LblChangePassword;

@property (weak, nonatomic) IBOutlet UIButton *otl_BtnSubmitInSetPaword;
@property (weak, nonatomic) IBOutlet UIButton *otl_BtnCancelInSetPassword;


- (IBAction)onClickSubmitInSetPasswordView:(id)sender;
- (IBAction)onClickCancel_InSetPasswordView:(id)sender;

#pragma mark- Security Question view

@property (weak, nonatomic) IBOutlet UITextField *otl_TxtSecurityQ1_InSecurityQView;
@property (weak, nonatomic) IBOutlet UITextField *otl_TxtSecurityQ2_InSecurityQView;
- (IBAction)onClickSubmitInSecurityView:(id)sender;
- (IBAction)onClickCancel_InSecurityQView:(id)sender;



@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
