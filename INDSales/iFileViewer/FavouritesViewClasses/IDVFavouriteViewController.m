//
//  IDVFavouriteViewController.m
//  iDocViewer
//
//  Created by Krishna on 21/10/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import "IDVFavouriteViewController.h"

@interface IDVFavouriteViewController ()
{
    NSString *imgString;
    NSString *imgPath;
    NSString *favouritePathString;
    BOOL favButtonTag;
    int deleteIndex;
    UILabel *noFIleLabel;
    NSArray *_arrOfFetchedfile;
    NSArray *arrOfFetchedFavouritefiles;
    
    NSString *sortingOrderByDate;
    NSString *sortingOrderByName;
    NSString *sortingOrderBySize;
    NSDateFormatter *formatter;
    NSArray *thumbnailArray;
    NSString *thumbnailFilesPath;
    BOOL creatThumbnailImage;
    MBProgressHUD *HUD1;
    
    BOOL isEditing;
    NSMutableArray *selectedArr;
    NSIndexPath *indexPathToBeSelected;
    UITableViewCell *cellToBeSelected;
}
@property(strong,nonatomic)  NSMutableArray *filepaths;
@property(strong,nonatomic)  NSMutableArray *MutableDirectoryContents;
@property(strong,nonatomic) UIPopoverController *activityPopoverController;

@end
@class IDVWebViewController;

@implementation IDVFavouriteViewController
@synthesize otl_TableView;
@synthesize currentDirectoryPath;
@synthesize MutableDirectoryContents;
//@synthesize arrOfFavouriteFilePath;
@synthesize directoryPathForCell;
@synthesize imageViewForPreview,arrOfFileName,arrOfFileSize,currentIndex,arrOficonImage;
@synthesize longPressGesture;
@dynamic isLongPressForTableView;
@synthesize selectedindexPath;
@synthesize menuController,menuItemPaste;
@synthesize segmentedControl;
@synthesize addButton;
@synthesize isNotCalledFirstTime,viewTag;
@synthesize popoverController;
@synthesize directoryPathInDidSelect;
@synthesize favouriteVCDelegate;
@synthesize fileToShare;
@synthesize  deletingFilePath;
@synthesize deleteFileIndex;
@synthesize otl_sortButton;
@synthesize soringPopover;
@synthesize otl_EditButton;

//@synthesize indexPathInDidselect;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
   // id delegate = [[UIApplication sharedApplication] delegate];
    DatasourceSingltonClass *sharedObject=[DatasourceSingltonClass sharedInstance];

    if ([sharedObject performSelector:@selector(managedObjectContext)]) {
        context = [sharedObject managedObjectContext];
    }
    return context;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    // creatThumbnailImage=NO;
    [self.navigationController setNavigationBarHidden:NO];
   [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    if(![DatasourceSingltonClass sharedInstance].iDVFavVCFirstTime==true)
    {
    switch ([DatasourceSingltonClass sharedInstance].viewStyle)
        {
            case eFileViewerTypeList:
            {
                
                otl_TableView.hidden=NO;
                break;
            }
            case eFileViewerTypeCarousel:
            {
                otl_TableView.hidden=YES;
                break;
            }
            case eFileViewerTypeCollection:
            {
                otl_TableView.hidden=YES;
                break;
            }
        }

        HUD1 = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD1.delegate=self;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            HUD1.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
        }
        HUD1.mode = MBProgressHUDModeIndeterminate;
        HUD1.labelText = @"Loading";
        [HUD1 show:YES];
        
        creatThumbnailImage=NO;
        
            [self dataFetchMethod];
                [self displayView];
                [HUD1 hide:YES];
        
        [DatasourceSingltonClass sharedInstance].collectionViewEditFlag=0;
    }
    else
    {
        [DatasourceSingltonClass sharedInstance].iDVFavVCFirstTime=false;
        otl_EditButton.hidden=YES;
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
   //
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _otl_CancelMultipleSelection.hidden=YES;
    isEditing=NO;
    creatThumbnailImage=YES;

    switch ([DatasourceSingltonClass sharedInstance].viewStyle)
    {
        case eFileViewerTypeList:
        {
            
            otl_TableView.hidden=NO;
            break;
        }
        case eFileViewerTypeCarousel:
        {
            otl_TableView.hidden=YES;
            break;
        }
        case eFileViewerTypeCollection:
        {
            otl_TableView.hidden=YES;
            break;
        }
    }
    
    [DatasourceSingltonClass sharedInstance].iDVFavVCFirstTime=true;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
    [otl_TableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    HUD1 = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD1.delegate=self;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        HUD1.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
    }
    HUD1.mode = MBProgressHUDModeIndeterminate;
    HUD1.labelText = @"Loading";
    [HUD1 show:YES];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    
    noFIleLabel=[[UILabel alloc] init];
    noFIleLabel.text=@"No files available in the Directory";
    otl_TableView.dataSource=self;
    otl_TableView.delegate=self;
   
    
    otl_TableView.backgroundColor = [UIColor clearColor];
    otl_TableView.opaque = NO;
    otl_TableView.backgroundView = nil;
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    [self addingComoponentMethodToNavigationBar];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *thumbnailFolderPath =[documentsPath stringByAppendingPathComponent:@"iDocDir/favouriteFileThumbnails"];
    thumbnailFilesPath=[thumbnailFolderPath stringByAppendingPathComponent:[self.currentDirectoryPath lastPathComponent]];
    
    NSError *error;
    if(![[NSFileManager defaultManager] fileExistsAtPath:thumbnailFilesPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:thumbnailFilesPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [self newThread];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self backToMainThread];
            
            [self displayView];
            [HUD1 hide:YES];
            
        });
        
    });
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        addButton.tintColor=[UIColor grayColor];
        segmentedControl.tintColor = [UIColor lightGrayColor];
    }
}

-(void)newThread
{
    creatThumbnailImage=YES;
    
   NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *req1=[[NSFetchRequest alloc]init];
    [req1 setReturnsObjectsAsFaults:NO];
    NSEntityDescription *entity1=[NSEntityDescription entityForName:@"PasswordFiles" inManagedObjectContext:context];
    [req1 setEntity:entity1];
    
    NSFetchRequest *req2=[[NSFetchRequest alloc]init];
    [req2 setReturnsObjectsAsFaults:NO];
    NSEntityDescription *entity2=[NSEntityDescription entityForName:@"FavouriteFiles" inManagedObjectContext:context];
    [req2 setEntity:entity2];
    
    _arrOfFetchedfile=[[NSArray alloc]init];
    _arrOfFetchedfile=[context executeFetchRequest:req1 error:nil];
    
    arrOfFetchedFavouritefiles=[[NSArray alloc]init];
    arrOfFetchedFavouritefiles=[context executeFetchRequest:req2 error:nil];
   
    if (self.isNotCalledFirstTime==YES)
    {
      [self.navigationItem setTitle:[self.currentDirectoryPath lastPathComponent]];
    }
    else
    {
         [self.navigationItem setTitle:@"Favourites"];
      self.currentDirectoryPath=[self rootFolderPath];
    }
    [self dataFetchMethod];
  }
-(void)backToMainThread
{
    thumbnailArray = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath: thumbnailFilesPath] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    self.otl_TableView.hidden=NO;
    //[otl_TableView reloadData];
}

