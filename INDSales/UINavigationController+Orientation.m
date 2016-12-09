//
//  UINavigationController+Orientation.m
//  INDSales
//
//  Created by Kush on 04/10/16.

#import "UINavigationController+Orientation.h"

@implementation UINavigationController (Orientation)

-(BOOL)shouldAutorotate
{
    // forcing the rotate IOS6 Only
    return [self.topViewController shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

@end
