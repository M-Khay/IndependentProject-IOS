//
//  IDVViewController.m
//  iDocViewer
//
//////  Created by Kush on 13/11/16.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import "IDVViewController.h"
#import "AFURLSessionManager.h"
#define NUMBERS_ONLY @"1234567890"
#import "IDVPasswordChangeViewController.h"
#import "ZipArchive.h"
#import "INDDataModel.h"

#define CHARACTER_LIMIT 4
@interface IDVViewController ()<PasswordChangeDelegate>
{
    // UITableViewCell *selectedCell;
    BOOL internetConnection;
    NSString *imgString;
    NSString *pathForCurrentFile;
    NSString *directoryPathInDidSelect;
    
    UIButton* SubmitButton;
    UIButton* HistoryButton ;
    UIButton* SettingButton;
    UIButton *DoneButtonInPasswordSection;
    UIView *navigationBarView;
    UISegmentedControl *segmentedControl;
    UILabel *noFIleLabel1;
    UILabel *noFIleLabel2;
    NSString *deletePath;
    int unZippingInProgress;
    NSString *pathToUnzipingFile;
    NSMutableDictionary *plistDict;
    NSArray *_arrOfFetchedfile;
    NSArray *arrOfFetchedFavouritefiles;
    NSString *sortingOrderByDate;
    NSString *sortingOrderByName;
    NSString *sortingOrderBySize;
    NSDateFormatter *formatter;
    NSArray *thumbnailArray;
    NSString *currentURL;
    NSString *newTempDownloadFilePath;
    NSString *thumbnailFilesPath;
    BOOL creatThumbnailImage;
    MBProgressHUD  *HUD1;
    UIView *navigationBarCoverView;
    UIPopoverController *popover;
    UIView *navBarButtonsHolder;
    UIPopoverController  *videoLibraryPopover;
    INDDataModel *fileToDelete;
    BOOL isInLockMode;
    BOOL isEditing;
    NSMutableArray *selectedArr;
    UITableViewCell *cellToBeSelected;
    NSIndexPath *indexPathToBeSelected;
}
@property (strong,nonatomic)NSString* urlToload;
@property (strong,nonatomic)NSOperationQueue *operationQueue;
@property (strong,nonatomic)AFHTTPRequestOperation *failedOperation;
@property (strong,nonatomic)NSString *pathToStoreDownloadedFile;

@property (strong,nonatomic) NSString *downloadfilePath;

@property(strong,nonatomic) UIPopoverController *settingPopover;
@property(strong,nonatomic) UIPopoverController *soringPopover;

@property(strong,nonatomic) UIPopoverController *activityPopoverController;

@property (strong, nonatomic) IDVPasswordChangeViewController *passwordChangeVCObj;

@end

@implementation IDVViewController
@synthesize textURL,otlTableView,downloadfilePath,operation,otl_DownloadLabel;
@synthesize currentDirectoryPath;
@synthesize reachability;
@synthesize directoryPathForCell;
@synthesize historyPopoverController;
@synthesize otl_DownloadProgressview;
@synthesize otl_downloadProgressLabel;
@synthesize settingPopover;
@synthesize soringPopover;
@synthesize isNotCalledFirstTime;
@synthesize viewTag;
@synthesize MIMETYPE;
@synthesize docFileExtensions;
@synthesize indexPathInDidselect;
@synthesize fileToShare;
@synthesize deleteFileIndex;
@synthesize otl_sortButton,otl_EditButton;
@synthesize operationQueue;
@synthesize pathToStoreDownloadedFile;

#pragma  mark- methods


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    DatasourceSingltonClass *sharedObject=[DatasourceSingltonClass sharedInstance];
    if ([sharedObject performSelector:@selector(managedObjectContext)]) {
        context = [sharedObject managedObjectContext];
    }
    return context;
}

#pragma mark- View life cycle methods

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    creatThumbnailImage=false;
    SettingButton.hidden=NO;
    DoneButtonInPasswordSection.hidden=YES;
    otlTableView.hidden=YES;
   
    if(![DatasourceSingltonClass sharedInstance].iDVCCalledFirstTime==true)
    {
        otlTableView.hidden=YES;
        HUD1 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD1.delegate=self;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            HUD1.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
            self.edgesForExtendedLayout = UIRectEdgeBottom;
        }
        HUD1.mode = MBProgressHUDModeIndeterminate;
        HUD1.labelText = @"Loading";
        [HUD1 show:YES];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            [[DatasourceSingltonClass sharedInstance].arrOfFavFiles removeAllObjects];
            [[DatasourceSingltonClass sharedInstance].arrOfLockedFiles removeAllObjects];
            NSManagedObjectContext *context=[self managedObjectContext];
            NSFetchRequest *req1=[[NSFetchRequest alloc]init];
            [req1 setReturnsObjectsAsFaults:NO];
            NSEntityDescription *entity1=[NSEntityDescription entityForName:@"PasswordFiles" inManagedObjectContext:context];
            [req1 setEntity:entity1];
            _arrOfFetchedfile =[[NSArray alloc]init];
            _arrOfFetchedfile=[context executeFetchRequest:req1 error:nil];
            
            NSFetchRequest *req2=[[NSFetchRequest alloc]init];
            [req2 setReturnsObjectsAsFaults:NO];
            NSEntityDescription *entity2=[NSEntityDescription entityForName:@"FavouriteFiles" inManagedObjectContext:context];
            [req2 setEntity:entity2];
            
            arrOfFetchedFavouritefiles =[[NSArray alloc]init];
            arrOfFetchedFavouritefiles=[context executeFetchRequest:req2 error:nil];
            
            for (NSManagedObject *obj in arrOfFetchedFavouritefiles)
            {
                [[DatasourceSingltonClass sharedInstance].arrOfFavFiles addObject:[obj valueForKey:@"filepath"]];
            }
            for (NSManagedObject *obj in _arrOfFetchedfile)
            {
                [[DatasourceSingltonClass sharedInstance].arrOfLockedFiles addObject:[obj valueForKey:@"filepath"]];
            }
            
           /* NSError *error;
            if(![[NSFileManager defaultManager] fileExistsAtPath:thumbnailFilesPath])
            {
                [[NSFileManager defaultManager] createDirectoryAtPath:thumbnailFilesPath withIntermediateDirectories:YES attributes:nil error:&error];
            } */
            
            [self dataFetchMethod];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                [self displayView];
                [HUD1 hide:YES];
            });
        });
    }
    else
    {
        [DatasourceSingltonClass sharedInstance].iDVCCalledFirstTime=false;
    }
    
    [self.navigationController setNavigationBarHidden:NO];
    
    [DatasourceSingltonClass sharedInstance].fileLockTag=NO;
    
    [DatasourceSingltonClass sharedInstance].collectionViewEditFlag=0;
    
    if (_urlToload!=nil) {
        [self.tabBarController.navigationController setNavigationBarHidden:YES];
        
    }
}

