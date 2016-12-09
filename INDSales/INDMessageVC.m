//
//  INDMessageVC.m
//  INDSales
//
//////  Created by Kush on 13/11/16.
//

#import "INDMessageVC.h"

@interface INDMessageVC ()

@end

@implementation INDMessageVC
@synthesize secondMsgLabel;
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
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        secondMsgLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 5, 200,40)];

    }
    else
    {
        secondMsgLabel=[[UILabel alloc]initWithFrame:CGRectMake(25, 5, 450,40)];
  
    }
    [self.view addSubview:secondMsgLabel];
    

	// Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setTextToLabel:(NSString*)text
{
   self.msgLabel.text = text;
    
    
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
