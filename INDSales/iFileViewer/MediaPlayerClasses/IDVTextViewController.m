//
//  IDVTextViewController.m
//  iDocViewer
//
//  Created by Krishna on 08/11/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import "IDVTextViewController.h"

@interface IDVTextViewController ()
{
}

@end

@implementation IDVTextViewController
@synthesize otl_TextView;
@synthesize path;
@synthesize textVIewPinchGesture;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
        

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self.navigationItem setTitle:[path lastPathComponent]];
    NSString *textToDisplay=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    otl_TextView.text=textToDisplay;
    self.textVIewPinchGesture=[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchGesture:)];

    self.textVIewPinchGesture.delegate = self;

    [otl_TextView addGestureRecognizer:textVIewPinchGesture];
   
    [self changeOrientation];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGestRecognizer{
  
    
    UIFont *font = self.otl_TextView.font;
	CGFloat pointSize = font.pointSize;
	NSString *fontName = font.fontName;
    
	pointSize = ((pinchGestRecognizer.velocity > 0) ? 1 : -1) * 1 + pointSize;
	
	if (pointSize < 13) pointSize = 13;
	if (pointSize > 42) pointSize = 42;
	
	self.otl_TextView.font = [UIFont fontWithName:fontName size:pointSize];

}

-(void)OrientationChange
{
    [self changeOrientation];
}
-(void)changeOrientation
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        self.view.frame=CGRectMake(0, 0, 768, 1024);
        self.otl_TextView.frame=self.view.frame;
        
    }
    else
    {
        
        self.view.frame=CGRectMake(0, 0, 1024, 768);
        self.otl_TextView.frame=self.view.frame;
    }
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}



@end