-(void)displayView
{
    [[DatasourceSingltonClass sharedInstance].collectionViewObj removeFromSuperview];
    [[DatasourceSingltonClass sharedInstance].coverFlowViewObj removeFromSuperview];
    [DatasourceSingltonClass sharedInstance].collectionViewObj=nil;
    [DatasourceSingltonClass sharedInstance].coverFlowViewObj =nil;
    
    [DatasourceSingltonClass sharedInstance].viewControllerTag=2;
    
    switch ([DatasourceSingltonClass sharedInstance].viewStyle)
    {
        case eFileViewerTypeList:
        {
            segmentedControl.selectedSegmentIndex = 0;
            otl_EditButton.hidden=YES;
            otl_TableView.hidden=NO;
            [[DatasourceSingltonClass sharedInstance].collectionViewObj removeFromSuperview];
            [[DatasourceSingltonClass sharedInstance].coverFlowViewObj removeFromSuperview];
            [DatasourceSingltonClass sharedInstance].collectionViewObj=nil;
            [DatasourceSingltonClass sharedInstance].coverFlowViewObj =nil;
            if(!isNotCalledFirstTime)
                _otl_MultipleDelButton.hidden=NO;
            else
                _otl_MultipleDelButton.hidden=YES;
            [otl_TableView reloadData];
            break;
        }
        case eFileViewerTypeCarousel:
        {
            segmentedControl.selectedSegmentIndex = 1;
            otl_TableView.hidden=YES;
            otl_EditButton.hidden=YES;
            
            [[DatasourceSingltonClass sharedInstance].collectionViewObj removeFromSuperview];
            [DatasourceSingltonClass sharedInstance].collectionViewObj=nil;
            [DatasourceSingltonClass sharedInstance].coverFlowViewObj=[[IDVCoverFlowVIew alloc]init];
            [DatasourceSingltonClass sharedInstance].coverFlowViewObj.idvCoverFlowViewDelegateObj=self;
            
            [DatasourceSingltonClass sharedInstance].favCommonDirectoryPath=self.currentDirectoryPath;
            [[DatasourceSingltonClass sharedInstance].coverFlowViewObj initialization];
            [self.view addSubview:[DatasourceSingltonClass sharedInstance].coverFlowViewObj];
            _otl_MultipleDelButton.hidden=YES;
            [otl_TableView reloadData];
            
            break;
        }
            
        case eFileViewerTypeCollection:
        {
            segmentedControl.selectedSegmentIndex = 2;
            otl_TableView.hidden=YES;
            otl_EditButton.hidden=NO;
            
            [[DatasourceSingltonClass sharedInstance].coverFlowViewObj removeFromSuperview];
            [DatasourceSingltonClass sharedInstance].coverFlowViewObj =nil;
            [DatasourceSingltonClass sharedInstance].favCommonDirectoryPath=self.currentDirectoryPath;
            [DatasourceSingltonClass sharedInstance].collectionViewObj=[[IDVCollectionVIew alloc]init];
            [DatasourceSingltonClass sharedInstance].collectionViewObj.idvCollectionViewDelegate=self;
            [[DatasourceSingltonClass sharedInstance].collectionViewObj initialization];
            [self.view addSubview:[DatasourceSingltonClass sharedInstance].collectionViewObj];
            _otl_MultipleDelButton.hidden=YES;
            [otl_TableView reloadData];
            
            break;
        }
    }
}

#pragma mark- generate thumbnails

- (void)saveThumbnailImage:(UIImage *)img path:(NSString*)path file:(INDDataModel*)file
{
    UIImage *originalImage = img;
    NSData *imageData = UIImageJPEGRepresentation(originalImage, 0.5);
    CGSize destinationSize = (imageData.length > 4*1024*1024) ? CGSizeMake(50.0, 50.0) : CGSizeMake(100.0, 100.0);
    UIGraphicsBeginImageContext(destinationSize);
    [originalImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *pngData = UIImageJPEGRepresentation(newImage, 1.0);
    
    NSString *pathToStoreThumbnails=nil;
    if(isNotCalledFirstTime)
    {
        pathToStoreThumbnails  =thumbnailFilesPath;
    }
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        NSString *thumbnailFolderPath =[documentsPath stringByAppendingPathComponent:@"iDocDir/favouriteFileThumbnails"];
        pathToStoreThumbnails=thumbnailFolderPath;

    }
    NSString *tempPath=[path stringByReplacingOccurrencesOfString:@"/" withString:@""];
     NSString *thumbnailPath = [pathToStoreThumbnails stringByAppendingPathComponent:tempPath]; //Add the file name
    file.fileThumbnailPath=thumbnailPath;

    [pngData writeToFile:thumbnailPath atomically:YES]; //Write the file
}

#pragma mark-addingComoponentsToNavigationBar

-(void)addingComoponentMethodToNavigationBar
{
    UIView *navigationBarView;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
      navigationBarView=[[UIView alloc] initWithFrame:CGRectMake ( 0,0, 105,40)];
    }
    else
    {
      navigationBarView =[[UIView alloc] initWithFrame:CGRectMake ( 0,0, 145,40)];
    }
    navigationBarView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleRightMargin;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navigationBarView];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
       /* NavigationBar buttons*/
       NSArray *segmentImageArray = [NSArray arrayWithObjects:
                                  [UIImage imageNamed:@"list.png"],
                                  [UIImage imageNamed:@"carousel1.png"],
                                  [UIImage imageNamed:@"grid.png"],
                                  nil];
    
    segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentImageArray];
    [segmentedControl  setContentMode:UIViewContentModeScaleToFill];
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        [segmentedControl  setWidth:25.0 forSegmentAtIndex:0];
        [segmentedControl  setWidth:25.0 forSegmentAtIndex:1];
        [segmentedControl  setWidth:25.0 forSegmentAtIndex:2];
    }
    else
    {
        [segmentedControl  setWidth:30.0 forSegmentAtIndex:0];
        [segmentedControl  setWidth:30.0 forSegmentAtIndex:1];
        [segmentedControl  setWidth:30.0 forSegmentAtIndex:2];
    }
    [segmentedControl addTarget:self
                         action:@selector(segmentControlAction:)
               forControlEvents:UIControlEventValueChanged];
    [navigationBarView addSubview:segmentedControl];

    if (!self.isNotCalledFirstTime==YES)
    {
        addButton=[[UIButton alloc]init];
        [addButton addTarget:self action:@selector(onClickAddNewFolder) forControlEvents:UIControlEventTouchUpInside];
        [addButton setImage:[UIImage imageNamed:@"addFolder.png"] forState:UIControlStateNormal];
       //*** [navigationBarView addSubview:addButton];
        
        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
           //*** segmentedControl.frame=CGRectMake(0,8.0, 75.0, 25.0);
           //*** addButton.frame = CGRectMake(90,8.0, 25.0, 25.0);
            segmentedControl.frame=CGRectMake(25,8.0, 75.0,25.0);
        }
        else
        {
            //***segmentedControl.frame=CGRectMake(15,5.0, 90.0, 30.0);
           //*** addButton.frame = CGRectMake(120,5.0, 30.0, 30.0);
            segmentedControl.frame=CGRectMake(50,5.0, 90.0, 30.0);
        }
    }
    else
    {
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            segmentedControl.frame=CGRectMake(25,8.0, 75.0,25.0);
        }
        else
        {
            segmentedControl.frame=CGRectMake(50,5.0, 90.0, 30.0);
        }
    }
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        otl_EditButton.frame=CGRectMake(55,0.0, 35.0, 28.0);
        otl_sortButton.frame=CGRectMake(10,0.0, 35.0, 28.0);
    }
    else
    {
        otl_EditButton.frame=CGRectMake(70,0.0, 46.0, 30.0);
        otl_sortButton.frame=CGRectMake(10,0.0, 46.0, 30.0);
    }
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {

            _otl_CancelMultipleSelection.frame=CGRectMake(225, 0, 45, 30);
            _otl_MultipleDelButton.frame=CGRectMake(275, 0, 40, 30);
            noFIleLabel.frame= CGRectMake(65, 200, 200, 30);
        }
        else
        {
            _otl_CancelMultipleSelection.frame=CGRectMake(624, 2, 50, 30);
            _otl_MultipleDelButton.frame=CGRectMake(706, 2, 50, 30);
            noFIleLabel.frame= CGRectMake(300, 500, 300, 30);
        }
    }
    else
    {
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            noFIleLabel.frame= CGRectMake(195, 130, 200, 30);

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
            _otl_MultipleDelButton.frame=CGRectMake(930, 2, 50, 30);
            _otl_CancelMultipleSelection.frame=CGRectMake(850, 2, 50, 30);
            noFIleLabel.frame= CGRectMake(400, 400, 300, 30);

        }
    }
 }