-(void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
   /* if (_urlToload!=nil)
    {
        
        self.textURL.text =_urlToload;
        [self onClickSubmit:nil];
        
        _urlToload=nil;
    } */
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    navigationBarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
}
-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.otlTableView setEditing:NO];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.navigationController.navigationBar setTintColor:[UIColor blueColor]];
    if(!isNotCalledFirstTime)
    {
    [[NSUserDefaults standardUserDefaults] setInteger:[DatasourceSingltonClass sharedInstance].viewStyle forKey:kFileViewerViewStyle];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   // self.otlTableView.allowsMultipleSelectionDuringEditing = YES;
   // self.otl_CancelMultipleSelection.hidden=YES;
    
    _otl_CancelMultipleSelection.hidden=YES;
    isEditing=NO;
    isInLockMode=NO;
    otlTableView.dataSource=self;
    otlTableView.delegate=self;
    creatThumbnailImage=YES;
    sortingOrderByDate=@"ascending";
    sortingOrderByName=@"ascending";
    sortingOrderBySize=@"ascending";
    [DatasourceSingltonClass sharedInstance].iDVCCalledFirstTime=true;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"switch"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        [otlTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    unZippingInProgress=0;
    operationQueue =[[NSOperationQueue alloc] init];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    MIMETYPE=[[NSMutableArray alloc]initWithObjects:@"xls",@"xml",@"doc",@"xlsx",@"docx",@"ppt",@"pptx",@"json",@"pdf",@"png",@"jpeg",@"jpg",@"mov",@"mp4",@"mp3",@"m4v",@"wav",@"3gp",@"mpv",@"m4p",@"m4a",@"caf",@"zip",@"rar",@"ipa",@"plist",@"htm",@"html", nil];
    //  docFileExtensions=[[NSMutableArray alloc]initWithObjects:@"xls",@"xml",@"doc",@"xlsx",@"docx",@"ppt",@"pptx",@"json",@"pdf", nil];
    //  imageFileExtensions=[[NSMutableArray alloc]initWithObjects:@"png",@"jpeg",@"jpg", nil];
    // mediaFileExtensions=[[NSMutableArray alloc]initWithObjects:@"mov",@"mp4",@"mp3",@"m4v",@"wav",@"3gp",@"mpv",@"m4p",@"caf", nil];
    
    otlTableView.backgroundColor=[UIColor clearColor];
//    noFIleLabel1=[[UILabel alloc] init];
//    noFIleLabel2=[[UILabel alloc] init];
//    
//    noFIleLabel1.text=@"No files available in the directory";
  //  noFIleLabel2.text=@" Please use the above text box to download the files";
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    textURL = [[UITextField alloc] init];
    navigationBarView=[[UIView alloc] init ];
    textURL.userInteractionEnabled=YES;
    textURL.tag=5;
    SubmitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    HistoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    SettingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    SettingButton.layer.cornerRadius=5.0;
    DoneButtonInPasswordSection=[UIButton buttonWithType:UIButtonTypeCustom];
    [DoneButtonInPasswordSection setTitleColor:[UIColor blackColor] forState:UIControlStateNormal] ;
   
    DoneButtonInPasswordSection.hidden=YES;
    
    DoneButtonInPasswordSection.layer.borderColor = [UIColor whiteColor].CGColor;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        [self.navigationController.navigationBar setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIFont fontWithName:@"Helvetica" size:12],
          NSFontAttributeName, nil]];
        DoneButtonInPasswordSection.layer.borderWidth = .5f;
         [DoneButtonInPasswordSection.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size: 10.0]];
    }
    else
    {
        DoneButtonInPasswordSection.layer.borderWidth = 2.0f;
          [DoneButtonInPasswordSection.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size: 14.0]];
    }
    
    otl_DownloadLabel.hidden=YES;
    otl_downloadProgressLabel.hidden=YES;
    otl_DownloadProgressview.hidden=YES;
    
    /* internet reachability checking..*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if(remoteHostStatus == NotReachable)
        internetConnection=NO;
    else
        internetConnection=YES;
    
    //  NSURL *downloadURL=[NSURL URLWithString:@"https://lms.indegene.com/appstore/install/Azvilla/azvilla.ipa"];
    
    if (self.isNotCalledFirstTime==YES)
    {
        self.navigationItem.title=[self.currentDirectoryPath lastPathComponent];
        
        [self addingComoponentsToNavigationBar];
        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            [textURL removeFromSuperview];
            [SubmitButton removeFromSuperview];
            [HistoryButton removeFromSuperview];
            CGRect viewFrame = CGRectMake(0.0, 0.0, 105, 40.0);
            navigationBarView.frame=viewFrame;
            segmentedControl.frame=CGRectMake(0.0, 0.0, 75,25.0);
            SettingButton.frame=CGRectMake(80, 1.0,26,22.0);
            DoneButtonInPasswordSection.frame=CGRectMake(80, 1.0,26,22.0);
            navBarButtonsHolder.frame=CGRectMake(navigationBarView.frame.origin.x, navigationBarView.frame.origin.y+8, (segmentedControl.frame.size.width+SettingButton.frame.size.width+05), navBarButtonsHolder.frame.size.height);
        }
        else
        {
            
        }
        
        textURL.hidden=YES;
        SubmitButton.hidden=YES;
        HistoryButton.hidden=YES;
        
        [self changeOrientation];
    }
    else
    {
       
        NSInteger fileViewSyleINT = [[NSUserDefaults standardUserDefaults] integerForKey:kFileViewerViewStyle];
        switch (fileViewSyleINT) {
            case 0:
                [DatasourceSingltonClass sharedInstance].viewStyle=eFileViewerTypeList;
                break;
            case 1:
                [DatasourceSingltonClass sharedInstance].viewStyle=eFileViewerTypeCarousel;
                break;
            case 2:
                [DatasourceSingltonClass sharedInstance].viewStyle=eFileViewerTypeCollection;
                break;
            default:
                break;
    }

        [self.navigationItem setTitle:nil];
        self.otlTableView.hidden=NO;
        currentDirectoryPath=[self rootFolderPath];
        [self addingComoponentsToNavigationBar];
        [self changeOrientation];
        otl_EditButton.hidden=YES;
        
        //deleting all thumbnail files
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        
        NSString *thumbnailFolderPath=[documentsPath stringByAppendingPathComponent:@"iDocDir/thumbnails"];
        NSString *favThumbnailFolderPath=[documentsPath stringByAppendingPathComponent:@"iDocDir/favouriteFileThumbnails"];
        
        [[NSFileManager defaultManager] removeItemAtPath:thumbnailFolderPath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:favThumbnailFolderPath error:nil];
       // [DatasourceSingltonClass sharedInstance].viewStyle= eFileViewerTypeList;

    }
    
    NSDictionary *normalAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIFont fontWithName:@"Helvetica Neue" size:15.0],NSFontAttributeName,
                                      nil];
    [[UIBarButtonItem appearance] setTitleTextAttributes:normalAttributes
                                                forState:UIControlStateNormal];
    
    
    HUD1 = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD1.delegate=self;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        HUD1.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
    }
    HUD1.mode = MBProgressHUDModeIndeterminate;
    HUD1.labelText = @"Loading";
    [HUD1 show:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [self newThread];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
           // [self backToMainThread];
            
            [self displayView];
            
            [HUD1 hide:YES];
            
        });
        
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        [DoneButtonInPasswordSection setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        SettingButton.backgroundColor=[UIColor lightGrayColor];
        segmentedControl.tintColor = [UIColor lightGrayColor];
    }
    else
    {
        segmentedControl.tintColor = [UIColor clearColor];
        segmentedControl.backgroundColor = [UIColor clearColor];
        textURL.textColor=[UIColor whiteColor];
    }
}

-(void)displayView
{
    [[DatasourceSingltonClass sharedInstance].collectionViewObj removeFromSuperview];
    [[DatasourceSingltonClass sharedInstance].coverFlowViewObj removeFromSuperview];
    [DatasourceSingltonClass sharedInstance].collectionViewObj=nil;
    [DatasourceSingltonClass sharedInstance].coverFlowViewObj =nil;
    
    [DatasourceSingltonClass sharedInstance].viewControllerTag=1;
    
    if([DatasourceSingltonClass sharedInstance].viewControllerTag==1)
    {
        otl_EditButton.hidden = YES;
        NSLog(@"current style=%u",[DatasourceSingltonClass sharedInstance].viewStyle);
        
        switch ([DatasourceSingltonClass sharedInstance].viewStyle)
        {
            case eFileViewerTypeList:
            {
                segmentedControl.selectedSegmentIndex = 0;
                otlTableView.hidden=NO;
                [[DatasourceSingltonClass sharedInstance].collectionViewObj removeFromSuperview];
                [[DatasourceSingltonClass sharedInstance].coverFlowViewObj removeFromSuperview];
                [DatasourceSingltonClass sharedInstance].collectionViewObj=nil;
                [DatasourceSingltonClass sharedInstance].coverFlowViewObj=nil;
                _otl_MultipleDelButton.hidden=NO;

                [self changeOrientation];
                [otlTableView reloadData];
                break;
            }
                
            case eFileViewerTypeCarousel:
            {
                otl_EditButton.hidden=YES;
                
                segmentedControl.selectedSegmentIndex = 1;
                otlTableView.hidden=YES;
                
                [[DatasourceSingltonClass sharedInstance].collectionViewObj removeFromSuperview];
                [DatasourceSingltonClass sharedInstance].collectionViewObj=nil;
                [DatasourceSingltonClass sharedInstance].coverFlowViewObj=[[IDVCoverFlowVIew alloc]init];
                [DatasourceSingltonClass sharedInstance].coverFlowViewObj.idvCoverFlowViewDelegateObj=self;
                
                [DatasourceSingltonClass sharedInstance].CommonDirectoryPath=self.currentDirectoryPath;
                
                [[DatasourceSingltonClass sharedInstance].coverFlowViewObj initialization];
                [self.view addSubview:[DatasourceSingltonClass sharedInstance].coverFlowViewObj];
                _otl_MultipleDelButton.hidden=YES;

                [otlTableView reloadData];
                
                break;
            }
                
            case eFileViewerTypeCollection:
            {
                otl_EditButton.hidden=NO;
                segmentedControl.selectedSegmentIndex = 2;
                otlTableView.hidden=YES;
                [[DatasourceSingltonClass sharedInstance].coverFlowViewObj removeFromSuperview];
                [DatasourceSingltonClass sharedInstance].coverFlowViewObj=nil;
                [DatasourceSingltonClass sharedInstance].CommonDirectoryPath=self.currentDirectoryPath;
                
                [DatasourceSingltonClass sharedInstance].collectionViewObj=[[IDVCollectionVIew alloc]init];
                [DatasourceSingltonClass sharedInstance].collectionViewObj.idvCollectionViewDelegate=self;
                [[DatasourceSingltonClass sharedInstance].collectionViewObj initialization];
                
                [self.view addSubview:[DatasourceSingltonClass sharedInstance].collectionViewObj];
                _otl_MultipleDelButton.hidden=YES;

                [otlTableView reloadData];
                
                break;
            }
        }
    }
    
    [HUD1 hide:YES];
}


-(void)backToMainThread
{
    
    if([DatasourceSingltonClass sharedInstance].sharedDataSource.count>0)
    {
        [noFIleLabel1 removeFromSuperview];
        [noFIleLabel2 removeFromSuperview];
    }
    else
    {
        [self.view addSubview:noFIleLabel1];
        if(!isNotCalledFirstTime)
        [self.view addSubview:noFIleLabel2];
    }
    
}

-(void)newThread
{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req1=[[NSFetchRequest alloc]init];
    [req1 setReturnsObjectsAsFaults:NO];
    NSEntityDescription *entity1=[NSEntityDescription entityForName:@"PasswordFiles" inManagedObjectContext:context];
    [req1 setEntity:entity1];
    _arrOfFetchedfile =[[NSArray alloc]init];
    _arrOfFetchedfile=[context executeFetchRequest:req1 error:nil];
    
    NSFetchRequest *req2=[[NSFetchRequest alloc]init];
    [req2 setReturnsObjectsAsFaults:NO];
    NSEntityDescription *entity2=[NSEntityDescription entityForName:@"FavouriteFiles" inManagedObjectContext:context];
    [req2 setEntity:entity2];
    
    arrOfFetchedFavouritefiles =[[NSArray alloc]init];
    arrOfFetchedFavouritefiles=[context executeFetchRequest:req2 error:nil];
    
    for (NSManagedObject *obj in arrOfFetchedFavouritefiles)
    {
        [[DatasourceSingltonClass sharedInstance].arrOfFavFiles addObject:[obj valueForKey:@"filepath"]];
    }
    for (NSManagedObject *obj in _arrOfFetchedfile)
    {
        [[DatasourceSingltonClass sharedInstance].arrOfLockedFiles addObject:[obj valueForKey:@"filepath"]];
    }
    [self dataFetchMethod];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
   NSString *thumbnailFolderPath=[documentsPath stringByAppendingPathComponent:@"iDocDir/thumbnails"];
    thumbnailFilesPath=[thumbnailFolderPath stringByAppendingPathComponent:[self.currentDirectoryPath lastPathComponent]];
    BOOL isDIR;
    NSError *error;
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:thumbnailFolderPath isDirectory:&isDIR])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:thumbnailFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    for(INDDataModel *file in [DatasourceSingltonClass sharedInstance].sharedDataSource)
    {
        if([[[file.fileName pathExtension] lowercaseString] isEqualToString:@"png"]||[[[file.fileName pathExtension] lowercaseString] isEqualToString:@"jpeg"]||[[[file.fileName pathExtension] lowercaseString] isEqualToString:@"jpg"])
        {
            [self saveThumbnailImage:[UIImage imageWithContentsOfFile:file.fileFullPath] path:file.fileFullPath file:file];
            file.fileThumbnailPath = [thumbnailFilesPath stringByAppendingPathComponent:[file.fileFullPath lastPathComponent]];
        }
    }
}

#pragma mark- fetchData

-(void) dataFetchMethod
{
    BOOL isDirectory;

    DatasourceSingltonClass* sharedSingleton = [DatasourceSingltonClass sharedInstance];
    sharedSingleton.CommonDirectoryPath=self.currentDirectoryPath;
    
    NSString*  filePath1 =sharedSingleton.CommonDirectoryPath;
    
  //  [[DatasourceSingltonClass sharedInstance].sharedDataSource removeAllObjects];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[[NSURL alloc] initFileURLWithPath:filePath1 isDirectory:YES]
                                                   includingPropertiesForKeys:[NSArray arrayWithObject:NSURLCreationDateKey]
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                        error:nil];
   
    
    if(files.count>0)
    {
        [noFIleLabel1 removeFromSuperview];
        [noFIleLabel2 removeFromSuperview];
        noFIleLabel1=nil;
        noFIleLabel2=nil;
        
        NSMutableArray *sharedDataSource = [NSMutableArray arrayWithCapacity:1];
        for(NSURL *fileURL in files)
        {
            NSString *file=[[NSString alloc] initWithString:[fileURL path]];

            INDDataModel *datamodelObj=[[INDDataModel alloc]init];
            NSError *error;
            NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:file error: &error];
            float fileSize = [fileDictionary fileSize];
            
            datamodelObj.fileName=[file lastPathComponent];
            datamodelObj.fileCreationDate=[fileDictionary fileCreationDate];
            datamodelObj.fileFullPath=file;
            datamodelObj.fileThumbnail=nil;
            datamodelObj.isFavourite=[[DatasourceSingltonClass sharedInstance].arrOfFavFiles containsObject:datamodelObj.fileFullPath];
            datamodelObj.isLocked=[[DatasourceSingltonClass sharedInstance].arrOfLockedFiles containsObject:datamodelObj.fileFullPath];
            datamodelObj.isFolder=([[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDirectory] && isDirectory);
            
            if([[[file pathExtension] lowercaseString] isEqualToString:@"png"]||[[[file pathExtension] lowercaseString] isEqualToString:@"jpeg"]||[[[file pathExtension] lowercaseString] isEqualToString:@"jpg"])
            {
             // [self saveThumbnailImage:[UIImage imageWithContentsOfFile:file] path:file file:datamodelObj];
              datamodelObj.fileThumbnailPath=[thumbnailFilesPath stringByAppendingPathComponent:[file lastPathComponent]];
            }
            else
            {
                datamodelObj.fileThumbnailPath=nil;
            }
            
            if (datamodelObj.isFolder)
            {
                NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath: file] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
                
                int count = (int)[directoryContents count];
                datamodelObj.fileSize=count;
            }
            else
            {
                datamodelObj.fileSize=fileSize;
            }
            
            [sharedDataSource addObject:datamodelObj];
        }
       NSArray *sortedArray = [sharedDataSource sortedArrayUsingComparator:^NSComparisonResult(INDDataModel *file1, INDDataModel *file2){
            
            return [file2.fileCreationDate compare:file1.fileCreationDate];
        }];
        
        [DatasourceSingltonClass sharedInstance].sharedDataSource = [NSMutableArray arrayWithArray:sortedArray];
       }
    else
    {
        noFIleLabel1=[[UILabel alloc] init];
        
        
        noFIleLabel1.text=@"No files available in the directory";
        [self.view addSubview:noFIleLabel1];
        
        if(!isNotCalledFirstTime)
        {
        noFIleLabel2=[[UILabel alloc] init];
        noFIleLabel2.text=@" Please use the above text box to download the files";
        [self.view addSubview:noFIleLabel2];
        }
        [[DatasourceSingltonClass sharedInstance].sharedDataSource removeAllObjects];
    }
}

-(void)addingComoponentsToNavigationBar
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        //iPhone
        
        CGFloat navigationBarViewWidth = self.navigationItem.title ? 215.0 : (self.navigationController.navigationBar.bounds.size.width -30.0);
        CGRect viewFrame = CGRectMake(0.0, 0.0, navigationBarViewWidth, 40.0);
        navigationBarView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        navigationBarView.frame = viewFrame;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navigationBarView];
        
        /* URL text field */
        textURL.borderStyle = UITextBorderStyleRoundedRect;
        textURL.backgroundColor = [UIColor clearColor];
        textURL.font = [UIFont systemFontOfSize:10];
        textURL.placeholder = @"Enter Download Link Here..";
        textURL.autocorrectionType = UITextAutocorrectionTypeNo;
        textURL.keyboardType = UIKeyboardTypeDefault;
        textURL.returnKeyType = UIReturnKeyDone;
        textURL.clearButtonMode = UITextFieldViewModeWhileEditing;
        textURL.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textURL.delegate = self;
        textURL.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
        [navigationBarView addSubview:textURL];
        
        [SubmitButton addTarget:self action:@selector(onClickSubmit:) forControlEvents:UIControlEventTouchUpInside];
        [SubmitButton setImage:[UIImage imageNamed:@"submit.png"] forState:UIControlStateNormal];
        
        
        [navigationBarView addSubview:SubmitButton];
        
        [HistoryButton addTarget:self action:@selector(onClickShowHistory) forControlEvents:UIControlEventTouchUpInside];
        [HistoryButton setImage:[UIImage imageNamed:@"history.png"] forState:UIControlStateNormal];
        [navigationBarView addSubview:HistoryButton];
        
        [SettingButton addTarget:self action:@selector(onClickShowSettingOptions) forControlEvents:UIControlEventTouchUpInside];
        [SettingButton setImage:[UIImage imageNamed:@"Menu.png"] forState:UIControlStateNormal];
        [navigationBarView addSubview:SettingButton];
        
        [DoneButtonInPasswordSection addTarget:self action:@selector(onClickDoneLockingFiles) forControlEvents:UIControlEventTouchUpInside];
        [DoneButtonInPasswordSection setTitle:@"Done" forState:UIControlStateNormal];
        [navigationBarView addSubview:DoneButtonInPasswordSection];
        
        NSArray *segmentImageArray = [NSArray arrayWithObjects:
                                      [UIImage imageNamed:@"list.png"],
                                      [UIImage imageNamed:@"carousel1.png"],
                                      [UIImage imageNamed:@"grid.png"],
                                      nil];
        
        segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentImageArray];
        segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        [segmentedControl  setContentMode:UIViewContentModeScaleToFill];
        [segmentedControl  setWidth:25.0 forSegmentAtIndex:0];
        [segmentedControl  setWidth:25.0 forSegmentAtIndex:1];
        [segmentedControl  setWidth:25.0 forSegmentAtIndex:2];
        
        CGFloat btnViewWidth = 00.0;
        CGFloat btnWidth = 25.0;
        CGFloat btnOriginY = 0.0;
        
        navBarButtonsHolder = [[UIView alloc] initWithFrame:CGRectZero];
        navBarButtonsHolder.backgroundColor = [UIColor clearColor];
        
        SubmitButton.frame = CGRectMake(btnViewWidth, btnOriginY, btnWidth, btnWidth);
        btnViewWidth += btnWidth + 3.0;
        
        HistoryButton.frame = CGRectMake(btnViewWidth, btnOriginY, btnWidth, btnWidth);
        btnViewWidth += btnWidth + 3.0;
        
        segmentedControl.frame = CGRectMake(btnViewWidth+2.0, btnOriginY, btnWidth * 3.0, btnWidth);
        btnViewWidth += segmentedControl.frame.size.width + 5.0;
        
        SettingButton.frame = CGRectMake(btnViewWidth+2.0, btnOriginY+1, btnWidth +1.0, btnWidth-3);
        
        DoneButtonInPasswordSection.frame = CGRectMake(btnViewWidth+1.0, btnOriginY+1, btnWidth +1.0, btnWidth-3);
        btnViewWidth += SettingButton.frame.size.width;
        
        navBarButtonsHolder.frame = CGRectMake(navigationBarView.bounds.size.width - btnViewWidth-2, 8.0, btnViewWidth+2, btnWidth);
        [navigationBarView addSubview:navBarButtonsHolder];
        navBarButtonsHolder.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        
        textURL.frame = CGRectMake(7.0, 8.0, navigationBarView.bounds.size.width - (btnViewWidth+10.0), btnWidth);
        
        [navBarButtonsHolder addSubview:SubmitButton];
        [navBarButtonsHolder addSubview:HistoryButton];
        [navBarButtonsHolder addSubview:segmentedControl];
        [navBarButtonsHolder addSubview:DoneButtonInPasswordSection];
        [navBarButtonsHolder addSubview:SettingButton];
        
        segmentedControl.selectedSegmentIndex = 0;
        [segmentedControl addTarget:self
                             action:@selector(segmentControlAction:)
                   forControlEvents:UIControlEventValueChanged];
    }
    else
    {
        //[ipad]
        
        CGFloat navigationBarViewWidth = self.navigationItem.title ? 200.0 : (self.navigationController.navigationBar.bounds.size.width - 50.0);
        CGRect viewFrame = CGRectMake(0.0, 0.0, navigationBarViewWidth, 40.0);
        //CGRect viewFrame = CGRectMake(50.0, 0.0, self.navigationController.navigationBar.bounds.size.width - 50.0, 40.0);
        navigationBarView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        navigationBarView.frame = viewFrame;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navigationBarView];
        
        /* URL text field */
        textURL.borderStyle = UITextBorderStyleRoundedRect;
        textURL.backgroundColor = [UIColor clearColor];
        textURL.font = [UIFont systemFontOfSize:15];
        textURL.placeholder = @"Enter Download Link Here";
        textURL.autocorrectionType = UITextAutocorrectionTypeNo;
        textURL.keyboardType = UIKeyboardTypeDefault;
        textURL.returnKeyType = UIReturnKeyDone;
        textURL.clearButtonMode = UITextFieldViewModeWhileEditing;
        textURL.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textURL.delegate = self;
        textURL.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
        [navigationBarView addSubview:textURL];
        
        [SubmitButton addTarget:self action:@selector(onClickSubmit:) forControlEvents:UIControlEventTouchUpInside];
        [SubmitButton setImage:[UIImage imageNamed:@"submit.png"] forState:UIControlStateNormal];
        
        
        [navigationBarView addSubview:SubmitButton];
        
        [HistoryButton addTarget:self action:@selector(onClickShowHistory) forControlEvents:UIControlEventTouchUpInside];
        [HistoryButton setImage:[UIImage imageNamed:@"history.png"] forState:UIControlStateNormal];
        [navigationBarView addSubview:HistoryButton];
        
        [SettingButton addTarget:self action:@selector(onClickShowSettingOptions) forControlEvents:UIControlEventTouchUpInside];
        [SettingButton setImage:[UIImage imageNamed:@"Menu.png"] forState:UIControlStateNormal];
        [navigationBarView addSubview:SettingButton];
        
        [DoneButtonInPasswordSection addTarget:self action:@selector(onClickDoneLockingFiles) forControlEvents:UIControlEventTouchUpInside];
        [DoneButtonInPasswordSection setTitle:@"Done" forState:UIControlStateNormal];
        [DoneButtonInPasswordSection setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [navigationBarView addSubview:DoneButtonInPasswordSection];
        
        NSArray *segmentImageArray = [NSArray arrayWithObjects:
                                      [UIImage imageNamed:@"list.png"],
                                      [UIImage imageNamed:@"carousel1.png"],
                                      [UIImage imageNamed:@"grid.png"],
                                      nil];
        
        segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentImageArray];
        segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        [segmentedControl  setContentMode:UIViewContentModeScaleToFill];
        [segmentedControl  setWidth:30.0 forSegmentAtIndex:0];
        [segmentedControl  setWidth:30.0 forSegmentAtIndex:1];
        [segmentedControl  setWidth:30.0 forSegmentAtIndex:2];
        segmentedControl.tintColor = [UIColor lightGrayColor];
        
        CGFloat btnViewWidth = 0.0;
        CGFloat btnWidth = 30.0;
        CGFloat btnOriginY = 0.0;
        
        navBarButtonsHolder = [[UIView alloc] initWithFrame:CGRectZero];
        navBarButtonsHolder.backgroundColor = [UIColor clearColor];
        
        SubmitButton.frame = CGRectMake(btnViewWidth, btnOriginY, btnWidth, btnWidth);
        btnViewWidth += btnWidth + 5.0;
        
        HistoryButton.frame = CGRectMake(btnViewWidth, btnOriginY, btnWidth, btnWidth);
        btnViewWidth += btnWidth + 30.0;
        
        segmentedControl.frame = CGRectMake(btnViewWidth, btnOriginY, btnWidth * 3.0, btnWidth);
        btnViewWidth += segmentedControl.frame.size.width + 15.0;
        
        SettingButton.frame = CGRectMake(btnViewWidth, btnOriginY, btnWidth + 10.0, btnWidth);
        
        DoneButtonInPasswordSection.frame = CGRectMake(btnViewWidth, btnOriginY, btnWidth + 10.0, btnWidth);
        btnViewWidth += SettingButton.frame.size.width + 5.0;
        
        navBarButtonsHolder.frame = CGRectMake(navigationBarView.bounds.size.width - btnViewWidth, 5.0, btnViewWidth, btnWidth);
        [navigationBarView addSubview:navBarButtonsHolder];
        navBarButtonsHolder.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        
        textURL.frame = CGRectMake(0.0, 5.0, navigationBarView.bounds.size.width - (btnViewWidth + 10.0), btnWidth);
        
        [navBarButtonsHolder addSubview:SubmitButton];
        [navBarButtonsHolder addSubview:HistoryButton];
        [navBarButtonsHolder addSubview:segmentedControl];
        [navBarButtonsHolder addSubview:DoneButtonInPasswordSection];
        [navBarButtonsHolder addSubview:SettingButton];
        
        segmentedControl.selectedSegmentIndex = 0;
        [segmentedControl addTarget:self
                             action:@selector(segmentControlAction:)
                   forControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark- Orientation methods

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    _passwordChangeVCObj.otl_PasswordView.center=_passwordChangeVCObj.view.center;
    _passwordChangeVCObj.otl_SetPasswordView.center=_passwordChangeVCObj.view.center;
    _passwordChangeVCObj.otl_SecurityQuestionView.center=_passwordChangeVCObj.view.center;
    
    if (_passwordChangeVCObj.view.superview)
    {
        [_passwordChangeVCObj willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

-(void) setComponentsOnPortrait
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        noFIleLabel1.frame= CGRectMake(60, 200, 215, 30);
        noFIleLabel2.frame=CGRectMake(10, 230, 300, 30);
        [noFIleLabel1 setFont:[UIFont systemFontOfSize:13]];
        [noFIleLabel2 setFont:[UIFont systemFontOfSize:12]];
        
        otl_EditButton.frame=CGRectMake(55,0.0, 35.0, 30.0);
        otl_sortButton.frame=CGRectMake(10,0.0, 35.0, 30.0);
        
        otl_DownloadProgressview.frame=CGRectMake(192, 5.0, 125, 2);
        otl_DownloadLabel.frame=CGRectMake(93, -5, 96, 21);
        
        _otl_CancelMultipleSelection.frame=CGRectMake(225, 0, 45, 30);
        _otl_MultipleDelButton.frame=CGRectMake(275, 0, 40, 30);
    }
    else
    {
        noFIleLabel1.frame= CGRectMake(285, 500, 300, 30);
        noFIleLabel2.frame=CGRectMake(195, 535, 500, 30);
        otl_EditButton.frame=CGRectMake(70,0.0, 46.0, 30.0);
        otl_sortButton.frame=CGRectMake(10,0.0, 46.0, 30.0);
        
        otl_DownloadProgressview.frame=CGRectMake(268, 15, 283, 2);
        otl_downloadProgressLabel.frame=CGRectMake(125, 5, 124, 21);
        otl_DownloadLabel.frame=CGRectMake(574, 5, 240, 21);
        
        _otl_CancelMultipleSelection.frame=CGRectMake(624, 2, 50, 30);
        _otl_MultipleDelButton.frame=CGRectMake(706, 2, 50, 30);

    }
}

-(void)setComponentsOnLandscape
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        noFIleLabel1.frame= CGRectMake(190, 130, 215, 30);
        noFIleLabel2.frame= CGRectMake(135, 170, 300, 30);
        
        [noFIleLabel1 setFont:[UIFont systemFontOfSize:13]];
        [noFIleLabel2 setFont:[UIFont systemFontOfSize:12]];
        
        otl_EditButton.frame=CGRectMake(55,0.0, 35.0, 30.0);
        otl_sortButton.frame=CGRectMake(10,0.0, 35.0, 30.0);
        
        otl_DownloadLabel.frame=CGRectMake(140, 2,120, 21);
        otl_DownloadProgressview.frame=CGRectMake(258, 11, 200, 2);
    
        if ([[UIScreen mainScreen] bounds].size.height > 567.0f)
        {
            _otl_CancelMultipleSelection.frame=CGRectMake(475, 0, 45, 30);
            _otl_MultipleDelButton.frame=CGRectMake(523, 0, 40, 30);
        }
        else
        {
            //iphone 3.5 inch screen
        }

    }
    else
    {
        noFIleLabel1.frame= CGRectMake(385, 400, 300, 30);
        noFIleLabel2.frame= CGRectMake(295, 435, 500, 30);
        
        otl_EditButton.frame=CGRectMake(70,0.0, 46.0, 30.0);
        otl_sortButton.frame=CGRectMake(10,0.0, 46.0, 30.0);
        
        otl_DownloadProgressview.frame=CGRectMake(268, 15, 283, 2);
        otl_downloadProgressLabel.frame=CGRectMake(125, 5, 124, 21);
        otl_DownloadLabel.frame=CGRectMake(574, 5, 240, 21);
        _otl_MultipleDelButton.frame=CGRectMake(930, 2, 50, 30);
        _otl_CancelMultipleSelection.frame=CGRectMake(850, 2, 50, 30);
    }
}

