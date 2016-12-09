//
//  INDCustomerDetailViewController.m
//  INDSales
//
//  Created by parth on 03/03/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import "INDCustomerDetailViewController.h"
#import "Customer.h"
#import "INDAddCustomerVC.h"

@interface INDCustomerDetailViewController ()
@property (strong, nonatomic) IBOutlet UILabel *fullName;
@property (strong, nonatomic) IBOutlet UILabel *companyNameOtl;
@property (strong, nonatomic) IBOutlet UILabel *phoneNoOtl;
@property (strong, nonatomic) IBOutlet UILabel *alternateNoOtl;
@property (strong, nonatomic) IBOutlet UILabel *emailAddress;
@property (strong, nonatomic) IBOutlet UITextView *othersOtl;
@property (strong, nonatomic) IBOutlet UIImageView *otlCustomerImage;
@property (strong, nonatomic) IBOutlet UILabel *designation;
@property (weak, nonatomic) IBOutlet UILabel *countryOtl;
@property (strong, nonatomic) IBOutlet UIScrollView *contactScrollView;

@end

@implementation INDCustomerDetailViewController
@synthesize customerDetails;
@synthesize fullName,companyNameOtl,phoneNoOtl,alternateNoOtl,emailAddress,othersOtl,otlCustomerImage,countryOtl,designation,contactScrollView;

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
    if (isiPhone5) {
        [contactScrollView setContentSize:CGSizeMake(contactScrollView.frame.size.width, contactScrollView.frame.size.height+60)];

    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [fullName setText:[NSString stringWithFormat:@"%@ %@",customerDetails.firstname,customerDetails.lastname]];
    
    companyNameOtl.text=customerDetails.company;
    companyNameOtl.text=customerDetails.company;
    if (customerDetails.countryCode==NULL) {
        
        phoneNoOtl.text=[NSString stringWithFormat:@"%@",customerDetails.phone];
    }
    else
    {
        phoneNoOtl.text=[NSString stringWithFormat:@"%@%@",customerDetails.countryCode,customerDetails.phone];
    }
    
    alternateNoOtl.text=customerDetails.alternatenumber;
    othersOtl.text=customerDetails.otherinfo;
    emailAddress.text = customerDetails.email;
    countryOtl.text=customerDetails.country;
    designation.text=customerDetails.designation;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:customerDetails.photoPath])
    {
        otlCustomerImage.image=[UIImage imageWithContentsOfFile:customerDetails.photoPath];
    }
    else
    {
        otlCustomerImage.image=[UIImage imageNamed:@"avtar.png"];
    }
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)EditBtnClick:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"EditCustomerSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"EditCustomerSegue"])
    {
        INDAddCustomerVC* editCustomerVC=(INDAddCustomerVC*)[segue destinationViewController];
        
        editCustomerVC.addNewOrSave=saveExisting;
        editCustomerVC.customerDetail=customerDetails;
        
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