-(void)onClickAddNewFolder
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"New Folder" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
        av.alertViewStyle = UIAlertViewStylePlainTextInput;
        [av textFieldAtIndex:0].delegate = self;
        av.tag=30;
        [av show];
    }
    else
    {
        IDVNewFolderViewController *newFolderViewControllerObj=[[IDVNewFolderViewController alloc]initWithNibName:@"IDVNewFolderViewController" bundle:nil];
        newFolderViewControllerObj.delegate=self;
        self.popoverController= [[UIPopoverController alloc]initWithContentViewController:newFolderViewControllerObj];
        
        popoverController.popoverContentSize = CGSizeMake(230, 110);
        
        [self.popoverController presentPopoverFromRect:addButton.bounds inView:addButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
}
#pragma mark-
#pragma mark- segmentcontrle action method


- (IBAction)segmentControlAction:(id)sender
{
    [otl_EditButton setTitle:@"Edit" forState:UIControlStateNormal];
    [DatasourceSingltonClass sharedInstance].viewControllerTag=2;
    [self onClickCancelMultipleSelection:nil];

    if(segmentedControl.selectedSegmentIndex==0)
    {
        otl_EditButton.hidden=YES;
        otl_TableView.hidden=NO;
        
        [DatasourceSingltonClass sharedInstance].viewStyle=eFileViewerTypeList;
        [[DatasourceSingltonClass sharedInstance].collectionViewObj removeFromSuperview];
        [[DatasourceSingltonClass sharedInstance].coverFlowViewObj removeFromSuperview];
        [DatasourceSingltonClass sharedInstance].coverFlowViewObj.hidden=YES;
        [DatasourceSingltonClass sharedInstance].collectionViewObj.hidden=YES;
        [DatasourceSingltonClass sharedInstance].FavCommonDirectoryPath=self.currentDirectoryPath;
        self.viewTag=0;
        if(!isNotCalledFirstTime)
        _otl_MultipleDelButton.hidden=NO;
        else
        _otl_MultipleDelButton.hidden=YES;
        [otl_TableView reloadData];
    }
    if(segmentedControl.selectedSegmentIndex==1)
    {
        otl_EditButton.hidden=YES;
        otl_TableView.hidden=YES;
        [DatasourceSingltonClass sharedInstance].viewStyle=eFileViewerTypeCarousel;
        [DatasourceSingltonClass sharedInstance].coverFlowViewObj.hidden=NO;
        [[DatasourceSingltonClass sharedInstance].collectionViewObj removeFromSuperview];
        [DatasourceSingltonClass sharedInstance].collectionViewObj.hidden=YES;
        [DatasourceSingltonClass sharedInstance].coverFlowViewObj=[[IDVCoverFlowVIew alloc]init];
        [DatasourceSingltonClass sharedInstance].coverFlowViewObj.idvCoverFlowViewDelegateObj=self;
        [DatasourceSingltonClass sharedInstance].FavCommonDirectoryPath=self.currentDirectoryPath;
        [[DatasourceSingltonClass sharedInstance].coverFlowViewObj initialization];
        [self.view addSubview:[DatasourceSingltonClass sharedInstance].coverFlowViewObj];
        self.viewTag=1;
         _otl_MultipleDelButton.hidden=YES;
    }
    if(segmentedControl.selectedSegmentIndex==2)
    {
        otl_EditButton.hidden=NO;

        [DatasourceSingltonClass sharedInstance].viewStyle=eFileViewerTypeCollection;
        [[DatasourceSingltonClass sharedInstance].coverFlowViewObj removeFromSuperview];
        [DatasourceSingltonClass sharedInstance].collectionViewObj.hidden=NO;
        [DatasourceSingltonClass sharedInstance].coverFlowViewObj.hidden=YES;
        otl_TableView.hidden=YES;
        [DatasourceSingltonClass sharedInstance].collectionViewObj=[[IDVCollectionVIew alloc]init];
        [DatasourceSingltonClass sharedInstance].collectionViewObj.idvCollectionViewDelegate=self;
        [DatasourceSingltonClass sharedInstance].FavCommonDirectoryPath=self.currentDirectoryPath;
        [[DatasourceSingltonClass sharedInstance].collectionViewObj initialization];
        [self.view addSubview:[DatasourceSingltonClass sharedInstance].collectionViewObj];
        self.viewTag=2;
         _otl_MultipleDelButton.hidden=YES;
    }
}

#pragma mark- fetchData

-(void) dataFetchMethod
{
    NSError *error=nil;
    BOOL isDirectory;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *thumbnailFolderPath =[documentsPath stringByAppendingPathComponent:@"iDocDir/favouriteFileThumbnails"];
    [[DatasourceSingltonClass sharedInstance].favSharedDataSource removeAllObjects];
    if(self.isNotCalledFirstTime)
    {
        
          [DatasourceSingltonClass sharedInstance].FavCommonDirectoryPath=self.currentDirectoryPath;
        

          NSString*  filePath =self.currentDirectoryPath;
        
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[[NSURL alloc] initFileURLWithPath:filePath isDirectory:YES]
                                                       includingPropertiesForKeys:[NSArray arrayWithObject:NSURLCreationDateKey]
                                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                            error:nil];
        if(files.count>0)
        {
            [noFIleLabel removeFromSuperview];
                  
            NSMutableArray *tempDatasourceArr=[NSMutableArray arrayWithCapacity:1];
            for(NSURL *fileURL in files)
            {
                NSString *file=[[NSString alloc] initWithString:[fileURL path]];
                                NSError *error;
                // [[NSFileManager defaultManager] linkItemAtPath:file toPath:file error:&error];
                
                INDDataModel *datamodelObj=[[INDDataModel alloc]init];
                
                NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:file error: &error];
                float fileSize = [fileDictionary fileSize];
                
                datamodelObj.fileName=[file lastPathComponent];
                datamodelObj.fileCreationDate=[fileDictionary fileCreationDate];
                datamodelObj.fileFullPath=file;
                datamodelObj.fileThumbnail=nil;
                datamodelObj.isLocked=[[DatasourceSingltonClass sharedInstance].arrOfLockedFiles containsObject:datamodelObj.fileFullPath];
                datamodelObj.isFolder=([[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDirectory] && isDirectory);
                
                if (datamodelObj.isFolder)
                {
                    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath: file] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
                    
                    int count = (int)[directoryContents count];
                    datamodelObj.fileSize=count;
                    //imgString=@"folder";
                }
                else
                {
                datamodelObj.fileSize=fileSize;
                }
                
                [tempDatasourceArr addObject:datamodelObj];
                
                if(creatThumbnailImage==YES)
                {
                    if([[[file pathExtension] lowercaseString] isEqualToString:@"png"]||[[[file pathExtension] lowercaseString] isEqualToString:@"jpeg"]||[[[file pathExtension] lowercaseString] isEqualToString:@"jpg"])
                    {
                        [self saveThumbnailImage:[UIImage imageWithContentsOfFile:file] path:file file:datamodelObj];
                    }
                }
                else
                {
                    NSString *pathToStoreThumbnails=nil;
                   
                        pathToStoreThumbnails  =thumbnailFilesPath;
                        NSString *tempPath=[file stringByReplacingOccurrencesOfString:@"/" withString:@""];
                        NSString *thumbnailPath = [pathToStoreThumbnails stringByAppendingPathComponent:tempPath]; //Add the file name
                        datamodelObj.fileThumbnailPath=thumbnailPath;
                }

            }
           
            [DatasourceSingltonClass sharedInstance].favSharedDataSource =tempDatasourceArr;
        }
        
        else
        {
            [self.view addSubview:noFIleLabel];
            [[DatasourceSingltonClass sharedInstance].favSharedDataSource removeAllObjects];
        }
    }
    else
    {
       // NSLog(@"arroflockedfile=%@",[DatasourceSingltonClass sharedInstance].arrOfLockedFiles);
       // NSLog(@"favfiles=%@",[DatasourceSingltonClass sharedInstance].arrOfFavFiles);
        NSMutableArray *tempDatasourceArr=[NSMutableArray arrayWithCapacity:1];
        for (NSManagedObject *obj in arrOfFetchedFavouritefiles)
        {
            //  [[DatasourceSingltonClass sharedInstance].favSharedDataSource addObject:[obj valueForKey:@"filepath"]];
            NSString *file=[obj valueForKey:@"filepath"];
            
            INDDataModel *datamodelObj=[[INDDataModel alloc]init];
            
            NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:file error: &error];
            float fileSize = [fileDictionary fileSize];
            
            datamodelObj.fileName=[file lastPathComponent];
            datamodelObj.fileCreationDate=[fileDictionary fileCreationDate];
            datamodelObj.fileFullPath=file;
            datamodelObj.fileThumbnail=nil;
            datamodelObj.isLocked=[[DatasourceSingltonClass sharedInstance].arrOfLockedFiles containsObject:datamodelObj.fileFullPath];
            datamodelObj.isFolder=([[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDirectory] && isDirectory);
            if (datamodelObj.isFolder)
            {
                NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath: file] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
                
                int count = (int)[directoryContents count];
                datamodelObj.fileSize=count;
                //imgString=@"folder";
            }
            else
            {
                datamodelObj.fileSize=fileSize;
            }
            [tempDatasourceArr addObject:datamodelObj];
            
            if(creatThumbnailImage==YES)
            {
                if([[[datamodelObj.fileFullPath pathExtension] lowercaseString] isEqualToString:@"png"]||[[[datamodelObj.fileFullPath pathExtension] lowercaseString] isEqualToString:@"jpeg"]||[[[datamodelObj.fileFullPath pathExtension] lowercaseString] isEqualToString:@"jpg"])
                {
                    [self saveThumbnailImage:[UIImage imageWithContentsOfFile:datamodelObj.fileFullPath] path:file file:datamodelObj];
                }
            }
            else
            {
                    NSString *pathToStoreThumbnails=nil;
                
                    pathToStoreThumbnails=thumbnailFolderPath;
                    
               
                NSString *tempPath=[file stringByReplacingOccurrencesOfString:@"/" withString:@""];
                NSString *thumbnailPath = [pathToStoreThumbnails stringByAppendingPathComponent:tempPath]; //Add the file name
                datamodelObj.fileThumbnailPath=thumbnailPath;
                
            }


        }
        
       
        NSArray *reverseArr=[[tempDatasourceArr reverseObjectEnumerator] allObjects];
        [DatasourceSingltonClass sharedInstance].favSharedDataSource=[NSMutableArray arrayWithArray:reverseArr];
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
       return [DatasourceSingltonClass sharedInstance].favSharedDataSource.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"cell";
    
    IDVFavouriteCustomCell *cell = (IDVFavouriteCustomCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray* topLevelObjects;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"IDVFavouriteCustomCell_iPhone" owner:self options:nil];
        }
        else
        {
           topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"IDVFavouriteCustomCell" owner:self options:nil];
        }
        
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (IDVFavouriteCustomCell *)currentObject;
                break;
            }
        }
    }
    
    if([DatasourceSingltonClass sharedInstance].favSharedDataSource.count > indexPath.row)
    {
        //BOOL isDirectory;
        INDDataModel *file=[[DatasourceSingltonClass sharedInstance].favSharedDataSource objectAtIndex:indexPath.row];
        imgPath=file.fileFullPath;
        
        
        cell.backgroundColor=[UIColor clearColor];
        
        [self setIconImage];
        
        cell.favCustomCellDelegateObj=self;
        cell.path=imgPath;
        cell.file=file;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        cell.otl_TextFileName.text=[imgPath lastPathComponent];
        [cell.otl_ImageView setContentMode:UIViewContentModeScaleAspectFit];
        
        cell.otl_TextFileSize.text=[self countFileSizeForCell:cell file:file];
        cell.otl_TextFileCreationDate.text=[formatter stringFromDate:file.fileCreationDate];
        
        if([[[imgPath pathExtension] lowercaseString] isEqualToString:@"png"]||[[[imgPath pathExtension] lowercaseString] isEqualToString:@"jpeg"]||[[[imgPath pathExtension] lowercaseString] isEqualToString:@"jpg"])
        {
            
           /* for(  NSURL *imgFile in thumbnailArray)
            {
               // NSString *tempImgFile=[[imgFile path] stringByReplacingOccurrencesOfString:@"/" withString:@""];
               // NSString *tempImgPath=[imgPath stringByReplacingOccurrencesOfString:@"/" withString:@""];
               // if([tempImgPath isEqualToString:tempImgFile])
            if([[imgFile lastPathComponent] isEqualToString:[imgPath lastPathComponent]])
                {
                    //  NSData *pngData = [NSData dataWithContentsOfFile:imgFile];
                    NSData *pngData=   [NSData dataWithContentsOfURL:imgFile];
                    UIImage *image = [UIImage imageWithData:pngData];
                    cell.otl_ImageView.image =image;
                }
            }*/
            NSData *pngData=   [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:file.fileThumbnailPath]];
            UIImage *image = [UIImage imageWithData:pngData];
            cell.otl_ImageView.image =image;
            
        }
        else
        {
            cell.otl_ImageView.image = [UIImage imageNamed:imgString];
        }
        if(file.isFolder)
        {
            imgString=@"folder";
            cell.otl_ImageView.image = [UIImage imageNamed:imgString];
        }
        if(file.isLocked)
            cell.otl_imageLock.image=[UIImage imageNamed:@"passwordLock.png"];

        if(isEditing)
        {
            cell.otl_BtnShare.hidden=YES;
        }
        else
        {
            cell.otl_BtnShare.hidden=NO;
        }

     }
    return cell;
}

