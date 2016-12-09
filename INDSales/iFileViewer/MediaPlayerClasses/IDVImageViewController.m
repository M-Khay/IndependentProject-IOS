//
//  IDVImageViewController.m
//  iDocViewer
//
//  Created by Krishna on 17/10/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import "IDVImageViewController.h"

@interface IDVImageViewController ()
{
    UIImage *image1 ;
    UIView *subView;
}

@end

@implementation IDVImageViewController
@synthesize pinchGesture,oneTapGesture,doubleTapGesture,imageVIew;
@synthesize selectedRowIndexNumbr,path;
@synthesize scrView;
@synthesize canvas;

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
    [self.navigationItem setTitle:[path lastPathComponent]];
     // CGRect rect = CGRectZero;
   //
  //  rect.size = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    scrView = [[UIScrollView alloc] init];
   // scrView.frame=rect;

    imageVIew = [[UIImageView alloc] init];
    
  
    scrView.delegate = self;
    scrView.minimumZoomScale = 0.5;
    scrView.maximumZoomScale = 2.5;
    [self.view addSubview:scrView];
    [scrView addSubview:imageVIew];
    
    NSError *attributesError = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&attributesError];
    
    int fileSize = (int)[fileAttributes fileSize];
  image1  = [UIImage imageWithContentsOfFile:path];
    

   // imageVIew.contentMode=UIControlContentVerticalAlignmentCenter;
    imageVIew.image=image1;
    imageVIew.userInteractionEnabled=YES;
    
    
    if(fileSize<(200*1024))
    {
        
         imageVIew.contentMode=UIViewContentModeCenter;
    }
    else
    {
        imageVIew.contentMode=UIViewContentModeScaleToFill;

    }
    
    oneTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    oneTapGesture.numberOfTapsRequired = 1;
    
    doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [oneTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    
    [self.view addGestureRecognizer:oneTapGesture];
    [imageVIew addGestureRecognizer:doubleTapGesture];
    
    [self changeOrientation];

   }


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;  {
    //incase we are zooming the center image view parent
    if (self.imageVIew.superview == scrollView){
        return self.imageVIew;
    }
    
    return nil;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
   subView = [scrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)recognizer {
    UIScrollView *scrollView = (UIScrollView*)self.imageVIew.superview;
    float scale = scrollView.zoomScale;
    scale += 1.0;
    if(scale > 2.0) scale = 1.0;
    [scrollView setZoomScale:scale animated:YES];
}

- (void)handleSingleTapGesture:(UITapGestureRecognizer *)recognizer
{
    static int count=2;
    
    count ++;
    if(count %2==1 ) {
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
        //self.navigationController.navigationBar.translucent=YES;
      // [UIView beginAnimations:nil context:NULL];
      //  [UIView setAnimationDuration:0.2];
       // [self.navigationController.navigationBar setAlpha:0.0];
       // [UIView commitAnimations];
    }
    else  {
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
        //
       // self.navigationController.navigationBar.translucent=NO;

           }
    
   // NSLog(@"count tap %d",count);
   // [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden];

   /* if (self.navigationController.navigationBar.hidden == NO) {
        // hide the Navigation Bar

        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
        // if Navigation Bar is already hidden
    else if (self.navigationController.navigationBar.hidden == YES) {
            // Show the Navigation Bar

    [self.navigationController setNavigationBarHidden:NO animated:NO];
    } */
       
    
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
      //  imageVIew.frame=CGRectMake(0, 0, 1024, 768);
       // scrollview.frame=CGRectMake(0, 0, 1024, 768);
    }
    else
    {
       // scrView.frame=self.view.frame;

      //  imageVIew.frame = scrView.bounds;

       // imageVIew.frame=CGRectMake(0, 0, 768, 1024);
       // scrollview.frame=CGRectMake(0, 0, 768, 1024);
        
   
    }
  //  CGRect rect = CGRectZero;
    
   // rect.size = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
   // scrView.frame=rect;

   // imageVIew.frame = scrView.bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)changeOrientation
{
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
       // imageVIew.frame=CGRectMake(0, 0, 768, 1024);
       //    scrollview.frame=CGRectMake(0, 0, 768, 1024);
       // canvas.frame=CGRectMake(50, 50, 600, 600);
        self.view.frame=CGRectMake(0, 0, 768, 1024);
    }
    else
    {
       //imageVIew.frame=CGRectMake(0, 0, 768, 1024);
        //  scrollview.frame=CGRectMake(0, 0, 1024, 768);
       // canvas.frame=CGRectMake(300, 200, 500, 300);
       // canvas.frame=CGRectMake(0,0,image1.size.width,image1.size.height);
        self.view.frame=CGRectMake(0, 0, 1024, 768);

    }
    CGRect rect = CGRectZero;
    
    rect.size = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    scrView.frame=rect;
    
    imageVIew.frame = scrView.bounds;
    
  }
-(void)OrientationChange
{
    [self changeOrientation];
    
  //  imageVIew.contentMode=UIViewContentModeScaleAspectFit;
   // imageVIew.contentMode=UIViewContentModeScaleAspectFill;
  //  scrView.contentMode=UIViewContentModeScaleAspectFit;
   // imageVIew.contentMode=UIViewContentModeScaleAspectFit;
  //  CGRect rect = CGRectZero;
    
  //  rect.size = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
  //  scrView.frame=rect;
    
   // imageVIew.frame = scrView.bounds;
    subView.center = self.view.center;
}
/*- (void)toggleNavBar:(UITapGestureRecognizer *)gesture {
    BOOL barsHidden = self.navigationController.navigationBar.hidden;
    [self.navigationController setNavigationBarHidden:!barsHidden animated:YES];
} */

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}


@end
