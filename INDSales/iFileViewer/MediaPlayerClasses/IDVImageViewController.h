//
//  IDVImageViewController.h
//  iDocViewer
//
//  Created by Krishna on 17/10/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface IDVImageViewController : UIViewController<UIScrollViewDelegate,UIApplicationDelegate,UIGestureRecognizerDelegate>
{
    CGFloat _lastScale;
	CGFloat _lastRotation;
	CGFloat _firstX;
	CGFloat _firstY;
    
    UIImageView *photoImage;
  //  UIView *canvas;
    
    CAShapeLayer *_marque;

}

//@property (strong, nonatomic)  UIImageView *imageVIew;
@property (strong, nonatomic)  UIScrollView *scrView;
//@property (nonatomic, retain) IBOutlet UIView *canvas;

@property(strong,nonatomic) UIPinchGestureRecognizer *pinchGesture;
@property(strong,nonatomic) UITapGestureRecognizer *oneTapGesture;
@property(strong,nonatomic) UITapGestureRecognizer *doubleTapGesture;
@property(nonatomic) int selectedRowIndexNumbr;
@property(strong,nonatomic) NSString *path;

@property (strong, nonatomic) IBOutlet UIView *canvas;
@property (strong, nonatomic)  UIImageView *imageVIew;

@end
