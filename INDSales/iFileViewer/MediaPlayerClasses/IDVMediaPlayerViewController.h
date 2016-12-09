//
//  IDVMediaPlayerViewController.h
//  iDocViewer
//
//  Created by Krishna on 19/10/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "DatasourceSingltonClass.h"

@interface IDVMediaPlayerViewController : UIViewController
@property(strong,nonatomic) NSString *fileDirectoryPath;
@property(strong,nonatomic) UITapGestureRecognizer *oneTapGesture;

@end