#pragma mark- Download Methods

-(void) downloadMethodWithFilePath:(NSString*)path username:(NSString*)username password:(NSString*)password
{
    NSError *error;
    BOOL isDIR;
    
    pathToStoreDownloadedFile=path;
    operationQueue.maxConcurrentOperationCount=1;
    NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString*documentsPath=[docPath stringByAppendingPathComponent:@"iDocDir"];
    NSString* fileToDownload;
    
    __block UIProgressView* blockDownloadProgressView=otl_DownloadProgressview;
   // __block UIButton *blockbuttonDownloadProgress=_otl_buttonDownloadProgress;
    __block  NSString *blockpathToStoreDownloadedFile=pathToStoreDownloadedFile;
    __block NSMutableArray *blockFilePaths=[DatasourceSingltonClass sharedInstance].sharedDataSource;
    __block UILabel *blockdownloadProgressLabel=otl_downloadProgressLabel;
    __block UILabel *blockdownloadLabel=otl_DownloadLabel;
    __block UITableView *blockTableView=otlTableView;
    __weak typeof(self) weakSelf = self;
    [otl_DownloadProgressview setProgress:0.0 animated:NO];
    
    int pathExtentionFoundInMIMETYPE=0;
    for(NSString *pathExtention in MIMETYPE)
    {
        if([[[pathToStoreDownloadedFile pathExtension] lowercaseString] isEqualToString:pathExtention])
            pathExtentionFoundInMIMETYPE=1;
    }
    
    if(pathExtentionFoundInMIMETYPE)
    {
        
        fileToDownload = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",@"doc",[pathToStoreDownloadedFile lastPathComponent] ]];
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileToDownload];
        
        if(fileExists)
        {
            
            UIAlertView *fileExistAlert=[[UIAlertView alloc]initWithTitle:@"File already exists" message:@"Do you want to replace it?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Replace", nil];
            fileExistAlert.tag=1;
            [fileExistAlert show];
        }
        
        else
        {
            NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            newTempDownloadFilePath=[documentsPath stringByAppendingPathComponent:@"iDocDir/tempDownloadFiles"];
            if(![[NSFileManager defaultManager] fileExistsAtPath:newTempDownloadFilePath isDirectory:&isDIR])
            {
                [[NSFileManager defaultManager] createDirectoryAtPath:newTempDownloadFilePath withIntermediateDirectories:YES attributes:nil error:&error];
                
            }
            
            operation.outputStream=[NSOutputStream outputStreamToFileAtPath:[newTempDownloadFilePath stringByAppendingPathComponent:[pathToStoreDownloadedFile lastPathComponent]] append:NO];
            
            [operationQueue addOperation:operation];
            
            [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:nil];
            
            otl_DownloadLabel.text=[NSString stringWithFormat:@"Downloading 1 of %lu",(unsigned long)[operationQueue.operations count]];
            otl_DownloadProgressview.hidden=NO;
           // _otl_buttonDownloadProgress.hidden=NO;
            otl_downloadProgressLabel.hidden=NO;
            otl_DownloadLabel.hidden=NO;
        }
        
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
         {
             float progress=(float)totalBytesRead/(float)totalBytesExpectedToRead;
             
             [blockDownloadProgressView setProgress:progress animated:YES];
             
         }];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             
             BOOL isDIR;
             __strong typeof(self) strongSelf = weakSelf;
             NSError *error;
             NSString *DocumentFilePath=[strongSelf rootFolderPath];
             if(![[NSFileManager defaultManager] fileExistsAtPath:DocumentFilePath isDirectory:&isDIR])
             {
                 [[NSFileManager defaultManager] createDirectoryAtPath:DocumentFilePath withIntermediateDirectories:YES attributes:nil error:&error];
             }
             
             if([[NSFileManager defaultManager] fileExistsAtPath:blockpathToStoreDownloadedFile ])
             {
                 [[NSFileManager defaultManager] removeItemAtPath:blockpathToStoreDownloadedFile error:&error];
             }
             
             [[NSFileManager defaultManager] moveItemAtPath:[[documentsPath stringByAppendingPathComponent:@"tempDownloadFiles"] stringByAppendingPathComponent:[blockpathToStoreDownloadedFile lastPathComponent]] toPath:
              blockpathToStoreDownloadedFile error:nil];
             
             if([[[blockpathToStoreDownloadedFile pathExtension] lowercaseString] isEqualToString:@"png"]||[[[blockpathToStoreDownloadedFile pathExtension] lowercaseString] isEqualToString:@"jpeg"]||[[[blockpathToStoreDownloadedFile pathExtension] lowercaseString] isEqualToString:@"jpg"])
             {
                
                 [strongSelf saveThumbnailImage:[UIImage imageWithContentsOfFile:blockpathToStoreDownloadedFile] path:blockpathToStoreDownloadedFile file:nil];
                }
             
             if([[NSFileManager defaultManager] fileExistsAtPath:[[documentsPath stringByAppendingPathComponent:@"tempDownloadFiles"] stringByAppendingPathComponent:[blockpathToStoreDownloadedFile lastPathComponent]]])
             {
                 [[NSFileManager defaultManager] removeItemAtPath:[[documentsPath stringByAppendingPathComponent:@"tempDownloadFiles"] stringByAppendingPathComponent:[blockpathToStoreDownloadedFile lastPathComponent]] error:&error];
             }
             
             if(![blockFilePaths containsObject:blockpathToStoreDownloadedFile])
             {
                 [blockFilePaths addObject:blockpathToStoreDownloadedFile];
             }
             
                 switch ([DatasourceSingltonClass sharedInstance].viewStyle)
                 {
                     case eFileViewerTypeList:
                     {
                         [strongSelf.otlTableView reloadData];
                         [strongSelf reloadDataSource];
                         break;
                     }
                         
                     case eFileViewerTypeCarousel:
                     {
                         [strongSelf dataFetchMethod];
                         [strongSelf updateCoverFlowDataSource];
                         [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.tableView reloadData];
                         [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.carousel reloadData];
                         break;
                     }
                         
                     case eFileViewerTypeCollection:
                     {
                          [strongSelf dataFetchMethod];
                          [strongSelf updateCollectionDataSource];
                         [[DatasourceSingltonClass sharedInstance].collectionViewObj.collectionView reloadData];
                         break;
                     }
                 }
             
             if([weakSelf.operationQueue.operations count]==0)
             {
                 blockDownloadProgressView.hidden=YES;
              //   blockbuttonDownloadProgress.hidden=YES;
                 blockdownloadProgressLabel.hidden=YES;
                 blockdownloadLabel.hidden=YES;
                 blockDownloadProgressView.progress=0;
             }
             blockdownloadLabel.text=[NSString stringWithFormat:@"Downloading 1 of %lu",(unsigned long)[weakSelf.operationQueue.operations count]];
             
         }
    
        failure:^(AFHTTPRequestOperation *operation1, NSError *error)
         {
             __strong typeof(self) strongSelf = weakSelf;
             
             if([weakSelf.operationQueue.operations count]==0)
             {
                 blockDownloadProgressView.hidden=YES;
               //  blockbuttonDownloadProgress.hidden=YES;
                 blockdownloadProgressLabel.hidden=YES;
                 blockdownloadLabel.hidden=YES;
                 blockDownloadProgressView.progress=0;
             }
             
             if(operation1.response.statusCode==404)
             {
                 
                 UIAlertView *myAlert = [[UIAlertView alloc]
                                         initWithTitle:@"iDocViewer"
                                         message:[NSString stringWithFormat: @" File '%@' not found on the server",[blockpathToStoreDownloadedFile lastPathComponent]]
                                         delegate:strongSelf
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
                 [myAlert show];
                 
             }
             else if(operation1.response.statusCode==403)
             {
                 NSLog(@"authentication fail");
             }
             else if(operation1.response.statusCode==401)
             {
                 weakSelf.failedOperation = operation1;
                 // [operation1.operationDetails setObject:[NSString stringWithFormat:@"%d",i] forKey:@"operation_id"];
                 
                 NSString *failedFile=[weakSelf.pathToStoreDownloadedFile lastPathComponent];
                 NSString *title=[NSString stringWithFormat:@"%@ \"%@\"",@"Authentication required for file",failedFile];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:@"Enter User name and Password" delegate:strongSelf cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
                 [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
                 // alert.tag=i;
                 alert.tag=401;
                 [alert show];
             }
             else
             {
                 UIAlertView *myAlert = [[UIAlertView alloc]
                                         initWithTitle:@"iDocViewer"
                                         message:[NSString stringWithFormat: @"Currently unable to download \"%@\" file",[blockpathToStoreDownloadedFile lastPathComponent]]
                                         delegate:strongSelf
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
                 [myAlert show];
                 
             }
             
             NSString* _fileToDownload = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",@"doc",[blockpathToStoreDownloadedFile lastPathComponent]]];
             
             BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:_fileToDownload];
             if(fileExists)
                 [[NSFileManager defaultManager] removeItemAtPath:fileToDownload error:&error];
             
             [blockFilePaths removeObject:[blockpathToStoreDownloadedFile stringByDeletingPathExtension]];
             [blockTableView reloadData];
             
         }];
    }
    else
    {
        [DatasourceSingltonClass sharedInstance].webViewFlag= @"unsupportedFiles";
        /*  NSString *weburl;
         NSString *regEx = [NSString stringWithFormat:@".*%@.*", @"http"];
         NSRange range = [currentURL rangeOfString:regEx options:NSRegularExpressionSearch];
         if (range.location != NSNotFound)
         {
         weburl=currentURL;
         }
         else
         {
         
         weburl = [NSString stringWithFormat:@"%@%@",@"https://",currentURL];
         }
         // [DatasourceSingltonClass sharedInstance].webViewFlag= @"unsupportedFiles";
         // weburl=testURL;
         IDVWebViewController *idvWebViewControllerObj=[[IDVWebViewController alloc]init];
         idvWebViewControllerObj.path=weburl;
         
         [self.navigationController pushViewController:idvWebViewControllerObj animated:YES]; */
        UIAlertView *myAlert = [[UIAlertView alloc]
                                initWithTitle:@"iDocViewer"
                                message:[NSString stringWithFormat: @"Unable to download \"%@\" file",[blockpathToStoreDownloadedFile lastPathComponent]]
                                delegate:self
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil];
        [myAlert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
#pragma mark-UITableView methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [DatasourceSingltonClass sharedInstance].sharedDataSource.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"cell";
    CustomCell *cell = (CustomCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        NSArray* topLevelObjects;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomCell_iPhone" owner:self options:nil];
        }
        else
        {
            topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
        }
        for (id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (CustomCell *)currentObject;
                break;
            }
        }
    }
    
    if ([DatasourceSingltonClass sharedInstance].sharedDataSource.count > indexPath.row)
    {
        // pathForCurrentFile=[[DatasourceSingltonClass sharedInstance].filepaths objectAtIndex:indexPath.row];
        INDDataModel *file = [[DatasourceSingltonClass sharedInstance].sharedDataSource objectAtIndex:indexPath.row];
        pathForCurrentFile = file.fileFullPath;
        
        cell.backgroundColor=[UIColor clearColor];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        cell.path=pathForCurrentFile;//directoryPathForCell;
        cell.file=file;
        cell.otl_BtnFavourite.tag=indexPath.row;
        cell.otl_BtnShare.tag=indexPath.row;
        cell.otl_LockButton.tag=indexPath.row;
        cell.customCellDelegateObj=self;
        cell.otl_FileName.text=file.fileName;
        cell.otl_FileSize.text=[self countFileSizeForCell:cell file:file];
        
        cell.otl_CreationDate.text= [formatter stringFromDate:file.fileCreationDate];
        if([[[pathForCurrentFile pathExtension] lowercaseString] isEqualToString:@"png"]||[[[pathForCurrentFile pathExtension] lowercaseString] isEqualToString:@"jpeg"]||[[[pathForCurrentFile pathExtension] lowercaseString] isEqualToString:@"jpg"])
        {
            if (file.fileThumbnail)
            {
                cell.otl_ImgView.image = file.fileThumbnail;
            }
            else
            {
               // [self setThumbnailForcell:cell withIndexPath:indexPath file:pathForCurrentFile];
                cell.otl_ImgView.image=[UIImage imageWithContentsOfFile:file.fileThumbnailPath];
            }
        }
        else
        {
            // cell.otl_ImgView.image=[UIImage imageNamed:imgString];
            [self setIconImageOnCell:cell path:pathForCurrentFile];
        }
        if (file.isFolder)
        {
            imgString=@"folder";
            cell.otl_ImgView.image=[UIImage imageNamed:imgString];
        }
        
        cell.otl_LockButton.tintColor=[UIColor darkGrayColor];
        
        if(file.isLocked)
        {
            cell.otl_LockButton.selected=YES;
            cell.otl_ImageViewLock.image=[UIImage imageNamed:@"passwordLock.png"];
        }
        else
        {
            cell.otl_LockButton.selected=NO;
        }
        
        if(file.isFavourite)
        {
            cell.otl_BtnFavourite.selected=YES;
        }
        else
        {
            cell.otl_BtnFavourite.selected=NO;
        }
        
        if ([DatasourceSingltonClass sharedInstance].fileLockTag==NO)
        {
            cell.otl_LockButton.hidden=YES;
          //  cell.otl_BtnFavourite.hidden=NO;
           // cell.otl_BtnShare.hidden=NO;
            
            if(isEditing)
            {
                cell.otl_BtnFavourite.hidden=YES;
                cell.otl_BtnShare.hidden=YES;
            }
            else
            {
                cell.otl_BtnFavourite.hidden=NO;
                cell.otl_BtnShare.hidden=NO;
            }
        }
        else
        {
            cell.otl_LockButton.hidden=NO;
            cell.otl_BtnFavourite.hidden=YES;
            cell.otl_BtnShare.hidden=YES;
        }
        
       
    }
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     if(isEditing)
     {
         INDDataModel *file=[[DatasourceSingltonClass sharedInstance].sharedDataSource objectAtIndex:indexPath.row];
         UITableViewCell *c = [tableView cellForRowAtIndexPath:indexPath];
                 if (c.accessoryType == UITableViewCellAccessoryCheckmark) {
                     [c setAccessoryType:UITableViewCellAccessoryNone];
                     [selectedArr removeObject:indexPath];
                 }
                 else
                 {
                     if(file.isLocked)
                     {
                         indexPathToBeSelected=indexPath;
                         cellToBeSelected=c;
                         UIAlertView *fileProtectedAlert = [[UIAlertView alloc] initWithTitle:@"Passcode Protected File" message:@"Enter Passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
                         [fileProtectedAlert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
                         [[fileProtectedAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
                         [fileProtectedAlert textFieldAtIndex:0].keyboardAppearance = UIKeyboardAppearanceLight;
                         [fileProtectedAlert setTag:211];
                         [[fileProtectedAlert textFieldAtIndex:0] setTag:4];
                         [fileProtectedAlert show];
                     }
                     else{
                   [c setAccessoryType:UITableViewCellAccessoryCheckmark];
                     [selectedArr addObject:indexPath];
                     }
                 }
         NSLog(@"selectedArr=%@",selectedArr);
     }
    
    else
    {
        if(!isInLockMode)
        [self commonDidSelectAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        return 50.0;
    }
    else
    {
        return 85.0;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([DatasourceSingltonClass sharedInstance].fileLockTag==YES)
    {
        return NO;
    }
    else
        return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // deleteIndex=(int)indexPath.row;
        self.deleteFileIndex=(int)indexPath.row;
        
        UIAlertView *confirmDelete=[[UIAlertView alloc] initWithTitle:@"iDocViewer" message:@"Do you want to delete the file?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
        confirmDelete.tag=2;
        [confirmDelete show];
    }
}


-(NSString*)countFileSizeForCell:(CustomCell*)cell file:(INDDataModel*)file
{
    float fileSize=file.fileSize;
    NSString *finalfilesize=nil;
    if(file.isFolder)
    {
        finalfilesize= [NSString stringWithFormat:@"%i %@",(int)fileSize,@"files"];
    }
    else
    {
        NSString *kbMb;
        float newValue;
        
        NSString *fileSizeString;
        if(fileSize<(1024*1024))
        {
            kbMb=@"KB";
            newValue=(float)fileSize/1024;
        }
        else
        {
            kbMb=@"MB";
            newValue=(float)fileSize/(1024*1024);
        }
        float rounded_down = floorf(newValue * 100) / 100;
        fileSizeString=[NSString stringWithFormat:@"%.02f",rounded_down];
       finalfilesize =[NSString stringWithFormat:@"%@ %@",fileSizeString,kbMb];
    }
    
    return finalfilesize;
}

- (void)setThumbnailForcell:(CustomCell*)cell withIndexPath:(NSIndexPath *)indexPath file:(NSString *)filePath
{
   
     UIImage *image = nil;
     for(NSURL *imgFile in thumbnailArray)
     {
     if([[imgFile lastPathComponent] isEqualToString:[pathForCurrentFile lastPathComponent]])
     {
     NSData *pngData = [NSData dataWithContentsOfURL:imgFile];
     image = [UIImage imageWithData:pngData];
     
     //  dispatch_sync(dispatch_get_main_queue(), ^{
     
     // CustomCell *cell = (CustomCell *)[otlTableView cellForRowAtIndexPath:indexPath];
     // if (cell)
     // {
     cell.otl_ImgView.image=image;
     //}
     //  });
     break;
     }
     }
     //  });
}


-(void)setIconImageOnCell:(CustomCell*)cell path:(NSString*)iconPath
{
    BOOL isDirectory;
    if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"xls"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"xlsx"])
    {
        imgString=@"excel";
        cell.otl_ImgView.image=[UIImage imageNamed:imgString];
    }
    else if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"doc"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"docx"])
    {
        imgString=@"doc";
        cell.otl_ImgView.image=[UIImage imageNamed:imgString];
    }
    else if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"ppt"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"pptx"])
    {
        imgString=@"ppt";
        cell.otl_ImgView.image=[UIImage imageNamed:imgString];
    }
    else if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"mov"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"mp4"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"m4v"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"mpv"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"3gp"])
    {
        imgString=@"Grid_Video";
        cell.otl_ImgView.image=[UIImage imageNamed:imgString];
    }
    else if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"mp3"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"m4p"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"wav"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"caf"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"m4a"])
    {
        imgString=@"audio";
        cell.otl_ImgView.image=[UIImage imageNamed:imgString];
    }
    else if([[[iconPath pathExtension] lowercaseString]  isEqualToString:@"pdf"])
    {
        imgString=@"pdf";
        cell.otl_ImgView.image=[UIImage imageNamed:imgString];
    }
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"json"])
    {
        imgString=@"json";
        cell.otl_ImgView.image=[UIImage imageNamed:imgString];
    }
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"xml"])
    {
        imgString=@"xml";
        cell.otl_ImgView.image=[UIImage imageNamed:imgString];
    }
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"zip"])
    {
        imgString=@"zip";
        cell.otl_ImgView.image=[UIImage imageNamed:imgString];
    }
    
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"html"]||
             [[[iconPath pathExtension] lowercaseString] isEqualToString:@"htm"]||
             [[[iconPath pathExtension] lowercaseString] isEqualToString:@"htmls"]||
             [[[iconPath pathExtension] lowercaseString] isEqualToString:@"htt"]||
             [[[iconPath pathExtension] lowercaseString] isEqualToString:@"htx"])
    {
        imgString=@"html";
        cell.otl_ImgView.image=[UIImage imageNamed:imgString];
    }
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"txt"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"text"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"rtf"])
    {
        imgString=@"text";
        cell.otl_ImgView.image=[UIImage imageNamed:imgString];
    }
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"plist"])
    {
        imgString=@"plist";
        cell.otl_ImgView.image=[UIImage imageNamed:imgString];
    }
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"ipa"])
    {
        imgString=@"ipa";
        cell.otl_ImgView.image=[UIImage imageNamed:imgString];
    }
    else  if ([[NSFileManager defaultManager] fileExistsAtPath:pathForCurrentFile isDirectory:&isDirectory] && isDirectory)
    {
        imgString=@"folder";
        cell.otl_ImgView.image=[UIImage imageNamed:imgString];
        
    }
    else
        imgString=@"other";
    cell.otl_ImgView.image=[UIImage imageNamed:imgString];
    
}
// Audio Files: MP3, M4P, M4A / AAC, WAV, and CAF
// Video Files: M4V, MPV, MP4, MOV, 3GP