-(NSString*)countFileSizeForCell:(IDVFavouriteCustomCell*)cell file:(INDDataModel*)file
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

-(void)setIconImage
{
    if([[[imgPath pathExtension] lowercaseString] isEqualToString:@"xls"]||[[[imgPath pathExtension] lowercaseString] isEqualToString:@"xlsx"])
    {
        imgString=@"excel";
    }
    else if([[[imgPath pathExtension] lowercaseString] isEqualToString:@"doc"]||[[[imgPath pathExtension] lowercaseString] isEqualToString:@"docx"])
    {
        imgString=@"doc";
    }
    else if([[[imgPath pathExtension] lowercaseString] isEqualToString:@"ppt"]||[[[imgPath pathExtension] lowercaseString] isEqualToString:@"pptx"])
    {
        imgString=@"ppt";
    }
    else if([[[imgPath pathExtension] lowercaseString] isEqualToString:@"mov"]||[[[imgPath pathExtension] lowercaseString] isEqualToString:@"mp4"]||[[[imgPath pathExtension] lowercaseString] isEqualToString:@"m4v"]||[[[imgPath pathExtension] lowercaseString] isEqualToString:@"mpv"]||[[[imgPath pathExtension] lowercaseString] isEqualToString:@"3gp"])
    {
        imgString=@"Grid_Video";
    }
    else if([[[imgPath pathExtension] lowercaseString] isEqualToString:@"mp3"]||[[[imgPath pathExtension] lowercaseString] isEqualToString:@"m4p"]||[[[imgPath pathExtension] lowercaseString] isEqualToString:@"wav"]||[[[imgPath pathExtension] lowercaseString] isEqualToString:@"caf"]||[[[imgPath pathExtension] lowercaseString] isEqualToString:@"m4a"])
    {
        imgString=@"audio";
    }
    // Audio Files: MP3, M4P, M4A / AAC, WAV, and CAF
    // Video Files: M4V, MPV, MP4, MOV, 3GP
    
   /* else if([[[imgPath pathExtension] lowercaseString] isEqualToString:@"png"]||[[[imgPath pathExtension] lowercaseString] isEqualToString:@"jpeg"]||[[[imgPath pathExtension] lowercaseString] isEqualToString:@"jpg"])
    {
        imgString=@"image";
    }*/
    
    else if([[[imgPath pathExtension] lowercaseString]  isEqualToString:@"pdf"])
    {
        imgString=@"pdf";
    }
    else  if([[[imgPath pathExtension] lowercaseString] isEqualToString:@"json"])
    {
        imgString=@"json";
    }
    else  if([[[imgPath pathExtension] lowercaseString] isEqualToString:@"xml"])
    {
        imgString=@"xml";
    }
    
    else  if([[[imgPath pathExtension] lowercaseString] isEqualToString:@"html"]||
             [[[imgPath pathExtension] lowercaseString] isEqualToString:@"htm"]||
             [[[imgPath pathExtension] lowercaseString] isEqualToString:@"htmls"]||
             [[[imgPath pathExtension] lowercaseString] isEqualToString:@"htt"]||
             [[[imgPath pathExtension] lowercaseString] isEqualToString:@"htx"])
    {
        imgString=@"html";
    }
    else  if([[[imgPath pathExtension] lowercaseString] isEqualToString:@"txt"]||[[[imgPath pathExtension] lowercaseString] isEqualToString:@"text"]||[[[imgPath pathExtension] lowercaseString] isEqualToString:@"rtf"])
    {
        imgString=@"text";
    }
    else  if([[[imgPath pathExtension] lowercaseString] isEqualToString:@"plist"])
    {
        imgString=@"plist";
    }
    else  if([[[imgPath pathExtension] lowercaseString] isEqualToString:@"ipa"])
    {
        imgString=@"ipa";
    }
    else  if([[[imgPath pathExtension] lowercaseString] isEqualToString:@"zip"])
    {
        imgString=@"zip";
    }
    else
        imgString=@"other";
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isEditing)
    {
        UITableViewCell *c = [tableView cellForRowAtIndexPath:indexPath];
        if (c.accessoryType == UITableViewCellAccessoryCheckmark) {
            [c setAccessoryType:UITableViewCellAccessoryNone];
            [selectedArr removeObject:indexPath];
        }
        else
        {
            INDDataModel *file=[[DatasourceSingltonClass sharedInstance].sharedDataSource objectAtIndex:indexPath.row];
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

    [self commonDidSelectAtIndexPath:indexPath];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        deleteIndex=indexPath.row;
        
        UIAlertView *confirmDelete=[[UIAlertView alloc] initWithTitle:@"iDocViewer" message:@"Do you want to delete this file?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete",nil];
        [confirmDelete setTag:1];
        [confirmDelete show];
    }
}

