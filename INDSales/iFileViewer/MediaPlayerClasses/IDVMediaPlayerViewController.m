//
//  IDVMediaPlayerViewController.m
//  iDocViewer
//
//  Created by Krishna on 19/10/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import "IDVMediaPlayerViewController.h"

@interface IDVMediaPlayerViewController ()
{
    MPMoviePlayerController *moviePlayer;
    UIImageView *image;
}

@end

@implementation IDVMediaPlayerViewController
@synthesize fileDirectoryPath,oneTapGesture;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

    [self.navigationItem setTitle:[fileDirectoryPath lastPathComponent]];
    image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"soundImage"]];
    [self.view addSubview:image];
    NSURL *videoUrl= [NSURL fileURLWithPath:fileDirectoryPath];
    
    if (videoUrl!=NULL)
    {
        moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoUrl];
        
        [self setPlayerSizeOnOrientaion];
    
   /* [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayerWillEnterFullscreenNotification:)
                                                     name:MPMoviePlayerWillEnterFullscreenNotification
                                                   object:moviePlayer];*/
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayerWillExitFullscreenNotification:)
                                                     name:MPMoviePlayerWillExitFullscreenNotification
                                                   object:moviePlayer]; 
    [self.view addSubview:moviePlayer.view];
        
    [moviePlayer setFullscreen:NO animated:YES];
    [moviePlayer play];
    //keep audio active after coming in forground
       
        BOOL test= [[NSUserDefaults standardUserDefaults] boolForKey:@"switch"];
        NSLog(@"test=%hhd",test);
        AVAudioSession *audioSession;
      //  UIBackgroundTaskIdentifier newTaskId;
        if(test)
        {
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
     //  newTaskId = UIBackgroundTaskInvalid;
      //  newTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
        
        }
        else
        {
            audioSession=nil;
        }
    }
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didTapDoneBtn:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
 }

- (void)didTapDoneBtn:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        [moviePlayer stop];
    }];
}

-(void)setPlayerSizeOnOrientaion
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if( [[[fileDirectoryPath pathExtension] lowercaseString] isEqualToString:@"mp3"] ||[[[fileDirectoryPath pathExtension] lowercaseString] isEqualToString:@"caf"]||[[[fileDirectoryPath pathExtension] lowercaseString] isEqualToString:@"wav"]||[[[fileDirectoryPath pathExtension] lowercaseString] isEqualToString:@"m4a"])
    {
        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
            {
                
                if ([[UIScreen mainScreen] bounds].size.height > 567.0f)
                {
                    image.frame = CGRectMake(30, 00, 260, 400);
                    [moviePlayer.view setFrame:CGRectMake(0, 460 ,320, 40)];
                }
                else
                {
                    image.frame = CGRectMake(30, 00, 260, 300);
                    [moviePlayer.view setFrame:CGRectMake(0, 380 ,320, 40)];
                }
            }
            else
            {
                if ([[UIScreen mainScreen] bounds].size.height > 567.0f)
                {
                    image.frame = CGRectMake(180, 00, 200, 220);
                    [moviePlayer.view setFrame:CGRectMake(0, 225 ,568, 40)];
                }
                else
                {
                    image.frame = CGRectMake(130, 00, 200, 200);
                    [moviePlayer.view setFrame:CGRectMake(0, 230 ,480, 40)];
                }
            }
        }
        else
        {
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
            {
                image.frame = CGRectMake(170, 150, 450, 500);
                [moviePlayer.view setFrame:CGRectMake(0, 860 ,780, 50)];
            }
            else
            {
                image.frame = CGRectMake(300, 90, 450, 500);
                [moviePlayer.view setFrame:CGRectMake(0, 640 ,1024, 50)];
            }
        }
    }
    else
    {
        [image removeFromSuperview];
        image=nil;
        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
            {
                if ([[UIScreen mainScreen] bounds].size.height > 567.0f)
                {
                    [moviePlayer.view setFrame:CGRectMake(0.0f, 00.0f,320.0f, 505.0f)];
                }
                else
                {
                    [moviePlayer.view setFrame:CGRectMake(0.0f,00.0f,320.0f, 420.0f)];
                }
            }
            else
            {
                if ([[UIScreen mainScreen] bounds].size.height > 567.0f)
                {
                    [moviePlayer.view setFrame:CGRectMake(0.0f,00.0f,568.0f, 275.0f)];
                }
                else
                {
                    [moviePlayer.view setFrame:CGRectMake(0.0f,00.0f,480.0f, 275.0f)];
                }
            }
        }
        else
        {
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
            {
                [moviePlayer.view setFrame:CGRectMake(0.0f, 0.0f, 768.0f, 965.0f)];
            }
            else
            {
                [moviePlayer.view setFrame:CGRectMake(0.0f,0.0f, 1024.0f, 705.0f)];
            }
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    [moviePlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    
    if ([moviePlayer respondsToSelector:@selector(setFullscreen:animated:)])
    {
      //  moviePlayer.fullscreen = NO;
    [moviePlayer.view removeFromSuperview];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
      [self setPlayerSizeOnOrientaion];
}

-(void)appWillResignActive:(NSNotification*)note
{
    BOOL test= [[NSUserDefaults standardUserDefaults] boolForKey:@"switch"];
    if(!test)
    {
        [moviePlayer pause];
    }
}

- (void)moviePlayerDidFinishNotification:(NSNotification*)notification {
    NSLog(@"willEnterFullscreen");
    
}

- (void)moviePlayerWillEnterFullscreenNotification:(NSNotification*)notification {
    NSLog(@"enteredFullscreen");
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                     //  self.allowRotation = YES;
                   });
}

- (void)moviePlayerWillExitFullscreenNotification:(NSNotification*)notification
{
    NSLog(@"willExitFullscreen");
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
        {
            if ([[UIScreen mainScreen] bounds].size.height > 567.0f)
            {
                [moviePlayer.view setFrame:CGRectMake(0.0f, 00.0f,320.0f, 505.0f)];
            }
            else
            {
                [moviePlayer.view setFrame:CGRectMake(0.0f,00.0f,320.0f, 420.0f)];
            }
        }
        else
        {
            if ([[UIScreen mainScreen] bounds].size.height > 567.0f)
            {
                [moviePlayer.view setFrame:CGRectMake(0.0f,00.0f,568.0f, 275.0f)];
            }
            else
            {
                [moviePlayer.view setFrame:CGRectMake(0.0f,00.0f,480.0f, 275.0f)];
            }
        }
    }
    else
    {
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
        {
            [moviePlayer.view setFrame:CGRectMake(0.0f,0.0f, 768.0f, 965.0f)];
        }
        else
        {
            [moviePlayer.view setFrame:CGRectMake(0.0f,0.0f, 1024.0f, 705.0f)];
        }
    }
}

@end