#pragma mark- Generating thumbnails

//- (void)saveThumbnailImage:(UIImage *)img path:(INDDataModel*)file
-(void)saveThumbnailImage:(UIImage *)img path:path file:(INDDataModel*)file
{
    NSError *error;
    UIImage *originalImage = img;
    NSData *imageData = UIImageJPEGRepresentation(originalImage, 0.5);
    CGSize destinationSize = (imageData.length > 4*1024*1024) ? CGSizeMake(50.0, 50.0) : CGSizeMake(100.0, 100.0);
    UIGraphicsBeginImageContext(destinationSize);
    [originalImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSData *pngData = UIImageJPEGRepresentation(newImage, 1.0);
   // NSString *pathToThumbnails=[thumbnailFilesPath stringByAppendingPathComponent:[self.currentDirectoryPath lastPathComponent]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:thumbnailFilesPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:thumbnailFilesPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSString *thumbnailPath = [thumbnailFilesPath stringByAppendingPathComponent:[path lastPathComponent]]; //Add the file name
   
    [pngData writeToFile:thumbnailPath atomically:YES]; //Write the file
   // file.fileThumbnailPath=thumbnailPath;
}


#pragma mark- Navbar Button action

-(IBAction)onClickSubmit:(id)sender
{
    
    if([textURL isFirstResponder]){
        [textURL resignFirstResponder];
    }
    
    currentURL=textURL.text;
    if(textURL.text.length==0)
    {
        MBProgressHUD *updatehud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        updatehud.delegate=self;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            updatehud.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
        }
        updatehud.mode = MBProgressHUDModeCustomView;
        updatehud.labelText = @"Empty URL";
        [updatehud hide:YES afterDelay:2];
    }
    else
    {
        NSString *regexp=@"(http(s)?://)?([\\w-]+\\.)+[\\w-]+(/[\\w- ;,./?%&=]*)?";
        // NSString *regexp= @"";
        //   NSString *regexp= @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
        //   NSString *regexp1= @"(http|https|ftp)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
        
        NSPredicate *urlPredic = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexp];
        BOOL isValidURL = [urlPredic evaluateWithObject:currentURL];
        
        //  BOOL canOpenGivenURL = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:textURL.text]];
        
        if (isValidURL)
        {
            NSManagedObjectContext *historyContext=[self managedObjectContext];
            NSFetchRequest *req=[[NSFetchRequest alloc]init];
            NSEntityDescription *e=[NSEntityDescription entityForName:@"HistoryFiles" inManagedObjectContext:historyContext];
            [req setEntity:e];
            NSArray *arrOfFetchedfile=[historyContext executeFetchRequest:req error:nil];
            //   NSLog(@"before...arrOfFetchedfile.count=%i",_arrOfFetchedfile.count);
            
            BOOL historyFound=NO;
            for (HistoryFiles* temp in arrOfFetchedfile) {
                if([temp.historyData isEqualToString:currentURL])
                {
                    historyFound=YES;
                    break;
                }
            }
            
            if(!historyFound)
            {
                HistoryFiles *historyFilesObj=[NSEntityDescription insertNewObjectForEntityForName:@"HistoryFiles" inManagedObjectContext:historyContext];
                historyFilesObj.historyData=textURL.text;
                NSError *error;
                if (![historyContext save:&error])
                {
                    NSLog(@"error");
                }
            }
            
            if(internetConnection)
            {
                NSLog(@"internet connection available");
                // operation.operationDetails =[[NSMutableDictionary alloc]init];
                NSURL *downloadURL=[NSURL URLWithString:currentURL];
                //@"https://lms.indegene.com/appstore/install/Azvilla/azvilla.ipa"];
                
                NSURLRequest *request=[NSURLRequest requestWithURL:downloadURL];
                operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                
                NSArray *directoryPaths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *_downloadfilePath=[[directoryPaths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",@"iDocDir/doc",[downloadURL lastPathComponent]]];
                
                //  NSURL *pathurl=[NSURL URLWithString:_downloadfilePath];
                //  NSURL *url = [pathurl URLByResolvingSymlinksInPath]; //This will remove private path component from path in iOS Device.
                //  NSString *path = [[NSString alloc] initWithString:[url path]];
                
//                [operation.operationDetails setObject:_downloadfilePath forKey:@"LOCAL_PATH"];
//                NSLog(@"weakSelf.failedOperation.operationDetails=%@",operation.operationDetails );
                [self downloadMethodWithFilePath:_downloadfilePath username:nil password:nil];
            }
            
            else
            {
                MBProgressHUD *updatehud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                updatehud.delegate=self;
                if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
                {
                    HUD1.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
                    HUD1.detailsLabelFont=[UIFont fontWithName:@"Helvetica" size:10];
                }
                updatehud.mode = MBProgressHUDModeCustomView;
                updatehud.labelText = @"No Internet Connection";
                updatehud.detailsLabelText=@"Please check your Network Settings";
                [updatehud hide:YES afterDelay:2];
                
                NSLog(@"internet connection not available");
            }
        }
        else
        {
            NSLog(@"invalid URL=%@",currentURL);
            textURL.text=nil;
            MBProgressHUD *updatehud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            updatehud.delegate=self;
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                updatehud.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
            }
            updatehud.mode = MBProgressHUDModeCustomView;
            updatehud.labelText = @"Invalid URL";
            [updatehud hide:YES afterDelay:2];
            
            [textURL becomeFirstResponder];
            
            /*   NSString *regexp=@"(http(s)?://)?([\\w-]+\\.)+[\\w-]+(/[\\w- ;,./?%&=]*)?";
             // NSString *regexp= @"(smb|http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
             NSPredicate *urlPredic = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexp];
             BOOL isValidURL = [urlPredic evaluateWithObject:currentURL];
             if(isValidURL)
             {
             [DatasourceSingltonClass sharedInstance].webViewFlag= @"unsupportedFiles";
             NSString *weburl;
             NSString *regEx = [NSString stringWithFormat:@".*%@.*", @"http"];
             NSRange range = [testURL rangeOfString:regEx options:NSRegularExpressionSearch];
             if (range.location != NSNotFound)
             {
             weburl=testURL;
             }
             else
             {
             weburl = [NSString stringWithFormat:@"%@%@",@"https://",testURL];
             }
             
             IDVWebViewController *idvWebViewControllerObj=[[IDVWebViewController alloc]init];
             idvWebViewControllerObj.path=weburl;
             
             [self.navigationController pushViewController:idvWebViewControllerObj animated:YES];
             }
             else
             {
             NSLog(@"invalid URL=%@",currentURL);
             textURL.text=nil;
             MBProgressHUD *updatehud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
             updatehud.delegate=self;
             
             updatehud.mode = MBProgressHUDModeCustomView;
             updatehud.labelText = @"Invalid URL";
             [updatehud hide:YES afterDelay:2];
             
             [textURL becomeFirstResponder];
             }*/
        }
    }
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder]; //dismiss the keyboard
    //do whatever else you need with the text
    if(textField.tag==5)
        [self onClickSubmit:nil];
    
    return YES;
}
-(void)onClickShowHistory
{
    NSManagedObjectContext *historyContex=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc]init];
    NSEntityDescription *entityDescription=[NSEntityDescription entityForName:@"HistoryFiles" inManagedObjectContext:historyContex];
    [req setEntity:entityDescription];
    
    NSError *error;
    
    NSArray *arr=[historyContex executeFetchRequest:req error:&error];
    IDVHistoryDataViewController *idvHistoryVCObj;
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if ([[UIScreen mainScreen] bounds].size.height > 567.0f)
        {
            
            
        }
        else
        {
            //iphone 3.5 inch screen
        }
        
        idvHistoryVCObj=[[IDVHistoryDataViewController alloc]initWithNibName:@"IDVHistoryDataViewController_iPhone" bundle:nil];
        idvHistoryVCObj.idvHistoryDelegateObj=self;
        
        if(arr.count>0)
        {
            [self presentViewController:idvHistoryVCObj animated:YES completion:nil];
        }
        else
        {
            MBProgressHUD *updatehud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            updatehud.delegate=self;
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                updatehud.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
            }
            updatehud.mode = MBProgressHUDModeCustomView;
            updatehud.labelText = @"No History Available";
            [updatehud hide:YES afterDelay:2];
        }
        
    }
    else{
        
        idvHistoryVCObj=[[IDVHistoryDataViewController alloc]initWithNibName:@"IDVHistoryDataViewController" bundle:nil];
        idvHistoryVCObj.idvHistoryDelegateObj=self;
        self.historyPopoverController= [[UIPopoverController alloc]initWithContentViewController:idvHistoryVCObj];
        
        historyPopoverController.popoverContentSize = CGSizeMake(320, 380);
        
        if(arr.count>0)
        {
            [self.historyPopoverController presentPopoverFromRect:HistoryButton.bounds inView:HistoryButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
        else
        {
            MBProgressHUD *updatehud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            updatehud.delegate=self;
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                updatehud.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
            }
            updatehud.mode = MBProgressHUDModeCustomView;
            updatehud.labelText = @"No History Available";
            [updatehud hide:YES afterDelay:2];
        }
        
    }
    
}

-(void)onClickShowSettingOptions
{
    if(isEditing)
    [self onClickCancelMultipleSelection:nil];
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        NSString *actionSheetTitle = @"Menu"; //Action Sheet Title
        // NSString *destructiveTitle = @"Favourites"; //Action Sheet Button Titles
        NSString *other1 = @"Favourites";
        // NSString *other2 = @"Help";
        // NSString *other3 = @"Support";
        NSString *other4 = @"Security";
        NSString *other5 = @"Import Media";
        NSString *cancelTitle = @"Cancel";
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:actionSheetTitle
                                      delegate:self
                                      cancelButtonTitle:cancelTitle
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:other1,other4,other5, nil];
        actionSheet.tag=1;
        [actionSheet showInView:self.view];
    }
    else
    {
        INSettingViewController *settingObj=[[INSettingViewController alloc]initWithNibName:@"INSettingViewController" bundle:nil];
        settingObj.settingDelegateObj=self;
        self.
        settingPopover=[[UIPopoverController alloc] initWithContentViewController:settingObj];
        settingPopover.popoverContentSize = CGSizeMake(230, 205);
        
        [settingPopover presentPopoverFromRect:SettingButton.bounds inView:SettingButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

-(void)onClickDoneLockingFiles
{
    isInLockMode=NO;
    [DatasourceSingltonClass sharedInstance].fileLockTag=NO;
    DoneButtonInPasswordSection.hidden=YES;
    SettingButton.hidden=NO;
    [otlTableView reloadData];
}

#pragma mark- root folder path

-(NSString*)rootFolderPath
{
    NSString*rootFolder = @"iDocDir/doc";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filepath = [path stringByAppendingPathComponent:rootFolder];
    return filepath;
}

#pragma mark-
#pragma mark-CustomCell Delegate method

-(void)shareFileWithObject:(INDDataModel*)file
{
    fileToShare= file.fileFullPath;
    
    NSError *attributesError = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:file.fileFullPath error:&attributesError];
    int fileSize = (int)[fileAttributes fileSize];
    if(fileSize>(10*1024*1024))
    {
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.delegate=self;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:10];
        }
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"Unable to share the file as its size exceeds 10 MB";
        [HUD hide:YES afterDelay:2];
    }
    else
    {
        int shareFileFlag=0;
        
        for (NSManagedObject *obj in _arrOfFetchedfile)
        {
            
            if([[obj valueForKey:@"filepath"] isEqual:file.fileFullPath])
            {
                shareFileFlag=1;
                break;
            }
        }
        
        if(shareFileFlag==1)
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Passcode Protected File" message:@"Enter Passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
            [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
            [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
            [alert textFieldAtIndex:0].keyboardAppearance = UIKeyboardAppearanceLight;
            [alert setTag:27];
            [[alert textFieldAtIndex:0] setTag:2];
            [alert show];
            
        }
        else
        {
            [self shareFileOnPath:file.fileFullPath];
            
        }
        
    }
}