-(NSString*)rootFolderPath
{
   // NSString*rootFolder = @"doc";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *filepath = [path stringByAppendingPathComponent:@"iDocDir/favourites"];
   // NSString *filepath = [path stringByAppendingPathComponent:@"iDocDir/doc"];

    return filepath;
}

#pragma mark-
#pragma mark-CustomCell Delegate method

-(void)shareFileWithObject:(INDDataModel*)file
{
    fileToShare=file.fileFullPath;
    
    NSError *attributesError = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileToShare error:&attributesError];
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
        
        if([[obj valueForKey:@"filepath"] isEqual:fileToShare])
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
        [alert show];
    }
    else
    {
        
    [self shareFileOnPath:fileToShare];
    }
    }
  }

-(void) shareFileOnPath:(NSString*)filePath
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
    
    UIActivityViewController *activityViewObj=[[UIActivityViewController alloc]initWithActivityItems:[NSArray arrayWithObjects:fileUrl, nil] applicationActivities:nil];
    
    [activityViewObj setExcludedActivityTypes:
     @[
       UIActivityTypeSaveToCameraRoll,
       UIActivityTypePostToWeibo,
       UIActivityTypeAssignToContact,
       UIActivityTypePostToFacebook,
       UIActivityTypePostToTwitter]];
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        [self presentViewController:activityViewObj animated:YES completion:nil];
    }
    else
    {
        _activityPopoverController= [[UIPopoverController alloc]initWithContentViewController:activityViewObj];
        
        CGRect rect = [[UIScreen mainScreen] bounds];
        
        [_activityPopoverController
         presentPopoverFromRect:rect inView:self.view
         permittedArrowDirections:0
         animated:YES];
  
    }
}

/*- (void)shareFile:(UIButton *)sender {
    
    INDDataModel *file=[[DatasourceSingltonClass sharedInstance].favSharedDataSource objectAtIndex:currentIndex];
     [self shareFileWithObject:file.fileFullPath];
} */

- (void)addToFavourite:(UIButton *)sender
{
    
}
#pragma mark- orientation methods

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.popoverController dismissPopoverAnimated:YES];
    [self. soringPopover  dismissPopoverAnimated:YES];
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            otl_EditButton.frame=CGRectMake(55,0.0, 35.0, 30.0);
            otl_sortButton.frame=CGRectMake(10,0.0, 35.0, 30.0);
            noFIleLabel.frame= CGRectMake(195, 130, 200, 30);

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
            otl_EditButton.frame=CGRectMake(55,0.0, 35.0, 30.0);
            otl_sortButton.frame=CGRectMake(10,0.0, 35.0, 30.0);
            
            _otl_CancelMultipleSelection.frame=CGRectMake(225, 0, 45, 30);
            _otl_MultipleDelButton.frame=CGRectMake(275, 0, 40, 30);
            noFIleLabel.frame= CGRectMake(65, 200, 200, 30);
        }
    }
    else
    {
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            otl_EditButton.frame=CGRectMake(70,0.0, 46.0, 30.0);
            otl_sortButton.frame=CGRectMake(10,0.0, 46.0, 30.0);
            _otl_MultipleDelButton.frame=CGRectMake(930, 2, 50, 30);
            _otl_CancelMultipleSelection.frame=CGRectMake(850, 2, 50, 30);
            noFIleLabel.frame= CGRectMake(400, 400, 300, 30);

        }
        else
        {
            otl_EditButton.frame=CGRectMake(70,0.0, 46.0, 30.0);
            otl_sortButton.frame=CGRectMake(10,0.0, 46.0, 30.0);
            _otl_MultipleDelButton.frame=CGRectMake(706, 2, 50, 30);
            _otl_CancelMultipleSelection.frame=CGRectMake(624, 2, 50, 30);
            noFIleLabel.frame= CGRectMake(300, 500, 300, 30);

        }
    }
    
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
   // [otl_TableView reloadData];
    
    }
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   // [otl_TableView reloadData];
    return YES;
}

