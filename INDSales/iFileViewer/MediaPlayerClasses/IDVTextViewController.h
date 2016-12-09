//
//  IDVTextViewController.h
//  iDocViewer
//
//  Created by Krishna on 08/11/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IDVTextViewController : UIViewController<UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UITextView *otl_TextView;
@property(strong,nonatomic) NSString *path;
@property(strong,nonatomic) UIPinchGestureRecognizer *textVIewPinchGesture;


@end