-(void)shareFileOnPath:(NSString *)filePath
{
    NSURL *fileUrl;
    
    BOOL isDIR;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDIR]&isDIR)
    {
        NSString *docPath=[[self rootFolderPath] stringByDeletingLastPathComponent];
        NSString *pathToStoreZipFiles=[docPath stringByAppendingPathComponent:@"zipFiles"];
        
        [[DatasourceSingltonClass sharedInstance] createFolderAtPath:pathToStoreZipFiles];
        
        NSString* zipfile = [pathToStoreZipFiles stringByAppendingPathComponent:[[filePath lastPathComponent] stringByAppendingPathExtension:@"zip"]];
        
        ZipArchive* zip = [[ZipArchive alloc] init];
         [zip CreateZipFile2:zipfile];
        [zip addFileToZip:filePath newname:filePath];//zip

        fileUrl= [NSURL fileURLWithPath:[pathToStoreZipFiles stringByAppendingPathComponent:[[filePath lastPathComponent] stringByAppendingPathExtension:@"zip"]]];
    }
    else
    {
        fileUrl = [NSURL fileURLWithPath:filePath];
    }
    
    NSData *data;
    [data writeToURL:fileUrl atomically:YES];
    
    UIActivityViewController *activityViewObj = [[UIActivityViewController alloc]initWithActivityItems:[NSArray arrayWithObjects:fileUrl, nil] applicationActivities:nil];
    
    [activityViewObj setExcludedActivityTypes:
     @[
       UIActivityTypeSaveToCameraRoll,
       UIActivityTypePostToWeibo,
       UIActivityTypeAssignToContact,
       ]];
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        [self presentViewController:activityViewObj animated:YES completion:nil];
    }
    else
    {
        _activityPopoverController= [[UIPopoverController alloc] initWithContentViewController:activityViewObj];
        
        [_activityPopoverController presentPopoverFromRect:self.view.bounds
                                                    inView:self.view
                                  permittedArrowDirections:0
                                                  animated:YES];
    }
    
    
}

-(void)addToFavouriteWithObject:(INDDataModel*)filePath
{
    [self saveFavouriteFiles:filePath];
}

-(void) removeFromFavouriteListWithObject:(INDDataModel*)file
{
    NSManagedObjectContext *context=[self managedObjectContext];
    
    [self deleteFavouriteFile:file.fileFullPath];
    
    NSFetchRequest *req=[[NSFetchRequest alloc]init];
    NSEntityDescription *e=[NSEntityDescription entityForName:@"FavouriteFiles" inManagedObjectContext:context];
    [req setEntity:e];
    arrOfFetchedFavouritefiles=[context executeFetchRequest:req error:nil];
    
}

-(void) removeLockedFileWithObject:(INDDataModel*)_file
{
     NSError *error;
     NSManagedObjectContext *context=[self managedObjectContext];
    
     for (NSManagedObject *obj in _arrOfFetchedfile)
     {
        NSLog(@"[obj valueForKey:filepath=%@",[obj valueForKey:@"filepath"]);
     if([[obj valueForKey:@"filepath"] isEqual:_file.fileFullPath])
     {
     [context deleteObject:obj];
     
     if (![context save:&error])
     {
     NSLog(@"error");
     }
     
     break;
     }
     
     }
     
//     NSFetchRequest *req=[[NSFetchRequest alloc]init];
//     NSEntityDescription *e=[NSEntityDescription entityForName:@"PasswordFiles" inManagedObjectContext:context];
//     [req setEntity:e];
//     _arrOfFetchedfile=[context executeFetchRequest:req error:nil];
    //_file.isFavourite=NO;
}


-(void)addPasswordToFile:(INDDataModel *)file
{
    NSError *error;
    
    int favFlag=0;
    
    NSManagedObjectContext *context=[self managedObjectContext];
    
    if(_arrOfFetchedfile.count==0)
    {
        PasswordFiles *passwordfile=[NSEntityDescription insertNewObjectForEntityForName:@"PasswordFiles" inManagedObjectContext:context];
        passwordfile.filepath=file.fileFullPath;   //
        NSLog(@"contex saved");
        
        if (![context save:&error])
        {
            NSLog(@"error");
        }
        
    }
    
    else
    {
        for (NSManagedObject *obj in _arrOfFetchedfile)
        {
            if([[obj valueForKey:@"filepath"]isEqual:file])
            {
                favFlag=1;
                break;
            }
        }
        if(favFlag==0)
        {
            PasswordFiles *passwordfile=[NSEntityDescription insertNewObjectForEntityForName:@"PasswordFiles" inManagedObjectContext:context];
            passwordfile.filepath=file.fileFullPath;   //
            NSLog(@"contex saved");
            
            if (![context save:&error])
            {
                NSLog(@"error");
            }
        }
        else
        {
            
        }
        
    }
    NSFetchRequest *req=[[NSFetchRequest alloc]init];
    NSEntityDescription *e=[NSEntityDescription entityForName:@"PasswordFiles" inManagedObjectContext:context];
    [req setEntity:e];
    _arrOfFetchedfile=[context executeFetchRequest:req error:nil];
    
    [[DatasourceSingltonClass sharedInstance].arrOfLockedFiles addObject:file];
    file.isLocked=YES;
    
    [otlTableView reloadData];
}
-(void)removePasswordFromFile:(INDDataModel *)file
{
    NSError *error;
    NSManagedObjectContext *context=[self managedObjectContext];
    
    for (NSManagedObject *obj in _arrOfFetchedfile)
    {
        
        if([[obj valueForKey:@"filepath"] isEqual:file.fileFullPath])
        {
            [[DatasourceSingltonClass sharedInstance].arrOfLockedFiles removeObject:file];
            
            [context deleteObject:obj];
            
            if (![context save:&error])
            {
                NSLog(@"error");
            }
            else
            {
                
            }
            
            break;
        }
    }
    NSFetchRequest *req=[[NSFetchRequest alloc]init];
    NSEntityDescription *e=[NSEntityDescription entityForName:@"PasswordFiles" inManagedObjectContext:context];
    [req setEntity:e];
    _arrOfFetchedfile=[context executeFetchRequest:req error:nil];
    file.isLocked=NO;
    [otlTableView reloadData];
}

#pragma mark-
#pragma mark- core data methods

-(void)saveFavouriteFiles:(INDDataModel*)file
{
    //
    NSError *error;
  
    NSManagedObjectContext *context=[self managedObjectContext];

   // if(success)
   // {
        FavouriteFiles *favApp=[NSEntityDescription insertNewObjectForEntityForName:@"FavouriteFiles" inManagedObjectContext:context];
        favApp.filepath=file.fileFullPath;
        
        NSLog(@"contex saved");
        
        if (![context save:&error])
        {
            NSLog(@"error");
        }
  //  }

NSFetchRequest *req=[[NSFetchRequest alloc]init];
NSEntityDescription *e=[NSEntityDescription entityForName:@"FavouriteFiles" inManagedObjectContext:context];
[req setEntity:e];
arrOfFetchedFavouritefiles=[context executeFetchRequest:req error:nil];
    for (NSManagedObject *obj in arrOfFetchedFavouritefiles)
    {
        [[DatasourceSingltonClass sharedInstance].arrOfFavFiles addObject:[obj valueForKey:@"filepath"]];
    }
//[self dataFetchMethod];
   file.isFavourite=YES;
    
   // [otlTableView reloadData];
    
    if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCarousel)
    {
        [self updateCoverFlowDataSource];
    }
    if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCollection)
    {
        [self updateCollectionDataSource];
    }
}

-(void)removeFavouriteFiles:(INDDataModel*)file
{
    [self deleteFavouriteFile:file.fileFullPath];
    file.isFavourite=NO;
   // [otlTableView reloadData];
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req2=[[NSFetchRequest alloc]init];
    NSEntityDescription *entity3=[NSEntityDescription entityForName:@"FavouriteFiles" inManagedObjectContext:context];
    [req2 setEntity:entity3];
    arrOfFetchedFavouritefiles=[context executeFetchRequest:req2 error:nil];
    if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCarousel)
    {
        [self updateCoverFlowDataSource];
    }
    if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCollection)
    {
        [self updateCollectionDataSource];
    }
}

#pragma mark- delete Favourite File

-(void)deleteFavouriteFile:(NSString*)filePath
{
    NSError *error;
    NSManagedObjectContext *context=[self managedObjectContext];
    
    for (NSManagedObject *obj in arrOfFetchedFavouritefiles)
    {
        NSLog(@"[obj valueForKey:filepath=%@",[obj valueForKey:@"filepath"]);
        NSLog(@"file.fulpath=%@",filePath);
        if([[obj valueForKey:@"filepath"] isEqual:filePath])
        {
            [context deleteObject:obj];
            [[DatasourceSingltonClass sharedInstance].arrOfFavFiles removeObject:filePath];
            if (![context save:&error])
            {
                NSLog(@"error");
            }
            break;
        }
    }
   }

-(void)removeThumbnailOfFile:(NSString*)file
{
    NSString *thumbnailPathToDelete =[thumbnailFilesPath stringByAppendingPathComponent:[file lastPathComponent]];
    NSURL *thumbnailURLToDelete=[NSURL fileURLWithPath:thumbnailPathToDelete];
    if([[NSFileManager defaultManager] fileExistsAtPath:thumbnailPathToDelete])
    {
        if([thumbnailArray containsObject:thumbnailURLToDelete])
        {
            [[NSFileManager defaultManager] removeItemAtPath:thumbnailPathToDelete error:nil];
        }
    }
}

#pragma mark-
#pragma mark-IDVHistoryViewControllerDelegeat method

-(void) ShowHistoryinTextBox:(NSString*)text
{
    textURL.text=text;
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
    }
    else
    {
        [historyPopoverController dismissPopoverAnimated:YES];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [self.otlTableView endEditing:YES];
}

#pragma mark-
#pragma mark- orientation method
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return YES;
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void)deviceOrientationDidChange
{
    [historyPopoverController dismissPopoverAnimated:YES];
    [settingPopover dismissPopoverAnimated:YES];
    [self.soringPopover dismissPopoverAnimated:YES];
}

-(void)orientationChanged:(NSNotification*)notification
{
    CGRect viewFrame = navigationBarView.frame;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        viewFrame.size.width = self.navigationItem.title ?100.0 : (self.navigationController.navigationBar.bounds.size.width - 30.0);
        [UIView animateWithDuration:0.1
                         animations:^{
                             
                             navigationBarView.frame = viewFrame;
                         }];
    }
    else
    {
        viewFrame.size.width = self.navigationItem.title ? 200.0 : (self.navigationController.navigationBar.bounds.size.width - 50.0);
        [UIView animateWithDuration:0.1
                         animations:^{
                             
                             navigationBarView.frame = viewFrame;
                         }];
    }
    
    
    [self changeOrientation];
    [otlTableView reloadData];
}

-(void)changeOrientation
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        [self setComponentsOnPortrait];
    }
    else
    {
        [self setComponentsOnLandscape];
    }
    
    if (_activityPopoverController.isPopoverVisible)
    {
        [_activityPopoverController dismissPopoverAnimated:NO];
        
        [_activityPopoverController presentPopoverFromRect:self.view.bounds
                                                    inView:self.view
                                  permittedArrowDirections:0
                                                  animated:YES];
    }
}

#pragma mark-
#pragma download pause cancel resume
-(void)cancel
{
   // [operation cancel];
}

-(void)pause
{
   // [operation pause];
}

-(void)resume
{
   // [operation resume];
    // [afHTTPClientObj.operationQueue cancelAllOperations];
}