#pragma mark-
#pragma mark- alerview delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==1)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Delete"])
        {
            [self deleteFileAtIndex:deleteIndex];
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
                [HUD hide:YES afterDelay:1];
                
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
                // [HUD removeFromSuperview];
                // HUD=nil;
                
            }
            else if([[[ NSUserDefaults standardUserDefaults ] objectForKey:@"passcode"] isEqualToString:inputText])
            {
                [self deleteFileAtPath:deletingFilePath];
                
                if([DatasourceSingltonClass sharedInstance].viewStyle ==eFileViewerTypeCarousel)
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
                [HUD hide:YES afterDelay:1];
            }
        }
    }
    
    else if (alertView.tag==30)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        NSString *fileName=[alertView textFieldAtIndex:0].text;
        if([title isEqualToString:@"Create"])
        {
            [self createNewFolderWithName:fileName];
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

#pragma mark- delete  file

-(void)deleteFileAtIndex:(int)deleteFileindex
{
    if (self.isNotCalledFirstTime==NO)
    {
        self.deleteFileIndex=deleteFileindex;
        INDDataModel *file=[[DatasourceSingltonClass sharedInstance].favSharedDataSource objectAtIndex:self.deleteFileIndex];
        
        self.deletingFilePath=file.fileFullPath;
        
        if(file.isLocked)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Passcode Protected File" message:@"Enter Passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
            [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
            [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
            [alert textFieldAtIndex:0].keyboardAppearance = UIKeyboardAppearanceLight;
            [alert setTag:28];
            [alert show];
            
        }
        else
        {
            [self deleteFileAtPath:deletingFilePath];
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
        HUD.labelText = @"Favourite folder's content cannot be deleted";
        [HUD hide:YES afterDelay:2];
  
    }
    
}

-(void)deleteFileAtPath:(NSString*)deleteFilePath
{
     NSError *error;
     NSManagedObjectContext *context=[self managedObjectContext];
    
    for (NSManagedObject *obj in arrOfFetchedFavouritefiles)
    {
        
        if([[obj valueForKey:@"filepath"] isEqual:deleteFilePath])
        {
            [context deleteObject:obj];
            
            if (![context save:&error])
            {
                NSLog(@"error");
            }
            
            break;
        }
    }
    NSFetchRequest *req2=[[NSFetchRequest alloc]init];
    NSEntityDescription *entity3=[NSEntityDescription entityForName:@"FavouriteFiles" inManagedObjectContext:context];
    [req2 setEntity:entity3];
    arrOfFetchedFavouritefiles=[context executeFetchRequest:req2 error:nil];
    INDDataModel *file=[[DatasourceSingltonClass sharedInstance].favSharedDataSource objectAtIndex:self.deleteFileIndex];
    [self removeThumbnailOfFile:file];

    [[DatasourceSingltonClass sharedInstance].favSharedDataSource removeObjectAtIndex:deleteFileIndex];
    [otl_TableView reloadData];
    
    if([DatasourceSingltonClass sharedInstance].viewStyle ==eFileViewerTypeCarousel)
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

-(void)removeThumbnailOfFile:(INDDataModel*)file
{
    if([[NSFileManager defaultManager] fileExistsAtPath:file.fileThumbnailPath])
        [[NSFileManager defaultManager] removeItemAtPath:file.fileThumbnailPath error:nil];
}

-(void)reloadOrderedData
{
    [[DatasourceSingltonClass sharedInstance].favSharedDataSource removeAllObjects];
    
    BOOL isDIR;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.currentDirectoryPath isDirectory:&isDIR]&&isDIR) {
    }
   // [self getFavouriteDataSource];
    [self dataFetchMethod];
    [self.otl_TableView reloadData];
  }

#pragma mark- adding/removing files in favourite section

/*-(void)saveFavouriteFiles:(NSString*)file
{
    [self saveFavouriteFileInFavouriteSection:file];
}

-(void)saveFavouriteFileInFavouriteSection:(NSString*)file
{
    NSString *favPath=[[[self rootFolderPath]stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"favourites" ];
    
    [[DatasourceSingltonClass sharedInstance] createFolderAtPath:favPath];
    
    NSMutableDictionary *favouriteEntry=[[NSMutableDictionary alloc]init];
    [favouriteEntry setObject:file forKey:@"filePath"];
    
    NSString* favDocPath = [favPath stringByAppendingPathComponent:[file lastPathComponent]] ;
    [NSKeyedArchiver archiveRootObject:favouriteEntry toFile:favDocPath];
    
}

-(void)removeFavouriteFiles:(INDDataModel*)file
{
    [self removeFavouriteFilesFromFavouriteSection:file];
}

-(void)removeFavouriteFilesFromFavouriteSection:(INDDataModel*)file
{
    NSURL *directoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *rootPath = [[directoryURL path] stringByAppendingPathComponent:@"iDocDir/favourites"];
    // [rootPath  stringByAppendingPathComponent:@"favourites"];
    
    BOOL isDIR;
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.currentDirectoryPath isDirectory:&isDIR]&&isDIR) {
        
        NSURL *favRootPath = [NSURL fileURLWithPath:rootPath];
        NSArray *dirContent = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:favRootPath
                                                            includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                               options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                 error:&error];
     //   NSLog(@"error=%@",error);
        
        for (NSURL *pathurl in dirContent) {
            
            NSURL *url = [pathurl URLByResolvingSymlinksInPath]; //This will remove private path component from path in iOS Device.
            //  NSString *str=[NSString strin absoluteString];
            NSString *path = [[NSString alloc] initWithString:[url path]];
            NSMutableDictionary *favObj = [NSKeyedUnarchiver unarchiveObjectWithFile:path ];
            NSString *filePathForDocumentDir =[favObj objectForKey:@"filePath"];
            
            if([filePathForDocumentDir isEqual:file.fileFullPath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:[rootPath stringByAppendingPathComponent:[path lastPathComponent]] error:&error];
                break;
            }
        }
    }

  } */


#pragma mark-
#pragma mark- newFolderDelegate
-(void)createNewFolderWithName:(NSString *)newFolderName
{
    if (![newFolderName isEqualToString:@""])
    {
        NSString *inputText = newFolderName;
        
        NSString *newFolderName = [inputText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        //"." Hidden Validation
        if ([newFolderName hasPrefix:@"."])
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"iDocViewer" message:@"Folder name can't begin with \".\". " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            
            return;
        }
        
        // "/" Charachter Validation
        NSString *searchtext = @"/";
        if ([newFolderName rangeOfString:searchtext].location != NSNotFound)
            newFolderName = [newFolderName stringByReplacingOccurrencesOfString:@"/" withString:@"\\:"];

        NSString *favPath=[[[self rootFolderPath]stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"favourites" ];
        NSString *newFolderPath = [favPath stringByAppendingPathComponent:newFolderName];

        NSURL *favRootPath=[NSURL fileURLWithPath:favPath];

        NSArray *dirContent = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:favRootPath
                                                            includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                               options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                 error:nil];
        
        BOOL fileexists =NO;
        
        for (NSURL*url in dirContent)
        {
            if ([[[url path] lastPathComponent] caseInsensitiveCompare:newFolderName]==NSOrderedSame)
                fileexists =YES;
            
            // Folder name comparision after removing scapes Validation
            //                    NSString *existingFileName = [[[url path] lastPathComponent] stringByReplacingOccurrencesOfString:@" " withString:@""];
            //                    NSString *newFolderName = [folderName stringByReplacingOccurrencesOfString:@" " withString:@""];
            //
            //                    if ( [existingFileName caseInsensitiveCompare:newFolderName] == NSOrderedSame )
            //                        fileexists = YES;
        }
        
        if ( fileexists )
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iDocViewer" message:[NSString stringWithFormat:@"The name “%@” is already taken. Please choose a different name.",newFolderName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        else{
            
        BOOL res= [[DatasourceSingltonClass sharedInstance] createFolderAtPath:newFolderPath];
          //  [self saveFavouriteFileInFavouriteSection:path];/////
           // [self.arrOfFavouriteFilePath addObject:path];
           // [otl_TableView reloadData];
            if(res)
            {
                MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                HUD.delegate = self;
                if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
                {
                    HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
                }
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = @"New folder created";
                [HUD hide:YES afterDelay:2];
               
                [self cancelNewFolderPopover];
            }
            // [self.favouriteVCDelegate updateTable];
            [self reloadOrderedData];
            [self updateCoverFlowDataSource];
            [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.tableView reloadData];
            [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.carousel reloadData];
            [self updateCollectionDataSource];
            [[DatasourceSingltonClass sharedInstance].collectionViewObj.collectionView reloadData];

        }
    }else {
        
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
        }
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"Please enter folder name.";
        [HUD hide:YES afterDelay:1];
       
    }
}

