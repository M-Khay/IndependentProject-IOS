//
//  INDTabbarViewController.m
//  INDSales
//
//  Created by Kush on 04/10/16.


#import "INDTabbarViewController.h"

@interface INDTabbarViewController ()

@end

@implementation INDTabbarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!isiPhone5)
    {
        UISplitViewController *splitViewController = (UISplitViewController *)[self.viewControllers objectAtIndex:3];
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        
        splitViewController.delegate = (id)navigationController.topViewController;
    }
}

-(BOOL)shouldAutorotate
{
    // forcing the rotate IOS6 Only
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    if (!self.selectedViewController)
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    NSInteger selectedIndex = self.selectedIndex;
    UINavigationController *navigationController = [self.viewControllers objectAtIndex:selectedIndex];
    UIViewController *topViewController = [navigationController isKindOfClass:[UINavigationController class]] ? navigationController.topViewController : navigationController;
    
    return [topViewController supportedInterfaceOrientations];
}

@end