# pragma mark
#pragma mark- AlertView Methods..

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"alertView.title=%@",alertView.title);
    
    NSError *error;
    
    if(alertView.tag==1)
    {
        BOOL isDIR;
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Replace"])
        {
            NSLog(@"replacing file...!!");
            
            NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            newTempDownloadFilePath=[documentsPath stringByAppendingPathComponent:@"iDocDir/tempDownloadFiles"];
            if(![[NSFileManager defaultManager] fileExistsAtPath:newTempDownloadFilePath isDirectory:&isDIR])
            {
                [[NSFileManager defaultManager] createDirectoryAtPath:newTempDownloadFilePath withIntermediateDirectories:YES attributes:nil error:&error];
            }
            
            operation.outputStream=[NSOutputStream outputStreamToFileAtPath:[newTempDownloadFilePath stringByAppendingPathComponent:[pathToStoreDownloadedFile lastPathComponent]] append:NO];
            
            //[afHTTPClientObj enqueueHTTPRequestOperation:operation];
            [operationQueue addOperation:operation];
            
            otl_DownloadProgressview.hidden=NO;
           // _otl_buttonDownloadProgress.hidden=NO;
            otl_downloadProgressLabel.hidden=NO;
            otl_DownloadLabel.hidden=NO;
            
            otl_DownloadLabel.text=[NSString stringWithFormat:@"Downloading 1 of %lu",(unsigned long)[operationQueue.operations count]];
        }
    }
    else if(alertView.tag==2)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"OK"])
        {
            [self deleteFileAtIndex:self.deleteFileIndex];
        }
    }
    
    else if(alertView.tag==3)
    {
        pathToUnzipingFile=directoryPathInDidSelect;
        
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Unzip"])
        {
            
            MBProgressHUD *unzipHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            unzipHud.delegate=self;
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                unzipHud.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
            }
            unzipHud.mode = MBProgressHUDModeCustomView;
            unzipHud.labelText = @"Unzipping File";
            [unzipHud hide:YES afterDelay:2];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                
                ZipArchive *unzip = [[ZipArchive alloc] init];
                if([unzip UnzipOpenFile:pathToUnzipingFile])
                {
                    BOOL isDIR;
                    NSError *error;
                    NSLog(@"unzipping..");
                    unZippingInProgress=1;
                    
                    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    
                    NSString *newTempUnzipFilePath=[documentsPath stringByAppendingPathComponent:@"iDocDir/tempUnzipedFiles"];
                    if(![[NSFileManager defaultManager] fileExistsAtPath:newTempUnzipFilePath isDirectory:&isDIR])
                    {
                        [[NSFileManager defaultManager] createDirectoryAtPath:newTempUnzipFilePath withIntermediateDirectories:YES attributes:nil error:&error];
                    }
                    
                    [unzip UnzipFileTo:newTempUnzipFilePath   overWrite:YES];
                    
                    [unzip UnzipCloseFile];
                    
                    
                    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/__MACOSX",newTempUnzipFilePath ] error:nil];
                }
                
                dispatch_async( dispatch_get_main_queue(), ^{
                    // Add code here to update the UI/send notifications based on the
                    // results of the background processing
                    
                    [self doneUnzipping];
                    
                });
                
            });
        }
    }
    else if(alertView.tag==50)
    {
        NSString *pathToExtractingingFile;
        pathToExtractingingFile=directoryPathInDidSelect;
        
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Extract"])
        {
            
            MBProgressHUD *updatehud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            updatehud.delegate=self;
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                updatehud.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
            }
            updatehud.mode = MBProgressHUDModeCustomView;
            updatehud.labelText = @"Extracting file";
            
            ZipArchive *unzip=[[ZipArchive alloc] init];
            if([unzip UnzipOpenFile:pathToExtractingingFile])
            {
                NSLog(@"unzipping..");
                [unzip UnzipFileTo:[pathToExtractingingFile stringByDeletingLastPathComponent] overWrite:YES];
                
                [unzip UnzipCloseFile];
                
                [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/__MACOSX",[pathToExtractingingFile stringByDeletingLastPathComponent]] error:nil];
                [[DatasourceSingltonClass sharedInstance].sharedDataSource addObject:[[pathToExtractingingFile stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Payload"]];
                
                NSString *oldPath=[[pathToExtractingingFile stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Payload"];
                
                NSString *newPath = [NSString stringWithFormat:@"%@_%@",[pathToExtractingingFile stringByDeletingPathExtension],@"Payload"];
                
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:newPath];
                if(fileExists)
                {
                    [[NSFileManager defaultManager] removeItemAtPath:newPath error:&error];
                    [[DatasourceSingltonClass sharedInstance].sharedDataSource removeObject:newPath];
                }
                
                [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:nil];
                [[DatasourceSingltonClass sharedInstance].sharedDataSource removeObject:oldPath];
                [[DatasourceSingltonClass sharedInstance].sharedDataSource addObject:newPath];
                
                [self reloadDataSource];
                if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCarousel)
                {
                    [self updateCoverFlowDataSource];
                    [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.tableView reloadData];
                    [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.carousel reloadData];
                }
                if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCollection)
                {
                    [self updateCollectionDataSource];
                    [[DatasourceSingltonClass sharedInstance].collectionViewObj.collectionView reloadData];
                }
               
                
                [updatehud removeFromSuperview];
            }
            
        }
        if([title isEqualToString:@"Install"])
        {
            
            //////##############
            NSString *path = [[directoryPathInDidSelect stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"];
            plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
            // [tempDict setObject:[NSURL fileURLWithPath:directoryPathInDidSelect] forKey:@"url"];
            //  [tempDict writeToFile:path atomically:YES];
            //  NSLog(@"tempdict url=%@",[tempDict objectForKey:@"url"]);
            //  NSLog(@"directoryPathInDidSelect=%@",[NSURL fileURLWithPath:directoryPathInDidSelect]);
            //////#############
            // NSLog(@"%@", [[[[[tempDict objectForKey:@"Array"] objectAtIndex:0] objectForKey:@"Array"] objectAtIndex:0] objectForKey:@"url"]);
            //  NSLog(@"items=%@",[tempDict objectForKey:@"items"]);
            //  NSLog(@"%@",[[tempDict objectForKey:@"items"] objectAtIndex:0]);
            //  NSLog(@"assets=%@",[[[tempDict objectForKey:@"items"] objectAtIndex:0] objectForKey:@"assets"]);
            // NSLog(@"assets=%@",[[[[tempDict objectForKey:@"items"] objectAtIndex:0] objectForKey:@"assets"] objectAtIndex:0]);
            // NSLog(@"assets=%@",[[[[[tempDict objectForKey:@"items"] objectAtIndex:0] objectForKey:@"assets"] objectAtIndex:0] objectForKey:@"url"]);
            
            ///traversing the pllist..
            //[self deal:plistDict];
            
            /* NSLog(@"plistDict=%@",plistDict);
             
             BOOL res1= [plistDict writeToFile:path atomically:YES];
             NSLog(@"res1=%hhd",res1);
             // [tempDict writeToFile:path atomically:YES];
             NSMutableDictionary *temp=[[NSMutableDictionary alloc] initWithContentsOfFile:path];
             NSLog(@"temp=%@",temp); */
            
            NSString *pathToInstallFile;
            
            pathToInstallFile=[[directoryPathInDidSelect stringByDeletingPathExtension] stringByAppendingPathExtension:@"plist"];
            
            NSLog(@"path to install file=%@",pathToInstallFile);
            //  NSString *urlString= [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=https://lms.indegene.com/appstore/install/%@.plist",[pathToUnzipingFile stringByDeletingPathExtension]];
            
            //            NSURL *installURL=[NSURL URLWithString:pathToInstallFile];
            //            installURL = [[NSURL alloc] initWithString:pathToInstallFile];
            
            
            NSURL *installURL = [NSURL fileURLWithPath:pathToInstallFile];
            NSLog(@" install url=%@",installURL);
            
            //  NSString *urlString= [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",[installURL path]];
            NSString *urlString= [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",installURL ];
            
            NSLog(@"urlstring=%@",urlString);
            
            NSURL *url = [NSURL URLWithString: urlString];
            
            NSLog(@"Final URL = %@",url);
            //   BOOL res=[[UIApplication sharedApplication] openURL:url];
            
            //            if (![[UIApplication sharedApplication] openURL:url]) {
            //                NSLog(@"Failed to open url:%@",[url description]);
            //            }
            
            if([[NSFileManager defaultManager] fileExistsAtPath:pathToInstallFile])
            {
                [[UIApplication sharedApplication] openURL:url];
                
            }
            else
            {
                MBProgressHUD *unzipHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                unzipHud.delegate=self;
                if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
                {
                    unzipHud.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
                }
                unzipHud.mode = MBProgressHUDModeCustomView;
                unzipHud.labelText = @"Unable to install";
                [unzipHud hide:YES afterDelay:2];
            }
            
            //   NSURL *rtfUrl = [[NSBundle mainBundle] URLForResource:@"azvilla" withExtension:@".ipa"];
            // NSString *urlString= [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",rtfUrl];
            // NSURL *url=[NSURL URLWithString:urlString];
            // [[UIApplication sharedApplication] openURL:rtfUrl];
        }
    }
    
    else  if(alertView.tag==25)
    {
        
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:@"Submit"])
        {
            
            if ([[[alertView textFieldAtIndex:0]text] isEqualToString:@""])
            {
                MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                HUD.delegate = self;
                if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
                {
                    HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
                }
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = @"Please Enter The Passcode";
                [HUD hide:YES afterDelay:1];
            }
            
            else
            {
                NSString *inputText = [[alertView textFieldAtIndex:0] text];
                [[ NSUserDefaults standardUserDefaults ] setObject:inputText forKey:@"passcode"];
                
                // isPosswordSet=NO;
                [[ NSUserDefaults standardUserDefaults ] setBool:NO forKey:@"setPasscode"];
                
                MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                HUD.delegate = self;
                if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
                {
                    HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
                }
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = @"Password is set successfully";
                [ HUD hide:YES afterDelay:1];
            }
        }
        
    }
    
    else if(alertView.tag==21)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Submit"])
        {
            NSString *inputText = [[alertView textFieldAtIndex:0] text];
            
            if ([[[alertView textFieldAtIndex:0]text] isEqualToString:@""])
            {
                MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                HUD.delegate = self;
                if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
                {
                    HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
                }
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = @"Please Enter The Passcode";
                [ HUD hide:YES afterDelay:1];
                
            }
            else if([[[ NSUserDefaults standardUserDefaults ] objectForKey:@"passcode"] isEqualToString:inputText])
            {
                [self didSelectMethodAtIndexPath:self.indexPathInDidselect];
                
            }
            else
            {
                MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                HUD.delegate = self;
                if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
                {
                    HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
                }
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = @"Incorrect Passcode";
                [HUD hide:YES afterDelay:1];
                
            }
        }
    }
    
    else if(alertView.tag==27)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Submit"])
        {
            NSString *inputText = [[alertView textFieldAtIndex:0] text];
            
            if ([[[alertView textFieldAtIndex:0]text] isEqualToString:@""])
            {
                MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                HUD.delegate = self;
                if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
                {
                    HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
                }
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = @"Please Enter The Passcode";
                [HUD hide:YES afterDelay:1];
                
            }
            else if([[[ NSUserDefaults standardUserDefaults ] objectForKey:@"passcode"] isEqualToString:inputText])
            {
                [self shareFileOnPath:fileToShare];
                
            }
            else
            {
                MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                HUD.delegate = self;
                if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
                {
                    HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
                }
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = @"Incorrect Passcode";
                [HUD hide:YES afterDelay:1];
            }
        }
    }
    
    else if(alertView.tag==28)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Submit"])
        {
            
            NSString *inputText = [[alertView textFieldAtIndex:0] text];
            
            if ([[[alertView textFieldAtIndex:0]text] isEqualToString:@""])
            {
                MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                HUD.delegate = self;
                if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
                {
                    HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
                }
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = @"Please Enter The Passcode";
                [HUD hide:YES afterDelay:1];
            }
            else if([[[ NSUserDefaults standardUserDefaults ] objectForKey:@"passcode"] isEqualToString:inputText])
            {
                [self deleteFileAtPath:fileToDelete];
                
                if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCarousel)
                {
                    [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.idvCoverFlowViewDelegateObj updateCoverFlowDataSource];
                    
                    [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.tableView reloadData];
                    [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.carousel reloadData];
                }
                else if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCollection)
                {
                    [[DatasourceSingltonClass sharedInstance].collectionViewObj.idvCollectionViewDelegate updateCollectionDataSource];
                    
                    [[DatasourceSingltonClass sharedInstance].collectionViewObj.collectionView reloadData];
                }
            }
            
            else
            {
                MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                HUD.delegate = self;
                if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
                {
                    HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
                }
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = @"Incorrect Passcode";
            }
        }
    }
    //else if ([alertView.title isEqualToString:@"Login"])
    else if (alertView.tag==401)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Submit"])
        {
            NSString *username=[alertView textFieldAtIndex:0].text;
            NSString *password=[alertView textFieldAtIndex:1].text;
            
            if ([[[alertView textFieldAtIndex:0]text] isEqualToString:@""]||[[[alertView textFieldAtIndex:1]text] isEqualToString:@""])
            {
                MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                HUD.delegate = self;
                HUD.mode = MBProgressHUDModeCustomView;
                if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
                {
                    HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
                }
                HUD.labelText = @"Please enter username and password";
                [HUD hide:YES afterDelay:1];
            }
            
            else
            {
                NSURLRequest *request=[NSURLRequest requestWithURL:self.failedOperation.request.URL];
                operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                
                NSURLCredential *credential = [NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistenceForSession];
                [operation setCredential:credential];
                [self downloadMethodWithFilePath:pathToStoreDownloadedFile username:username password:password];
            }
            
        }
        
    }
    
    else if (alertView.tag==500)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Video"])
        {
            NSLog(@"Video");
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypePhotoLibrary])
            {
                
                UIImagePickerController *picker= [[UIImagePickerController alloc]init];
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                picker.mediaTypes = [NSArray arrayWithObjects:
                                     (NSString *) kUTTypeMovie,
                                     nil];
                
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
                {
                    [self presentViewController:picker animated:YES completion:nil];
                }
                else
                {
                    videoLibraryPopover=[[UIPopoverController alloc] initWithContentViewController:picker];
                    
                    [videoLibraryPopover presentPopoverFromRect:self.navigationController.navigationBar.bounds inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                }
            }
        }
        else if([title isEqualToString:@"Image"])
        {
            NSLog(@"Image");
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeSavedPhotosAlbum])
            {
                
                UIImagePickerController *picker= [[UIImagePickerController alloc]init];
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                // [self presentViewController:picker animated:YES completion:nil];
                
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
                {
                    [self presentViewController:picker animated:YES completion:nil];
                }
                else
                {
                    videoLibraryPopover=[[UIPopoverController alloc] initWithContentViewController:picker];
                    
                    [videoLibraryPopover presentPopoverFromRect:self.navigationController.navigationBar.bounds inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                }
            }
        }
        else if([title isEqualToString:@"Music"])
        {
            NSLog(@"Music");
            
            MPMediaPickerController* picker = [[MPMediaPickerController alloc] init];
            picker.delegate = self;
            
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
    else if(alertView.tag==211)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Submit"])
        {
            NSString *inputText = [[alertView textFieldAtIndex:0] text];
            
            if ([[[alertView textFieldAtIndex:0]text] isEqualToString:@""])
            {
                MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                HUD.delegate = self;
                if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
                {
                    HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
                }
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = @"Please Enter The Passcode";
                [ HUD hide:YES afterDelay:1];
                
            }
            else if([[[ NSUserDefaults standardUserDefaults ] objectForKey:@"passcode"] isEqualToString:inputText])
            {
               // [self selectFileToDelete:(INDDataModel*)file indexPath:(NSIndexPath*)indexpath cell:(CustomCell*)cell ];
                [cellToBeSelected setAccessoryType:UITableViewCellAccessoryCheckmark];
                [selectedArr addObject:indexPathToBeSelected];
            }
            else
            {
                MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                HUD.delegate = self;
                if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
                {
                    HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
                }
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = @"Incorrect Passcode";
                [HUD hide:YES afterDelay:1];
                
            }
        }
    }

}

- (void) deal:(id)item
{
    if ([item isKindOfClass:[NSDictionary class]]) {
        for (id key in item) {
            id it = [item objectForKey:key];
            if ([it isKindOfClass:[NSDictionary class]] || [it isKindOfClass:[NSArray class]]) {
                [self deal:it];
            }
        }
        if ([item objectForKey:@"url"]!=nil) {
            [item setObject:[NSURL fileURLWithPath:directoryPathInDidSelect] forKey:@"url"];
            return;
            
        }
    }
    if ([item isKindOfClass:[NSArray class]]) {
        for (id it in item) {
            if ([it isKindOfClass:[NSDictionary class]] || [it isKindOfClass:[NSArray class]]) {
                [self deal:it];
            }
        }
    }
    //  [plistDict removeAllObjects];
    
    //plistDict=[NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)item];
    plistDict=item;
    
    NSLog(@"plistDict=%@",plistDict);
}
-(void)doneUnzipping
{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *newTempUnzipFilePath=[documentsPath stringByAppendingPathComponent:@"iDocDir/tempUnzipedFiles"];
    
    [[NSFileManager defaultManager] removeItemAtPath:pathToUnzipingFile error:nil];
    [[DatasourceSingltonClass sharedInstance].sharedDataSource removeObject:pathToUnzipingFile];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[pathToUnzipingFile stringByDeletingPathExtension]])
    {
        [[NSFileManager defaultManager] removeItemAtPath:[pathToUnzipingFile stringByDeletingPathExtension] error:nil];
    }
    
    [[NSFileManager defaultManager] moveItemAtPath:[newTempUnzipFilePath stringByAppendingPathComponent:[[pathToUnzipingFile lastPathComponent] stringByDeletingPathExtension]] toPath:[pathToUnzipingFile stringByDeletingPathExtension] error:nil];
    
    [self reloadDataSource];
    
    if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCarousel)
    {
        [self updateCoverFlowDataSource];
        [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.tableView reloadData];
        [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.carousel reloadData];
    }
    if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCollection)
    {
        [self updateCollectionDataSource];
        [[DatasourceSingltonClass sharedInstance].collectionViewObj.collectionView reloadData];
    }
    
    unZippingInProgress=0;
}

#pragma mark- delete file
-(void) deleteFileAtIndex:(int)deletefileIndex
{
    //NSError *error;
    self.deleteFileIndex=deletefileIndex;
    INDDataModel *file=fileToDelete=[[DatasourceSingltonClass sharedInstance].sharedDataSource objectAtIndex:self.deleteFileIndex];
    deletePath=[self.currentDirectoryPath stringByAppendingPathComponent:[file.fileFullPath lastPathComponent]];
    
    
    int a=0;
    for (NSManagedObject *obj in _arrOfFetchedfile)
    {
        if([[obj valueForKey:@"filepath"] isEqual:deletePath])
        {
            
            a=1;
            break;
        }
    }
    if(a==1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Passcode Protected File" message:@"Enter Passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
        [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
        [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        [alert textFieldAtIndex:0].keyboardAppearance = UIKeyboardAppearanceLight;
        
        [alert setTag:28];
        [[alert textFieldAtIndex:0] setTag:3];
        [alert show];
    }
    else
    {
        [self deleteFileAtPath:file];
        
        if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCarousel)
        {
            [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.idvCoverFlowViewDelegateObj updateCoverFlowDataSource];
            
            [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.tableView reloadData];
            [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.carousel reloadData];
        }
        else if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCollection)
        {
            [[DatasourceSingltonClass sharedInstance].collectionViewObj.idvCollectionViewDelegate updateCollectionDataSource];
            
            [[DatasourceSingltonClass sharedInstance].collectionViewObj.collectionView reloadData];
        }
    }
}

-(void)deleteFileAtPath:(INDDataModel*)file
{
    HUD1 = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD1.delegate=self;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        HUD1.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
    }
    HUD1.mode = MBProgressHUDModeIndeterminate;
    HUD1.labelText = @"Deleting";
    [HUD1 show:YES];
    
    NSError *error;
    BOOL success;
    NSManagedObjectContext *context=[self managedObjectContext];
    
    if(file.isFolder)
    {
        [self deleteDirectory:file];
    }
    else{
        success =[[NSFileManager defaultManager] removeItemAtPath:file.fileFullPath error:&error];
    
        if(success)
        {
           // [[DatasourceSingltonClass sharedInstance].sharedDataSource removeObjectAtIndex:deleteFileIndex];
            
            [self removeThumbnailOfFile:file.fileFullPath];
            for (NSManagedObject *obj in _arrOfFetchedfile)
            {
                
                if( [file.fileFullPath isEqualToString:[obj valueForKey:@"filepath"]])
                {
                    
                    [context deleteObject:obj];
                    [[DatasourceSingltonClass sharedInstance].arrOfLockedFiles removeObject:[obj valueForKey:@"filepath"]];
                    
                    if (![context save:&error])
                    {
                        NSLog(@"error");
                    }
                }
            }
            
        [self deleteFavouriteFile:file.fileFullPath];

        }
        else
        {
            NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
        }
    }
    [[DatasourceSingltonClass sharedInstance].sharedDataSource removeObjectAtIndex:deleteFileIndex];
    
    NSFetchRequest *req2=[[NSFetchRequest alloc]init];
    NSEntityDescription *entity3=[NSEntityDescription entityForName:@"FavouriteFiles" inManagedObjectContext:context];
    [req2 setEntity:entity3];
    arrOfFetchedFavouritefiles=[context executeFetchRequest:req2 error:nil];
    
    NSEntityDescription *entity4=[NSEntityDescription entityForName:@"PasswordFiles" inManagedObjectContext:context];
    [req2 setEntity:entity4];
    _arrOfFetchedfile=[context executeFetchRequest:req2 error:nil];

   // [self reloadDataSource];
    [otlTableView reloadData];
    [HUD1 hide:YES];
    
    MBProgressHUD *updatehud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    updatehud.delegate=self;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        updatehud.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
    }
    updatehud.mode = MBProgressHUDModeCustomView;
    updatehud.labelText = @"Deleted";
    [updatehud hide:YES afterDelay:1];
}

-(void) deleteDirectory:(INDDataModel*)file
{
    NSError *error;
    NSManagedObjectContext *context=[self managedObjectContext];

    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:file.fileFullPath
                                                                              error:&error];
    
    NSMutableArray *newFileArray=[[NSMutableArray alloc]init];
    NSString *stringToCompare=nil;
    for(NSString *file1 in filesArray)
    {
        stringToCompare=[ file.fileFullPath stringByAppendingPathComponent:file1];
        [newFileArray addObject:stringToCompare];
    }
    [newFileArray addObject:file.fileFullPath];
    
    for (NSManagedObject *obj in _arrOfFetchedfile)
    {
        
        if( [newFileArray containsObject:[obj valueForKey:@"filepath"]])
        {
            
            [context deleteObject:obj];
            [[DatasourceSingltonClass sharedInstance].arrOfLockedFiles removeObject:[obj valueForKey:@"filepath"]];
            
            if (![context save:&error])
            {
                NSLog(@"error");
            }
        }
    }
    
    for (NSManagedObject *obj in arrOfFetchedFavouritefiles)
    {
        if([newFileArray containsObject:[obj valueForKey:@"filepath"]])
        {
            [context deleteObject:obj];
            [[DatasourceSingltonClass sharedInstance].arrOfFavFiles removeObject:[obj valueForKey:@"filepath"]];
            [self removeThumbnailOfFile:[obj valueForKey:@"filepath"]];
            if (![context save:&error])
            {
                NSLog(@"error");
            }
        }
    }

    [[NSFileManager defaultManager] removeItemAtPath:file.fileFullPath error:&error];
}


#pragma mark-
#pragma mark- setting class delegate method
-(void)showFavourites
{
    NSMutableArray *favouriteArray=[[NSMutableArray alloc]init];
    [favouriteArray removeAllObjects];
    
    if(arrOfFetchedFavouritefiles.count==0)
    {
        [self.settingPopover dismissPopoverAnimated:YES];
        MBProgressHUD *updatehud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        updatehud.delegate=self;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            updatehud.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
        }
        updatehud.mode = MBProgressHUDModeCustomView;
        updatehud.labelText = @"No Favourites Found";
        [updatehud hide:YES afterDelay:2];
    }
    else
    {
        [self.settingPopover dismissPopoverAnimated:YES];
        IDVFavouriteViewController *idvFavouriteViewControllerObj;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            idvFavouriteViewControllerObj=[[IDVFavouriteViewController alloc]initWithNibName:@"IDVFavouriteViewController_iPhone" bundle:nil];
        }
        else
        {
            idvFavouriteViewControllerObj=[[IDVFavouriteViewController alloc]initWithNibName:@"IDVFavouriteViewController" bundle:nil];
        }
        idvFavouriteViewControllerObj.favouriteVCDelegate=self;
        [self.navigationController pushViewController:idvFavouriteViewControllerObj animated:YES];
    }
    
}