-(void)cancelNewFolderPopover
{
    [self.popoverController dismissPopoverAnimated:YES];
}

#pragma mark-
#pragma mark-commonDidSelectAtIndexPath


-(void) collectionViewDidSelectAtindexPath:(NSIndexPath*)indexPath
{
     [ self commonDidSelectAtIndexPath:indexPath];
}
-(void)coverFlowDidSelectAtindexPath:(NSIndexPath*)indexPath
{
    [ self commonDidSelectAtIndexPath:indexPath];

}
-(void)commonDidSelectAtIndexPath:(NSIndexPath*)indexPath
{
    self.indexPathInDidselect=indexPath;
    BOOL isPasswordProtected=NO;
       NSString  *directoryPath;
    INDDataModel *file=[[DatasourceSingltonClass sharedInstance].favSharedDataSource objectAtIndex:indexPath.row];
    directoryPath= file.fileFullPath;

    for (NSManagedObject *obj in _arrOfFetchedfile)
            {
                if([[obj valueForKey:@"filepath"] isEqualToString:directoryPath])
                {
                    isPasswordProtected=YES;
                    break;
                }
            }
           
    if(isPasswordProtected)
    {
        UIAlertView *fileProtectedAlert = [[UIAlertView alloc] initWithTitle:@"Passcode Protected File" message:@"Enter Passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
        [fileProtectedAlert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
        [[fileProtectedAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        [fileProtectedAlert textFieldAtIndex:0].keyboardAppearance = UIKeyboardAppearanceLight;

        [fileProtectedAlert setTag:21];
        [fileProtectedAlert show];
    }
    else
        
    {
        [self didSelectMethodAtIndexPath:indexPath];
    }

}

-(void) didSelectMethodAtIndexPath:(NSIndexPath*)indexPath
{
    BOOL isDirectory;
    NSString *directoryPath;
    INDDataModel *file=[[DatasourceSingltonClass sharedInstance].favSharedDataSource objectAtIndex:indexPath.row];
    directoryPath= file.fileFullPath;
    NSLog(@"filefulpaht=%@",file.fileFullPath);

    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDirectory] && isDirectory)
    {
        IDVFavouriteViewController *idvFavViewController;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
           idvFavViewController=[[IDVFavouriteViewController alloc]initWithNibName:@"IDVFavouriteViewController_iPhone" bundle:nil];
        }
        else
        {
            idvFavViewController=[[IDVFavouriteViewController alloc]initWithNibName:@"IDVFavouriteViewController" bundle:nil];
        }
        
        
        
        // idvFavViewController.currentDirectoryPath = [self.currentDirectoryPath stringByAppendingPathComponent:[directoryPath lastPathComponent]];
        idvFavViewController.currentDirectoryPath=directoryPath; //stringByAppendingPathComponent:[directoryPath lastPathComponent]];//[self.arrOfFavouriteFilePath objectAtIndex:indexPath.row];
        [DatasourceSingltonClass sharedInstance].FavCommonDirectoryPath=idvFavViewController.currentDirectoryPath;
        
        idvFavViewController.isNotCalledFirstTime=YES;
        
        if(self.viewTag==1)
            [DatasourceSingltonClass sharedInstance].viewStyle=eFileViewerTypeCarousel;
        
        else if(self.viewTag==2)
            [DatasourceSingltonClass sharedInstance].viewStyle=eFileViewerTypeCollection;
        
        [self.navigationController pushViewController:idvFavViewController animated:YES];
        
    }
    else
    {
        if([[[directoryPath pathExtension] lowercaseString] isEqualToString:@"xls"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"xml" ]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"doc"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"xlsx"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"docx"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"ppt"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"pptx"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"json"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"pdf"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"html"]|| [[[directoryPath pathExtension] lowercaseString] isEqualToString:@"htm"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"htmls"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"htt"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"htx"])
        {
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
            idvWebViewControllerObj.path=directoryPath;
            [self.navigationController pushViewController:idvWebViewControllerObj animated:YES];
        }
        
        else if([[[directoryPath pathExtension] lowercaseString] isEqualToString:@"png"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"jpeg"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"jpg"])
        {
            
//            IDVImageViewController *idvImageViewControllerObj=[[IDVImageViewController alloc]init];
//            idvImageViewControllerObj.selectedRowIndexNumbr=indexPath.row;
//            idvImageViewControllerObj.path=directoryPath;
//            
//            [self.navigationController pushViewController:idvImageViewControllerObj animated:YES];
            
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
            idvWebViewControllerObj.path=directoryPath;
            [self.navigationController pushViewController:idvWebViewControllerObj animated:YES];
            
        }
        
        else  if([[[directoryPath pathExtension] lowercaseString] isEqualToString:@"mov"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"mp4"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"mp3"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"m4v"]||
                 [[[directoryPath pathExtension] lowercaseString] isEqualToString:@"wav"]||
                 [[[directoryPath pathExtension] lowercaseString] isEqualToString:@"3gp"]||
                 [[[directoryPath pathExtension] lowercaseString] isEqualToString:@"mpv"]||
                 [[[directoryPath pathExtension] lowercaseString] isEqualToString:@"m4p"]||
                 [[[directoryPath pathExtension] lowercaseString] isEqualToString:@"caf"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"m4a"])
        {
            // Audio Files: MP3, M4P, M4A / AAC, WAV, and CAF
            // Video Files: M4V, MPV, MP4, MOV, 3GP
            IDVMediaPlayerViewController *idvMediaPlayerVCObj=[[IDVMediaPlayerViewController alloc]init];
            idvMediaPlayerVCObj.fileDirectoryPath=directoryPath;
             UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:idvMediaPlayerVCObj];
            [self presentViewController:navController animated:YES completion:^{
                
            }];
        }
        else if([[[directoryPath pathExtension] lowercaseString] isEqualToString:@"txt"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"text"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"rtf"]||[[[directoryPath pathExtension] lowercaseString] isEqualToString:@"plist"])
        {
            IDVTextViewController *idvTextVCObj=[[IDVTextViewController alloc]initWithNibName:@"IDVTextViewController" bundle:nil];
            idvTextVCObj.path=directoryPath;
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
            unzipHud.labelText = @"Unable to open file";
            [unzipHud hide:YES afterDelay:1];
        }
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    
  if (![parent isEqual:self.parentViewController]) {

        [DatasourceSingltonClass sharedInstance].FavCommonDirectoryPath=[self.currentDirectoryPath stringByDeletingLastPathComponent];
      self.otl_TableView.delegate=nil;
      self.otl_TableView.dataSource=nil;
      [DatasourceSingltonClass sharedInstance].coverFlowViewObj.tableView.dataSource=nil;
      [DatasourceSingltonClass sharedInstance].coverFlowViewObj.tableView.delegate=nil;
      
      if(isNotCalledFirstTime)
      {
          if([[NSFileManager defaultManager] fileExistsAtPath:thumbnailFilesPath])
          [[NSFileManager defaultManager] removeItemAtPath:thumbnailFilesPath error:nil];
      }
      else
      {
          NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
          NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
          NSString *thumbnailFolderPath =[documentsPath stringByAppendingPathComponent:@"iDocDir/favouriteFileThumbnails"];
          if([[NSFileManager defaultManager] fileExistsAtPath:thumbnailFolderPath])
          [[NSFileManager defaultManager] removeItemAtPath:thumbnailFolderPath error:nil];
      }
  }
}

#pragma mark- collectionview class delegate method
//-(void)sharefileFromCollectionviewWithFilePath:(NSString *)file
//{
//    [self shareFileWithObject:file];
//}
-(void) updateCollectionDataSource
{
    [DatasourceSingltonClass sharedInstance].collectionViewObj.collectionViewDataSource=[[DatasourceSingltonClass sharedInstance].favSharedDataSource mutableCopy];
 }
-(void) updateCoverFlowDataSource
{
    [DatasourceSingltonClass sharedInstance].coverFlowViewObj.coverFlowDataSource=[[DatasourceSingltonClass sharedInstance].favSharedDataSource mutableCopy];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.otl_TableView setEditing:NO];
}
-(void)dealloc
{
    [self.otl_TableView setEditing:NO];
}

#pragma mark - MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	// Remove HUD from screen when the HUD was hidded
	[hud removeFromSuperview];
    hud=nil;
}
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
        
        [actionSheet showInView:self.view];
        
    }
    else
    {
        
        IDVSortOptionsViewController *sortingVCObj=[[IDVSortOptionsViewController alloc]initWithNibName:@"IDVSortOptionsViewController" bundle:nil];
        sortingVCObj.sortingDelegateObj=self;
        
        self.soringPopover=[[UIPopoverController alloc] initWithContentViewController:sortingVCObj];
        soringPopover.popoverContentSize = CGSizeMake(130, 110);
        
        [soringPopover presentPopoverFromRect:otl_sortButton.bounds inView:otl_sortButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

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

}

#pragma sorting class delegate methods
-(void)sortByName
{
    [self.soringPopover dismissPopoverAnimated:YES];
    NSLog(@"sortByName");
    
    NSArray *sortedArray;
    if([sortingOrderByName isEqualToString:@"ascending"])
    {
        sortedArray = [[DatasourceSingltonClass sharedInstance].favSharedDataSource sortedArrayUsingComparator:^NSComparisonResult(INDDataModel *file1, INDDataModel *file2){
            
            return [file1.fileName compare:file2.fileName];
        }];
        sortingOrderByName=@"descending";
    }
    else
    {
        sortedArray = [[DatasourceSingltonClass sharedInstance].favSharedDataSource sortedArrayUsingComparator:^NSComparisonResult(INDDataModel *file1, INDDataModel *file2){
            
            return [file2.fileName compare:file1.fileName];
        }];
        
        sortingOrderByName=@"ascending";
    }
    
    [[DatasourceSingltonClass sharedInstance].favSharedDataSource removeAllObjects];
    [DatasourceSingltonClass sharedInstance].favSharedDataSource= [NSMutableArray arrayWithArray:sortedArray];
    
    [otl_TableView reloadData];
    [self updateCollectionDataSource];
    [self updateCoverFlowDataSource];
    [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.tableView reloadData];
    [[DatasourceSingltonClass sharedInstance].collectionViewObj.collectionView reloadData];
    
}
-(void)sortBySize
{
    [self.soringPopover dismissPopoverAnimated:YES];
    NSLog(@"sortBySize");
    
    NSArray *sortedArray;
    if([sortingOrderByDate isEqualToString:@"ascending"])
    {
       sortedArray = [[DatasourceSingltonClass sharedInstance].favSharedDataSource sortedArrayUsingComparator:^NSComparisonResult(INDDataModel *file1, INDDataModel *file2){
            
            // return [file1.fileSize compare:file2.fileSize];
            
            if (file1.fileSize > file2.fileSize)
                return NSOrderedDescending;
            else if (file1.fileSize < file2.fileSize)
                return NSOrderedAscending;
            return NSOrderedSame;
            
        }];

         sortingOrderBySize=@"descending";
    }
    else
    {
        
       sortedArray = [[DatasourceSingltonClass sharedInstance].favSharedDataSource sortedArrayUsingComparator:^NSComparisonResult(INDDataModel *file1, INDDataModel *file2){
            
            // return [file1.fileSize compare:file2.fileSize];
            
            if (file2.fileSize > file1.fileSize)
                return NSOrderedDescending;
            else if (file1.fileSize < file2.fileSize)
          return NSOrderedAscending;
            return NSOrderedSame;
            
        }];

        sortingOrderBySize=@"ascending";
    }

    [[DatasourceSingltonClass sharedInstance].favSharedDataSource removeAllObjects];
    [DatasourceSingltonClass sharedInstance].favSharedDataSource= [NSMutableArray arrayWithArray:sortedArray];
    [otl_TableView reloadData];
    [self updateCollectionDataSource];
    [self updateCoverFlowDataSource];
    [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.tableView reloadData];
    [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.carousel reloadData];
    [[DatasourceSingltonClass sharedInstance].collectionViewObj.collectionView reloadData];
}
-(void)sortByCreationDate
{
    [self.soringPopover dismissPopoverAnimated:YES];
    NSLog(@"sortByCreationDate");
    NSArray *sortedArray;
    if([sortingOrderByDate isEqualToString:@"ascending"])
    {
        sortedArray = [[DatasourceSingltonClass sharedInstance].favSharedDataSource sortedArrayUsingComparator:^NSComparisonResult(INDDataModel *file1, INDDataModel *file2){
            
            return [file1.fileCreationDate compare:file2.fileCreationDate];
        }];
        sortingOrderByDate=@"descending";
    }
    else
    {
        sortedArray = [[DatasourceSingltonClass sharedInstance].favSharedDataSource sortedArrayUsingComparator:^NSComparisonResult(INDDataModel *file1, INDDataModel *file2){
            
            return [file2.fileCreationDate compare:file1.fileCreationDate];
        }];
        
        sortingOrderByDate=@"ascending";
    }
    
    [[DatasourceSingltonClass sharedInstance].favSharedDataSource removeAllObjects];
    [DatasourceSingltonClass sharedInstance].favSharedDataSource= [NSMutableArray arrayWithArray:sortedArray];
    [otl_TableView reloadData];
    [self updateCollectionDataSource];
    [self updateCoverFlowDataSource];
    [[DatasourceSingltonClass sharedInstance].coverFlowViewObj.tableView reloadData];
    [[DatasourceSingltonClass sharedInstance].collectionViewObj.collectionView reloadData];
}

#pragma mark- UIActionsheet Delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
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
        [self.otl_TableView reloadData];
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
            
            NSError *error;
            NSManagedObjectContext *context=[self managedObjectContext];
            for(NSIndexPath *indepath in selectedArr)
            {
            INDDataModel *file=[[DatasourceSingltonClass sharedInstance].favSharedDataSource objectAtIndex:indepath.row];
                
            for (NSManagedObject *obj in arrOfFetchedFavouritefiles)
                {
                    if([[obj valueForKey:@"filepath"] isEqual:file.fileFullPath])
                    {
                        [context deleteObject:obj];
                        
                        if (![context save:&error])
                        {
                            NSLog(@"error");
                        }
                        [self removeThumbnailOfFile:file];
                        break;
                    }
                }
            }
            [[DatasourceSingltonClass sharedInstance].favSharedDataSource removeObjectsAtIndexes:indicesOfItemsToDelete];
            // Tell the tableView that we deleted the objects
            [self.otl_TableView deleteRowsAtIndexPaths:selectedArr withRowAnimation:UITableViewRowAnimationAutomatic];
            
            NSFetchRequest *req2=[[NSFetchRequest alloc]init];
            NSEntityDescription *entity3=[NSEntityDescription entityForName:@"FavouriteFiles" inManagedObjectContext:context];
            [req2 setEntity:entity3];
            arrOfFetchedFavouritefiles=[context executeFetchRequest:req2 error:nil];
            
            [_otl_MultipleDelButton setTitle:@"Edit" forState:UIControlStateNormal];
            _otl_CancelMultipleSelection.hidden=YES;
            isEditing=NO;
            
            [self dataFetchMethod];
            [otl_TableView reloadData];
            
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
    [otl_TableView reloadData];
}
@end