-(void)showHelpContent
{
    [self.settingPopover dismissPopoverAnimated:YES];
}
-(void)contactUs
{
    [self.settingPopover dismissPopoverAnimated:YES];
    
    if (internetConnection) {
        MFMailComposeViewController *composer=[[MFMailComposeViewController alloc]init];
        [composer setMailComposeDelegate:self];
        if ([MFMailComposeViewController canSendMail]) {
            [composer setToRecipients:[NSArray arrayWithObjects:@" idocviewersupport@indegene.com",nil]];
            [composer setSubject:@""];
            
            [composer setMessageBody:@"" isHTML:NO];
            [composer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
            [composer setModalPresentationStyle:UIModalPresentationFormSheet];
            [self presentViewController:composer animated:YES completion:nil];
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No internet" message:[NSString stringWithFormat: @"Please check your Network Settings"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}

-(void)showPasswordSection
{
    UIViewAutoresizing autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        
        self.passwordChangeVCObj = [[IDVPasswordChangeViewController alloc] initWithNibName:@"IDVPasswordChangeViewController_iPhone" bundle:nil];
        _passwordChangeVCObj.delegate=self;
        
        _passwordChangeVCObj.modalPresentationStyle= UIModalPresentationFormSheet;
        _passwordChangeVCObj.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        _passwordChangeVCObj.view.frame = self.view.bounds;
        _passwordChangeVCObj.view.autoresizingMask = autoresizingMask;
        [self.view addSubview:_passwordChangeVCObj.view];
        
        navigationBarCoverView = [[UIView alloc]init];
        navigationBarCoverView.frame = self.view.bounds;
        navigationBarCoverView.autoresizingMask = autoresizingMask;
        navigationBarCoverView.backgroundColor=[UIColor lightGrayColor];
        navigationBarCoverView.alpha=0.3;
        [self.navigationController.navigationBar addSubview:navigationBarCoverView];
        [self.navigationController.navigationBar bringSubviewToFront:navigationBarCoverView];
        SettingButton.enabled=NO;
        segmentedControl.enabled=NO;
        HistoryButton.enabled=NO;
        SubmitButton.enabled=NO;
        self.textURL.enabled=NO;
        self.navigationController.navigationItem.hidesBackButton=YES;
        
    }
    else
    {
        [self.settingPopover dismissPopoverAnimated:YES];
        
        self.passwordChangeVCObj = [[IDVPasswordChangeViewController alloc] init];
        _passwordChangeVCObj.view.frame = self.view.bounds;
        _passwordChangeVCObj.view.autoresizingMask = autoresizingMask;
        _passwordChangeVCObj.delegate=self;
        
        _passwordChangeVCObj.modalPresentationStyle= UIModalPresentationFormSheet;
        _passwordChangeVCObj.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [self.view addSubview:_passwordChangeVCObj.view];
        // _passwordChangeVCObj.view.center = self.view.center;
        
        navigationBarCoverView =[[UIView alloc]init];
        navigationBarCoverView.frame = self.view.bounds;
        navigationBarCoverView.autoresizingMask = autoresizingMask;
        navigationBarCoverView.backgroundColor=[UIColor lightGrayColor];
        navigationBarCoverView.alpha=0.3;
        [self.navigationController.navigationBar addSubview:navigationBarCoverView];
        [self.navigationController.navigationBar bringSubviewToFront:navigationBarCoverView];
        SettingButton.enabled=NO;
        segmentedControl.enabled=NO;
        HistoryButton.enabled=NO;
        SubmitButton.enabled=NO;
        self.textURL.enabled=NO;
        self.navigationController.navigationItem.hidesBackButton=YES;
    }
}

-(void)fetchMediaFiles
{
    [self.settingPopover dismissPopoverAnimated:YES];
    NSError *error;
    BOOL isDIR;
    NSString *DocumentFilePath=[self rootFolderPath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:DocumentFilePath isDirectory:&isDIR])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:DocumentFilePath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    UIAlertView *musicAlertView = [[UIAlertView alloc] initWithTitle:@"Import" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Image",@"Music",@"Video", nil];
    musicAlertView.tag=500;
    [musicAlertView show];
    
}

#pragma mark-

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (error) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"error" message:[NSString stringWithFormat:@"error %@",[error description]] delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
        [alert show];
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [popover dismissPopoverAnimated:YES];
    popover=nil;
}
-(void) mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *currentDate = [NSDate date];
    NSString   *theDate = [dateFormatter stringFromDate:currentDate];
    // Get AVAsset
    NSURL* assetUrl = [mediaItemCollection.representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
    AVURLAsset* asset = [AVURLAsset URLAssetWithURL:assetUrl options:nil];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset: asset
                                                                      presetName: AVAssetExportPresetAppleM4A];
    exporter.outputFileType = @"com.apple.m4a-audio";
    
    NSString *exportFile = [[self rootFolderPath] stringByAppendingPathComponent:
                            [NSString stringWithFormat:@"audio-%@.m4a",theDate]];
    
    NSURL *exportURL = [NSURL fileURLWithPath:exportFile];
    exporter.outputURL = exportURL;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    MBProgressHUD *updatehud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    updatehud.delegate=self;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        updatehud.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
    }
    updatehud.mode = MBProgressHUDModeCustomView;
    updatehud.labelText = @"Importing File";
    [updatehud hide:YES afterDelay:2];
    
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus = exporter.status;
        switch (exportStatus) {
            case AVAssetExportSessionStatusFailed: {
                // log error to text view
                NSError *exportError = exporter.error;
                NSLog (@"AVAssetExportSessionStatusFailed: %@",
                       exportError);
                
                NSString *errorView = exportError ?
				[exportError description] : @"Unknown failure";
                NSLog(@"errorView==>%@",errorView);
                break;
            }
            case AVAssetExportSessionStatusCompleted: {
                NSLog (@"AVAssetExportSessionStatusCompleted");
                [self dataFetchMethod];
                [otlTableView reloadData];
                
                NSString *errorView  =[exporter.outputURL lastPathComponent];
                NSLog(@"errorView==>%@",errorView);
                break;
            }
            case AVAssetExportSessionStatusUnknown: {
                NSLog (@"AVAssetExportSessionStatusUnknown"); break;}
            case AVAssetExportSessionStatusExporting: {
                NSLog (@"AVAssetExportSessionStatusExporting"); break;}
            case AVAssetExportSessionStatusCancelled: {
                NSLog (@"AVAssetExportSessionStatusCancelled"); break;}
            case AVAssetExportSessionStatusWaiting: {
                NSLog (@"AVAssetExportSessionStatusWaiting"); break;}
            default: { NSLog (@"didn't get export status"); break;}
        }
    }];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:window animated:YES];
    HUD.delegate=self;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
    }
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Importing";
    [HUD show:YES];
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *currentDate = [NSDate date];
    NSString   *theDate = [dateFormatter stringFromDate:currentDate];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *videoPath=[[self rootFolderPath] stringByAppendingPathComponent:[videoURL lastPathComponent]];
        
        NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
        [videoData writeToFile:videoPath atomically:YES];
    }
    else
    {
        
        UIImage  *imageToSave = nil;
        imageToSave = [[info objectForKey:@"UIImagePickerControllerOriginalImage"]fixOrientation];
        NSString *filePath=[[self rootFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"image-%@.png",theDate]];
        
        NSData *pngData = UIImageJPEGRepresentation(imageToSave, 0.7);
        
        [pngData writeToFile:filePath atomically:NO];
        
     [self saveThumbnailImage:imageToSave path:filePath file:nil];
    
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
        else
        {
            [videoLibraryPopover dismissPopoverAnimated:YES];
        }
        
        switch ([DatasourceSingltonClass sharedInstance].viewStyle)
        {
            case eFileViewerTypeList:
            {
                [self.otlTableView reloadData];
                
                break;
            }
                
            case eFileViewerTypeCarousel:
            {
                [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.tableView reloadData];
                [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.carousel reloadData];
                
                break;
            }
                
            case eFileViewerTypeCollection:
            {
                [[DatasourceSingltonClass sharedInstance].collectionViewObj.collectionView reloadData];
                
                break;
            }
        }
    }
    
    HUD.hidden=YES;
}

#pragma mark-
#pragma mark- network change method

- (void)handleNetworkChange:(NSNotification *)notice
{
    NetworkStatus status = [reachability currentReachabilityStatus];
    if(status == NotReachable)
        internetConnection=NO;
    else
        internetConnection=YES;
    
    NSLog(@"internetConnection=%hhd",internetConnection);
}

#pragma -
#pragma- image Highlight method

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark-
#pragma mark- segmentcontrle action method

-(void)segmentControlAction:(id)sender
{
    [self onClickCancelMultipleSelection:nil];
    isInLockMode=NO;
    [otl_EditButton setTitle:@"Edit" forState:UIControlStateNormal];
    if(segmentedControl.selectedSegmentIndex==0)
    {
        otl_EditButton.hidden=YES;
        
        otlTableView.hidden=NO;
        [DatasourceSingltonClass sharedInstance].viewStyle=eFileViewerTypeList;
        
        [DatasourceSingltonClass sharedInstance].coverFlowViewObj.hidden=YES;
        [DatasourceSingltonClass sharedInstance].collectionViewObj.hidden=YES;
        [[DatasourceSingltonClass sharedInstance].collectionViewObj removeFromSuperview];
        [[DatasourceSingltonClass sharedInstance].coverFlowViewObj removeFromSuperview];
        [DatasourceSingltonClass sharedInstance].coverFlowViewObj=nil;
        [DatasourceSingltonClass sharedInstance].collectionViewObj=nil;
        [DatasourceSingltonClass sharedInstance].CommonDirectoryPath=self.currentDirectoryPath;
        [DatasourceSingltonClass sharedInstance].fileLockTag=NO;
        [otlTableView reloadData];
        [self changeOrientation];
        self.viewTag=0;
        _otl_MultipleDelButton.hidden=NO;
       // _otl_buttonDownloadProgress.hidden=NO;
    }
    if(segmentedControl.selectedSegmentIndex==1)
    {
        otl_EditButton.hidden=YES;
        
        [self onClickDoneLockingFiles];
        
        [DatasourceSingltonClass sharedInstance].viewStyle=eFileViewerTypeCarousel;
        [DatasourceSingltonClass sharedInstance].coverFlowViewObj.hidden=NO;
        otlTableView.hidden=YES;
        
        [DatasourceSingltonClass sharedInstance].collectionViewObj.hidden=YES;
        [[DatasourceSingltonClass sharedInstance].collectionViewObj removeFromSuperview];
        [DatasourceSingltonClass sharedInstance].collectionViewObj=nil;
        
        [DatasourceSingltonClass sharedInstance].coverFlowViewObj=[[IDVCoverFlowVIew alloc]init];
        [DatasourceSingltonClass sharedInstance].coverFlowViewObj.idvCoverFlowViewDelegateObj=self;
        [DatasourceSingltonClass sharedInstance].CommonDirectoryPath=self.currentDirectoryPath;
        [[DatasourceSingltonClass sharedInstance].coverFlowViewObj initialization];
        
        [self.view addSubview:[DatasourceSingltonClass sharedInstance].coverFlowViewObj];
        self.viewTag=1;
        _otl_MultipleDelButton.hidden=YES;
      //  _otl_buttonDownloadProgress.hidden=YES;
       // [self onClickDismissDownloadProgressBar:nil];
    }
    if(segmentedControl.selectedSegmentIndex==2)
    {
        otl_EditButton.hidden=NO;
        // otl_EditButton.titleLabel.text=@"Edit";
        // otl_EditButton.titleLabel.tintColor=[UIColor darkGrayColor];
        
        [self onClickDoneLockingFiles];
        [DatasourceSingltonClass sharedInstance].viewStyle=eFileViewerTypeCollection;
        [DatasourceSingltonClass sharedInstance].coverFlowViewObj.hidden=YES;
        [[DatasourceSingltonClass sharedInstance].coverFlowViewObj removeFromSuperview];
        [DatasourceSingltonClass sharedInstance].coverFlowViewObj=nil;
        NSLog(@"coverflow obj=%@",[DatasourceSingltonClass sharedInstance].coverFlowViewObj);
        [DatasourceSingltonClass sharedInstance].collectionViewObj.hidden=NO;
        otlTableView.hidden=YES;
        
        [DatasourceSingltonClass sharedInstance].collectionViewObj=[[IDVCollectionVIew alloc]init];
        [DatasourceSingltonClass sharedInstance].collectionViewObj.idvCollectionViewDelegate=self;
        [DatasourceSingltonClass sharedInstance].CommonDirectoryPath=self.currentDirectoryPath;
        [[DatasourceSingltonClass sharedInstance].collectionViewObj initialization];
        
        [self.view addSubview:[DatasourceSingltonClass sharedInstance].collectionViewObj];
        self.viewTag=2;
        _otl_MultipleDelButton.hidden=YES;
      //  _otl_buttonDownloadProgress.hidden=YES;
      //  [self onClickDismissDownloadProgressBar:nil];

    }
}

//-(void)sortTableData
//{
//  self.filepaths=(NSMutableArray*)[self.filepaths sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//       return [obj1 caseInsensitiveCompare:obj2];
//   }];
//}

#pragma mark-
#pragma mark- coverflowDelegate method

-(void)coverFlowDidSelectAtindexPath:(NSIndexPath*)indexPath
{
    [DatasourceSingltonClass sharedInstance].viewStyle=eFileViewerTypeCarousel;
    [self commonDidSelectAtIndexPath:indexPath];
}

#pragma mark-
#pragma mark- collectionViewClassDelegate method
-(void)collectionViewDidSelectAtindexPath:(NSIndexPath *)indexPath
{
    [DatasourceSingltonClass sharedInstance].viewStyle=eFileViewerTypeCollection;
    [self commonDidSelectAtIndexPath:indexPath];
}

-(void)commonDidSelectAtIndexPath:(NSIndexPath*)indexPath
{
    self.indexPathInDidselect=indexPath;
    
    INDDataModel *file=[[DatasourceSingltonClass sharedInstance].sharedDataSource objectAtIndex:indexPath.row];
    if(file.isLocked)
    {
        UIAlertView *fileProtectedAlert = [[UIAlertView alloc] initWithTitle:@"Passcode Protected File" message:@"Enter Passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
        [fileProtectedAlert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
        [[fileProtectedAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        [fileProtectedAlert textFieldAtIndex:0].keyboardAppearance = UIKeyboardAppearanceLight;
        [fileProtectedAlert setTag:21];
        [[fileProtectedAlert textFieldAtIndex:0] setTag:4];
        [fileProtectedAlert show];
    }
    else
    {
        [self didSelectMethodAtIndexPath:indexPath];
    }
}

-(void)didSelectMethodAtIndexPath:(NSIndexPath*)indexPath
{
    BOOL isDirectory;
    
    INDDataModel *file=[[DatasourceSingltonClass sharedInstance].sharedDataSource objectAtIndex:indexPath.row];
    directoryPathInDidSelect = file.fileFullPath;
    
    if(!file.isLocked)
    {
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPathInDidSelect isDirectory:&isDirectory] && isDirectory)
        {
            IDVViewController *idvViewController;
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                idvViewController=[[IDVViewController alloc]initWithNibName:@"IDVViewController_iPhone" bundle:nil];
            }
            else
            {
                idvViewController=[[IDVViewController alloc]initWithNibName:@"IDVViewController" bundle:nil];
            }
            
            idvViewController.currentDirectoryPath = [self.currentDirectoryPath stringByAppendingPathComponent:[directoryPathInDidSelect lastPathComponent]];
            DatasourceSingltonClass* sharedSingleton = [DatasourceSingltonClass sharedInstance];
            sharedSingleton.CommonDirectoryPath=idvViewController.currentDirectoryPath;
            
            if(self.viewTag==1)
                [DatasourceSingltonClass sharedInstance].viewStyle=eFileViewerTypeCarousel;
            else if(self.viewTag==2)
                [DatasourceSingltonClass sharedInstance].viewStyle=eFileViewerTypeCollection;
            
            idvViewController.isNotCalledFirstTime=YES;
            [self.navigationController pushViewController:idvViewController animated:YES];
        }
        
        else if([[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"xls"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"xml" ]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"doc"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"xlsx"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"docx"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"ppt"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"pptx"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"json"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"html"]|| [[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"htm"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"htmls"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"htt"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"htx"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"pdf"])
            
        {
            [DatasourceSingltonClass sharedInstance].webViewFlag= @"supportedFiles";
            IDVWebViewController *idvWebViewControllerObj;
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
             idvWebViewControllerObj=[[IDVWebViewController alloc]initWithNibName:@"IDVWebViewController_iPhone" bundle:nil];

            }
            else
            {
              idvWebViewControllerObj=[[IDVWebViewController alloc]initWithNibName:@"IDVWebViewController" bundle:nil];
            }
            idvWebViewControllerObj.selectedRowIndexNumbr=indexPath.row;
            idvWebViewControllerObj.path=directoryPathInDidSelect;
            [self.navigationController pushViewController:idvWebViewControllerObj animated:YES];
        }
        
        else if([[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"png"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"jpeg"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"jpg"])
        {
            
            [DatasourceSingltonClass sharedInstance].webViewFlag= @"supportedFiles";
            IDVWebViewController *idvWebViewControllerObj;
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                idvWebViewControllerObj=[[IDVWebViewController alloc]initWithNibName:@"IDVWebViewController_iPhone" bundle:nil];
                
            }
            else
            {
                idvWebViewControllerObj=[[IDVWebViewController alloc]initWithNibName:@"IDVWebViewController" bundle:nil];
            }

            idvWebViewControllerObj.selectedRowIndexNumbr=indexPath.row;
            idvWebViewControllerObj.path=directoryPathInDidSelect;
            [self.navigationController pushViewController:idvWebViewControllerObj animated:YES];
            
        }
        
        else  if([[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"mov"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"mp4"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"mp3"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"m4v"]||
                 [[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"wav"]||
                 [[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"3gp"]||
                 [[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"mpv"]||
                 [[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"m4p"]||
                 [[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"caf"]||
                 [[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"m4a"])
        {
            
            IDVMediaPlayerViewController *idvMediaPlayerVCObj=[[IDVMediaPlayerViewController alloc]init];
            idvMediaPlayerVCObj.fileDirectoryPath=directoryPathInDidSelect;
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:idvMediaPlayerVCObj];
            [self presentViewController:navController animated:YES completion:^{
                
            }];
        }
        
        else if([[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"zip"])
        {
            if(unZippingInProgress==0)
            {
                UIAlertView *unzipAlert = [[UIAlertView alloc] initWithTitle:@"iDocViewer" message:[NSString stringWithFormat: @"Do you want to unzip the file?"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Unzip",nil];
                unzipAlert.tag=3;
                [unzipAlert show];
            }
            else
            {
                MBProgressHUD *unzipHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                unzipHud.delegate=self;
                if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
                {
                    unzipHud.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
                }
                unzipHud.mode = MBProgressHUDModeCustomView;
                unzipHud.labelText = @"Unzipping file";
                [unzipHud hide:YES afterDelay:2];
                
            }
            
        }
        else if([[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"ipa"])
        {
            UIAlertView *unzipIpa = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Extract",@"Install",nil];
            unzipIpa.tag=50;
            [unzipIpa show];
            
        }
        else if([[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"txt"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"text"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"rtf"]||[[[directoryPathInDidSelect pathExtension] lowercaseString] isEqualToString:@"plist"])
        {
            IDVTextViewController *idvTextVCObj=[[IDVTextViewController alloc]initWithNibName:@"IDVTextViewController" bundle:nil];
            idvTextVCObj.path=directoryPathInDidSelect;
            [self.navigationController pushViewController:idvTextVCObj animated:YES];
        }
        
        else
        {
            // otl_LblUnsupportedFile.hidden=NO;
            
            MBProgressHUD *unzipHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            unzipHud.delegate=self;
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                unzipHud.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
            }
            unzipHud.mode = MBProgressHUDModeCustomView;
            unzipHud.labelText = @"Unable to open the file";
            [unzipHud hide:YES afterDelay:1];
        }
    }
}

#pragma mark- willMoveToParentViewController
- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
        
        DatasourceSingltonClass *sharedSingleton=[DatasourceSingltonClass sharedInstance];
        sharedSingleton.CommonDirectoryPath=[self.currentDirectoryPath stringByDeletingLastPathComponent];
        self.otlTableView.dataSource=nil;
        self.otlTableView.delegate=nil;
        
        [DatasourceSingltonClass sharedInstance].coverFlowViewObj.tableView.dataSource=nil;
        [DatasourceSingltonClass sharedInstance].coverFlowViewObj.tableView.delegate=nil;
        
        if([[NSFileManager defaultManager] fileExistsAtPath:thumbnailFilesPath])
        [[NSFileManager defaultManager] removeItemAtPath:thumbnailFilesPath error:nil];
    }
}

#pragma mark-
#pragma favouriteVCCustomCell delegate
-(void)updateTable
{
    // [otlTableView reloadData];
    [self reloadDataSource];
}

#pragma mark-
#pragma favourite view controller delegate
-(void)updateTableAfterFavFileDeleted
{
    // [otlTableView reloadData];
    [self reloadDataSource];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.otlTableView setEditing:NO];
    
}

#pragma mark-Tableview reloadDataSource

-(void)reloadDataSource
{
    [self dataFetchMethod];
    [self.otlTableView reloadData];
}

#pragma mark- collection view delegate

-(void) updateCollectionDataSource
{
    [DatasourceSingltonClass sharedInstance].collectionViewObj.collectionViewDataSource=[[DatasourceSingltonClass sharedInstance].sharedDataSource mutableCopy];
}
#pragma mark-coverFlow delegate

-(void) updateCoverFlowDataSource
{
    [DatasourceSingltonClass sharedInstance].coverFlowViewObj.coverFlowDataSource=[[DatasourceSingltonClass sharedInstance].sharedDataSource mutableCopy];
}

#pragma mark- password Change delegate methods

-(void)didChangePassword
{
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
    HUD.delegate = self;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
    }
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = @"Passcode Changed Successfully";
    [HUD hide:YES afterDelay:1];
    
}
-(void)cancelPasswordModelViewController
{
    _passwordChangeVCObj=nil;
    [navigationBarCoverView removeFromSuperview];
    navigationBarCoverView=nil;
    SettingButton.enabled=YES;
    segmentedControl.enabled=YES;
    HistoryButton.enabled=YES;
    SubmitButton.enabled=YES;
    self.textURL.enabled=YES;
    self.navigationController.navigationItem.hidesBackButton=NO;
}
-(void)didSubmitPassword
{
    isInLockMode=YES;
    [navigationBarCoverView removeFromSuperview];
    navigationBarCoverView=nil;
    SettingButton.enabled=YES;
    segmentedControl.enabled=YES;
    HistoryButton.enabled=YES;
    SubmitButton.enabled=YES;
    self.textURL.enabled=YES;
    self.navigationController.navigationItem.hidesBackButton=NO;
}
-(void)submitPasswordChangeDelegateMethod
{
    otlTableView.hidden=NO;
    
    segmentedControl.selectedSegmentIndex=0;
    SettingButton.hidden=YES;
    DoneButtonInPasswordSection.hidden=NO;
    [DatasourceSingltonClass sharedInstance].viewStyle=eFileViewerTypeList;
    [DatasourceSingltonClass sharedInstance].favViewStyle=eFileViewerTypeList;
    
    [DatasourceSingltonClass sharedInstance].fileLockTag=YES;
    [[DatasourceSingltonClass sharedInstance].collectionViewObj removeFromSuperview];
    [[DatasourceSingltonClass sharedInstance].coverFlowViewObj removeFromSuperview];
    [DatasourceSingltonClass sharedInstance].collectionViewObj=nil;
    [DatasourceSingltonClass sharedInstance].coverFlowViewObj =nil;
    [otlTableView reloadData];
}

#pragma mark textfield delegate method

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    // Check for non-numeric characters
    if(textField.tag==1)
    {
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS_ONLY] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        
        if(![string isEqualToString:filtered])
        {
            
            MBProgressHUD *unzipHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            unzipHud.delegate=self;
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                unzipHud.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
            }
            unzipHud.mode = MBProgressHUDModeCustomView;
            unzipHud.labelText = @"Passcode should be numeric";
            [unzipHud hide:YES afterDelay:1];
            
            return NO;
        }
        if((newLength > CHARACTER_LIMIT))
        {
            
            MBProgressHUD *unzipHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            unzipHud.delegate=self;
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                unzipHud.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
            }
            unzipHud.mode = MBProgressHUDModeCustomView;
            unzipHud.labelText = @"Passcode cannot be more than 4 digits";
            [unzipHud hide:YES afterDelay:1];
            
            return NO;
        }
        return YES;
    }
    else
    {
        return YES;
    }
}

#pragma mark - MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidden
	[hud removeFromSuperview];
    hud=nil;
    
}
- (IBAction)onClickAllowMultipleDeletion:(id)sender
{
    if([_otl_MultipleDelButton.titleLabel.text isEqualToString:@"Edit"])
    {
        MBProgressHUD *updatehud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        updatehud.delegate=self;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            updatehud.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
        }
        updatehud.mode = MBProgressHUDModeCustomView;
        updatehud.labelText = @"Please select files to delete";
        [updatehud hide:YES afterDelay:1];
        
        selectedArr=[[NSMutableArray alloc]init];

        [_otl_MultipleDelButton setTitle:@"Delete" forState:UIControlStateNormal];
        isEditing=YES;
        [self.otlTableView reloadData];
        _otl_CancelMultipleSelection.hidden=NO;
    }
    else
    {
        BOOL deleteSpecificRows = selectedArr.count > 0;
        if (deleteSpecificRows)
        {
            // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
            
            HUD1 = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            HUD1.delegate=self;
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                HUD1.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
            }
            HUD1.mode = MBProgressHUDModeIndeterminate;
            HUD1.labelText = @"Deleting";
            [HUD1 show:YES];

            NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
            for (NSIndexPath *selectionIndex in selectedArr)
            {
                [indicesOfItemsToDelete addIndex:selectionIndex.row];
            }
            // Delete the objects from our data model.
            
            
            for(NSIndexPath *indepath in selectedArr)
            {
                INDDataModel *file=[[DatasourceSingltonClass sharedInstance].sharedDataSource objectAtIndex:indepath.row];
                if(file.isFolder)
                {
                    [self deleteDirectory:file];
                }
                else
                {
                    [[NSFileManager defaultManager] removeItemAtPath:file.fileFullPath error:nil];
                    [self removeFavouriteFiles:file];
                    [self removeLockedFileWithObject:file];
                  }
            }
            [[DatasourceSingltonClass sharedInstance].sharedDataSource removeObjectsAtIndexes:indicesOfItemsToDelete];
            // Tell the tableView that we deleted the objects
             [self.otlTableView deleteRowsAtIndexPaths:selectedArr withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [_otl_MultipleDelButton setTitle:@"Edit" forState:UIControlStateNormal];
            _otl_CancelMultipleSelection.hidden=YES;
             isEditing=NO;
            
            NSManagedObjectContext *context=[self managedObjectContext];
            NSFetchRequest *req=[[NSFetchRequest alloc]init];
            NSEntityDescription *e=[NSEntityDescription entityForName:@"PasswordFiles" inManagedObjectContext:context];
            [req setEntity:e];
            _arrOfFetchedfile=[context executeFetchRequest:req error:nil];
            
           // [self dataFetchMethod];
            [otlTableView reloadData];
            
            [HUD1 hide:YES];
        }
        else
        {
            MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.delegate=self;
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = @"No Selection";
            HUD.detailsLabelText=@"Please select atleast one file";
            [HUD hide:YES afterDelay:1];
        }
    }
}

- (IBAction)onClickCancelMultipleSelection:(id)sender
{
    self.otl_CancelMultipleSelection.hidden=YES;
    [self.otl_MultipleDelButton setTitle:@"Edit" forState:UIControlStateNormal];
    isEditing=NO;
    [otlTableView reloadData];
}

#pragma mark- EditButtonAction

- (IBAction)onClickEditMode:(id)sender
{
    if([otl_EditButton.titleLabel.text isEqual:@"Edit"])
    {
        [DatasourceSingltonClass sharedInstance].collectionViewEditFlag=1;
        [otl_EditButton setTitle:@"Done" forState:UIControlStateNormal];
        [[DatasourceSingltonClass sharedInstance].collectionViewObj.editButton setTitle:@"Done" forState:UIControlStateNormal];
        [[DatasourceSingltonClass sharedInstance].collectionViewObj.collectionViewFlowlayoutDragDrop setEditOnoff:NO];
        [[DatasourceSingltonClass sharedInstance].collectionViewObj.collectionView reloadData];
    }
    else
    {
        [DatasourceSingltonClass sharedInstance].collectionViewEditFlag=0;
        [otl_EditButton setTitle:@"Edit" forState:UIControlStateNormal];
        [[DatasourceSingltonClass sharedInstance].collectionViewObj.editButton setTitle:@"Edit" forState:UIControlStateNormal];
        [[DatasourceSingltonClass sharedInstance].collectionViewObj.collectionViewFlowlayoutDragDrop setEditOnoff:YES];
        [[DatasourceSingltonClass sharedInstance].collectionViewObj.collectionView reloadData];
    }
    // [[DatasourceSingltonClass sharedInstance].collectionViewObj activateDeletionMode];
}

#pragma mark- sortButtonAction

- (IBAction)onClickSortData:(id)sender
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        
        NSString *actionSheetTitle = @"Sort"; //Action Sheet Title
        // NSString *destructiveTitle = @"Favourites"; //Action Sheet Button Titles
        NSString *other1 = @"Sort By Name";
        NSString *other2 = @"Sort By Creation Date";
        NSString *other3 = @"Sort By File Size";
        NSString *cancelTitle = @"Cancel";
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:actionSheetTitle
                                      delegate:self
                                      cancelButtonTitle:cancelTitle
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:other1, other2, other3, nil];
        actionSheet.tag=2;
        [actionSheet showInView:self.view];
        
    }
    else
    {
        IDVSortOptionsViewController *sortingVCObj=[[IDVSortOptionsViewController alloc]initWithNibName:@"IDVSortOptionsViewController" bundle:nil];
        sortingVCObj.sortingDelegateObj=self;
        
        self.
        soringPopover=[[UIPopoverController alloc] initWithContentViewController:sortingVCObj];
        soringPopover.popoverContentSize = CGSizeMake(135, 110);
        
        [soringPopover presentPopoverFromRect:otl_sortButton.bounds inView:otl_sortButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
    }
    
}
#pragma sorting class delegate methods

-(void)sortByName
{
    [self.soringPopover dismissPopoverAnimated:YES];
    NSLog(@"sortByName");
    
    NSArray *sortedArray;
    if([sortingOrderByName isEqualToString:@"ascending"])
    {
        sortedArray = [[DatasourceSingltonClass sharedInstance].sharedDataSource sortedArrayUsingComparator:^NSComparisonResult(INDDataModel *file1, INDDataModel *file2){
            
            return [file1.fileName compare:file2.fileName];
        }];
        sortingOrderByName=@"descending";
    }
    else
    {
        sortedArray = [[DatasourceSingltonClass sharedInstance].sharedDataSource sortedArrayUsingComparator:^NSComparisonResult(INDDataModel *file1, INDDataModel *file2){
            
            return [file2.fileName compare:file1.fileName];
        }];

        sortingOrderByName=@"ascending";
    }
    
     [[DatasourceSingltonClass sharedInstance].sharedDataSource removeAllObjects];
    [DatasourceSingltonClass sharedInstance].sharedDataSource= [NSMutableArray arrayWithArray:sortedArray];
  
    
    if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeList)
    [otlTableView reloadData];
    
    if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCarousel)
    {
        [self updateCoverFlowDataSource];
        [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.tableView reloadData];
        [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.carousel reloadData];
    }
    if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCollection)
    {
        [self updateCollectionDataSource];
        [[DatasourceSingltonClass sharedInstance].collectionViewObj.collectionView reloadData];
    }
    
   }
-(void)sortBySize
{
    [self.soringPopover dismissPopoverAnimated:YES];
    NSLog(@"sortBySize");
    NSArray *sortedArray = [[DatasourceSingltonClass sharedInstance].sharedDataSource sortedArrayUsingComparator:^NSComparisonResult(INDDataModel *file1, INDDataModel *file2){
        
       // return [file1.fileSize compare:file2.fileSize];
        
        if (file1.fileSize > file2.fileSize)
            return NSOrderedDescending;
        else if (file1.fileSize < file2.fileSize)
            return NSOrderedAscending;
        return NSOrderedSame;
        
   }];
    [[DatasourceSingltonClass sharedInstance].sharedDataSource removeAllObjects];
     [DatasourceSingltonClass sharedInstance].sharedDataSource= [NSMutableArray arrayWithArray:sortedArray];
    
    if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeList)
    [otlTableView reloadData];
    
    if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCarousel)
    {
        [self updateCoverFlowDataSource];
        [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.tableView reloadData];
        [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.carousel reloadData];
    }
    if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCollection)
    {
        [self updateCollectionDataSource];
        [[DatasourceSingltonClass sharedInstance].collectionViewObj.collectionView reloadData];
    }
   
    
}
-(void)sortByCreationDate
{
    [self.soringPopover dismissPopoverAnimated:YES];
    NSArray *sortedArray;
    if([sortingOrderByDate isEqualToString:@"ascending"])
    {
        sortedArray = [[DatasourceSingltonClass sharedInstance].sharedDataSource sortedArrayUsingComparator:^NSComparisonResult(INDDataModel *file1, INDDataModel *file2){
            
            return [file1.fileCreationDate compare:file2.fileCreationDate];
        }];
        sortingOrderByDate=@"descending";
    }
    else
    {
        sortedArray = [[DatasourceSingltonClass sharedInstance].sharedDataSource sortedArrayUsingComparator:^NSComparisonResult(INDDataModel *file1, INDDataModel *file2){
            
            return [file2.fileCreationDate compare:file1.fileCreationDate];
        }];
        
        sortingOrderByDate=@"ascending";
    }
    
    [[DatasourceSingltonClass sharedInstance].sharedDataSource removeAllObjects];
    [DatasourceSingltonClass sharedInstance].sharedDataSource= [NSMutableArray arrayWithArray:sortedArray];
    
    if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeList)
    [otlTableView reloadData];
    
    if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCarousel)
    {
        [self updateCoverFlowDataSource];
        [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.tableView reloadData];
        [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.carousel reloadData];
    }
    if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCollection)
    {
        [self updateCollectionDataSource];
        [[DatasourceSingltonClass sharedInstance].collectionViewObj.collectionView reloadData];
    }
}

-(void)downloadFromGivenLink:(NSString*)url
{
    _urlToload=url;
}

//-(NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//}
#pragma mark- UIActionsheet Delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if(actionSheet.tag==1)
    {
        if  ([buttonTitle isEqualToString:@"Favourites"]) {
            [self showFavourites];
        }
        /* if ([buttonTitle isEqualToString:@"Help"]) {
         [self showHelpContent];
         }
         if ([buttonTitle isEqualToString:@"Support"]) {
         [self contactUs];
         }*/
        if ([buttonTitle isEqualToString:@"Security"]) {
            [self showPasswordSection];
        }
        if ([buttonTitle isEqualToString:@"Import Media"]) {
            [self fetchMediaFiles];
        }
        if ([buttonTitle isEqualToString:@"Cancel Button"]) {
            NSLog(@"Cancel pressed --> Cancel ActionSheet");
        }
    }
    else
    {
        if  ([buttonTitle isEqualToString:@"Sort By Name"]) {
            [self sortByName];
        }
        if ([buttonTitle isEqualToString:@"Sort By Creation Date"]) {
            [self sortByCreationDate];
        }
        if ([buttonTitle isEqualToString:@"Sort By File Size"]) {
            [self sortBySize];
        }
        
        if ([buttonTitle isEqualToString:@"Cancel Button"]) {
            NSLog(@"Cancel pressed --> Cancel ActionSheet");
        }
        
    }
}

@end
