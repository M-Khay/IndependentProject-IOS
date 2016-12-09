//
//  IDVCollectionVIew.m
//  iDocViewer
//  Created by Kush on 04/10/16.

#import "IDVCollectionVIew.h"
#import "INDDataModel.h"

@implementation IDVCollectionVIew
@synthesize currentPath,collectionView,collectionViewDataSource;
@synthesize imgString,isNotCalledFirstTime,pathForCurrentFile,directoryPathInDidSelect;
@synthesize navController;
@synthesize idvCollectionViewDelegate;
@synthesize deleteIndex;
@synthesize isDeletionModeActive;
@synthesize arrOfFetchedLockedfiles;
@synthesize collectionViewFlowlayoutDragDrop;
@synthesize editButton;
@synthesize arrOfFetchedFavouritefiles;
@synthesize formatter;
@synthesize thumbnailArray;
//@synthesize arrOfFavFiles;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
         collectionViewDataSource=[[NSMutableArray alloc]init];
        [DatasourceSingltonClass sharedInstance].collectionViewEditFlag=0;
    }
    return self;
}

-(void)initialization
{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    collectionView.dataSource=self;
    collectionView.delegate=self;


    editButton = [[UIButton alloc] init];// initWithFrame: buttonFrame];
    [self addSubview:editButton];
    
    self.collectionViewFlowlayoutDragDrop = [[BIDragDropCollectionViewFlowLayout alloc] init];
    self.collectionViewFlowlayoutDragDrop.delegate = self;
    self.collectionViewFlowlayoutDragDrop.dataSource = self;
    
    CGPoint originalContentOffset = self.collectionView.contentOffset;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
    if ([[UIScreen mainScreen] bounds].size.height > 567.0f)
        {
            [self.collectionViewFlowlayoutDragDrop setItemSize:CGSizeMake(106, 129)];
            [self.collectionViewFlowlayoutDragDrop setScrollDirection:UICollectionViewScrollDirectionVertical];
            self.collectionViewFlowlayoutDragDrop.sectionInset = UIEdgeInsetsMake(0.0, 30, 20, 40);
            self.collectionViewFlowlayoutDragDrop.minimumInteritemSpacing=30;
            self.collectionViewFlowlayoutDragDrop.minimumLineSpacing=30;
        }
        else
        {
            [self.collectionViewFlowlayoutDragDrop setItemSize:CGSizeMake(106, 129)];
            [self.collectionViewFlowlayoutDragDrop setScrollDirection:UICollectionViewScrollDirectionVertical];
            self.collectionViewFlowlayoutDragDrop.sectionInset = UIEdgeInsetsMake(05,20, 20, 20);
            self.collectionViewFlowlayoutDragDrop.minimumInteritemSpacing=30;
            self.collectionViewFlowlayoutDragDrop.minimumLineSpacing=30;
        }
    }
    else
    {
        [self.collectionViewFlowlayoutDragDrop setItemSize:CGSizeMake(140, 190)];
        [self.collectionViewFlowlayoutDragDrop setScrollDirection:UICollectionViewScrollDirectionVertical];
        self.collectionViewFlowlayoutDragDrop.minimumInteritemSpacing=50;
        self.collectionViewFlowlayoutDragDrop.minimumLineSpacing=50;
    }
   
    collectionView=[[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:self.collectionViewFlowlayoutDragDrop ];
    self.collectionView.contentOffset = originalContentOffset;
    self.backgroundColor=[UIColor clearColor];
    collectionView.bounces=YES;
    [self addSubview:collectionView];
    collectionView.delegate=self;
    collectionView.dataSource=self;
    collectionView.scrollEnabled=YES;
    self.collectionView.backgroundColor=[UIColor clearColor];
    [self.collectionView setAllowsSelection:YES];
    
    UINib *cellNib;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        cellNib = [UINib nibWithNibName:@"IDVCollectionVIewCustomCell_iPhone" bundle:nil];
    }
    else
    {
       cellNib = [UINib nibWithNibName:@"IDVCollectionVIewCustomCell" bundle:nil];
    }
    
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"cell"];

    if([DatasourceSingltonClass sharedInstance].viewControllerTag==1)
    {
        [collectionViewDataSource removeAllObjects];
        self.currentPath= [DatasourceSingltonClass sharedInstance].CommonDirectoryPath;
        collectionViewDataSource=[DatasourceSingltonClass sharedInstance].sharedDataSource;
        [self.collectionViewFlowlayoutDragDrop setEditOnoff:NO];//method call for dragging and dropping...
    }
    else
    {
        [collectionViewDataSource removeAllObjects];
        self.currentPath= [DatasourceSingltonClass sharedInstance].FavCommonDirectoryPath;
        collectionViewDataSource=[DatasourceSingltonClass sharedInstance].favSharedDataSource;
        [self.collectionViewFlowlayoutDragDrop setEditOnoff:NO];//method call for dragging and dropping...
    }
    
     editButton.hidden=YES;
    [collectionView reloadData];
    [self  changeOrientation];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    if([DatasourceSingltonClass sharedInstance].viewControllerTag==1)
    {
        NSString *thumbnailFilePaths=[[documentsPath stringByAppendingPathComponent:@"iDocDir/thumbnails"] stringByAppendingPathComponent:[currentPath lastPathComponent]];
        thumbnailArray = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath: thumbnailFilePaths] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    }
    else
    {
      //  NSString *favThumbnailFilePaths=[documentsPath stringByAppendingPathComponent:@"iDocDir/favouriteFileThumbnails"];
        
       // thumbnailArray = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath: favThumbnailFilePaths] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    }
}

#pragma mark - gesture-recognition action methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint touchPoint = [touch locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
    if (indexPath && [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        return NO;
    }
    return YES;
}


- (void)activateDeletionMode
{
    
    if([editButton.titleLabel.text isEqual:@"Edit"])
    {
        [DatasourceSingltonClass sharedInstance].collectionViewEditFlag=1;
       // [editButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.collectionViewFlowlayoutDragDrop setEditOnoff:NO];
        [collectionView reloadData];
    }
    else
    {
        [DatasourceSingltonClass sharedInstance].collectionViewEditFlag=0;
        //[editButton setTitle:@"Edit" forState:UIControlStateNormal];
        [self.collectionViewFlowlayoutDragDrop setEditOnoff:YES];
        [collectionView reloadData];
    }
}

#pragma mark-delete button action
- (void)deleteButtonAction:(UIButton *)sender
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:(IDVCollectionVIewCustomCell *)sender.superview];

    deleteIndex=(int)indexPath.row;
    UIAlertView *confirmDelete=[[UIAlertView alloc] initWithTitle:@"iDocViewer" message:@"Do you want to delete this file?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    confirmDelete.tag=2;
    [confirmDelete show];
}

-(void)changeOrientation
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
        {
            
            if ([[UIScreen mainScreen] bounds].size.height > 567.0f)
            {
                self.frame=CGRectMake(0.0,25,320,543);
                collectionView.frame=CGRectMake(0,0,320,485);
            }
            else
            {
                self.frame=CGRectMake(0.0,25,320,450);
                collectionView.frame=CGRectMake(0,0,320,395);
            }
        }
        else
        {
            if ([[UIScreen mainScreen] bounds].size.height > 567.0f)
            {
            self.frame=CGRectMake(0.0,25,543,290);
            collectionView.frame=CGRectMake(0,0,570,255);
            }
            else
            {
                self.frame=CGRectMake(0.0,25,480,290);
                collectionView.frame=CGRectMake(0,0,480,245);
            }
        }
    }
    else
    {
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
        {
            self.frame=CGRectMake(01,33, 764,1000);
            collectionView.frame=CGRectMake(0, 0, 768, 920);
        }
        else
        {
            self.frame=CGRectMake(01,33, 1020,700);
            collectionView.frame=CGRectMake(0, 0, 1024, 665);
        }
    }
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self changeOrientation];
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return  collectionViewDataSource.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)CollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    
    IDVCollectionVIewCustomCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
  //  pathForCurrentFile =[collectionViewDataSource objectAtIndex:indexPath.row];
    if(collectionViewDataSource.count>indexPath.row)
    {
        cell.layer.shouldRasterize = YES;
        cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        [cell.deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.deleteButton.hidden = ([DatasourceSingltonClass sharedInstance].collectionViewEditFlag == 0);
        
        cell.delegate=self;
        cell.collectionViewCellDelegate=self;

        
        INDDataModel *file=[collectionViewDataSource objectAtIndex:indexPath.row];
        
        pathForCurrentFile=file.fileFullPath;
        cell.otl_BtnFavourite.hidden = ([DatasourceSingltonClass sharedInstance].viewControllerTag == 2);
        
        [self setIconImageWithPath:pathForCurrentFile];
        BOOL isDirectory;
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathForCurrentFile isDirectory:&isDirectory] && isDirectory)
        {
            imgString=@"folder";
        }
        cell.otl_CreationDate.text=[formatter stringFromDate:file.fileCreationDate];
        
        cell.otl_ImageView.contentMode=UIViewContentModeScaleAspectFit;
        
        if([[[pathForCurrentFile pathExtension] lowercaseString] isEqualToString:@"png"]||[[[pathForCurrentFile pathExtension] lowercaseString] isEqualToString:@"jpeg"]||[[[pathForCurrentFile pathExtension] lowercaseString] isEqualToString:@"jpg"])
        {
            UIImage *image=nil;
            // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
           /* if([DatasourceSingltonClass sharedInstance].viewControllerTag==1)
            {
                
                for(  NSString *imgFile in thumbnailArray)
                {
                    if([[imgFile lastPathComponent] isEqualToString:[pathForCurrentFile lastPathComponent]])
                    {
                        // NSData *pngData = [NSData dataWithContentsOfFile:file.fileThumbnailPath];
                        NSData *pngData = [NSData dataWithContentsOfFile:imgFile];
                        image = [UIImage imageWithData:pngData];
                        
                        //   dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        // CustomCell *cell = (IDVCollectionVIewCustomCell *)[otlTableView cellForRowAtIndexPath:indexPath];
                        // if (cell)
                        // {
                        cell.otl_ImageView.image=image;
                        // }
                        //   });
                        break;
                    }
                }
                
                // });
 
            }
            else
            {
                NSData *pngData = [NSData dataWithContentsOfFile:file.fileThumbnailPath];
                image = [UIImage imageWithData:pngData];
                cell.otl_ImageView.image=image;
            } */
            NSData *pngData = [NSData dataWithContentsOfFile:file.fileThumbnailPath];
            image = [UIImage imageWithData:pngData];
            cell.otl_ImageView.image=image;
        }
        else
        {
            cell.otl_ImageView.image = [UIImage imageNamed:imgString];
        }
        
        cell.otl_LblFileName.text=file.fileName;
        cell.otl_LblSize.text=[self countFileSizeForCell:cell file:file];
        cell.otl_BtnFavourite.tag=indexPath.row;
        cell.otl_BtnShare.tag=indexPath.row;
        cell.path=file.fileFullPath;
        cell.file=file;
        cell.backgroundColor=[UIColor clearColor];
        
        UIImage* lockImage=[UIImage imageNamed: @"passwordLock.png"];
        cell.otl_imageLock.hidden=YES;
        
        if(file.isLocked)
        {
            cell.otl_imageLock.hidden=NO;
            cell.otl_imageLock.image=lockImage;
        }
        else
        {
            
        }
        if(file.isFavourite)
        {
            cell.otl_BtnFavourite.selected=YES;
        }
        else
        {
            cell.otl_BtnFavourite.selected=NO;
        }
        
        cell.otl_ImageView.layer.cornerRadius = 5;
        cell.otl_stripView.layer.cornerRadius=5;
        
    }
    return cell;
}

-(NSString*)countFileSizeForCell:(IDVCollectionVIewCustomCell*)cell file:(INDDataModel*)file
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

-(void)setIconImageWithPath:(NSString*)iconPath
{
    
    if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"xls"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"xlsx"])
    {
        imgString=@"excel";
    }
    else if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"doc"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"docx"])
    {
        imgString=@"doc";
    }
    else if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"ppt"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"pptx"])
    {
        imgString=@"ppt";
    }
    else if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"mov"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"mp4"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"m4v"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"mpv"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"3gp"])
    {
        imgString=@"Grid_Video";
    }
    else if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"mp3"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"m4p"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"wav"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"caf"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"m4a"])
    {
        imgString=@"audio";
    }
    else if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"png"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"jpeg"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"jpg"])
    {
        imgString=@"image";
    }
    
    else if([[[iconPath pathExtension] lowercaseString]  isEqualToString:@"pdf"])
    {
        imgString=@"pdf";
    }
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"json"])
    {
        imgString=@"json";
    }
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"xml"])
    {
        imgString=@"xml";
    }
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"zip"])
    {
        imgString=@"zip";
    }
    
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"html"]||
             [[[iconPath pathExtension] lowercaseString] isEqualToString:@"htm"]||
             [[[iconPath pathExtension] lowercaseString] isEqualToString:@"htmls"]||
             [[[iconPath pathExtension] lowercaseString] isEqualToString:@"htt"]||
             [[[iconPath pathExtension] lowercaseString] isEqualToString:@"htx"])
    {
        imgString=@"html";
    }
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"txt"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"text"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"rtf"])
    {
        imgString=@"text";
    }
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"plist"])
    {
        imgString=@"plist";
    }
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"ipa"])
    {
        imgString=@"ipa";
    }
    
    else
        imgString=@"other";
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([DatasourceSingltonClass sharedInstance].collectionViewEditFlag==0)
    [idvCollectionViewDelegate collectionViewDidSelectAtindexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (isDeletionModeActive) return NO;
    else return YES;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

-(void)saveFavouriteFilesAtPath:(INDDataModel *)file
{
      [self.idvCollectionViewDelegate saveFavouriteFiles:file];
}

-(void)removeFavouriteFilesAtPath:(INDDataModel*)file
{
       [self.idvCollectionViewDelegate removeFavouriteFiles:file];
}

-(void)shareFileAtPath:(INDDataModel *)file
{
   
[self.idvCollectionViewDelegate shareFileWithObject:file];
    
}

# pragma mark
#pragma mark- AlertView Methods..

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==2)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"OK"])
        {
            [self.idvCollectionViewDelegate deleteFileAtIndex:deleteIndex];
        }
    }
}

#pragma mark - spring board layout delegate
- (BOOL) isDeletionModeActiveForCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
{
    return isDeletionModeActive;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}

#pragma mark - ################################################ BIDragDropCollectionViewDataSource methods ################################################

- (void)BIcollectionView:(UICollectionView *)aCollectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    NSString *itemToMoveFromPath ;
    NSString *itemToMoveToPath ;
  //  NSString *filePathToDestinationFile;
 //   NSString *filePathToMovingFile;
   
  /*  BOOL isDIR;
    NSError *error;
    NSURL *directoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *rootPath = [[directoryURL path] stringByAppendingPathComponent:@"iDocDir/favourites"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[DatasourceSingltonClass sharedInstance].FavCommonDirectoryPath isDirectory:&isDIR]&&isDIR ) {
        
        NSURL *favRootPath = [NSURL fileURLWithPath:rootPath];

        NSArray *dirContent = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:favRootPath
                                                            includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                               options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                 error:&error];
        
        for (NSURL *pathurl in dirContent) {
            
            NSURL *url = [pathurl URLByResolvingSymlinksInPath];    //This will remove private path component from path in iOS Device.
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDIR]&&isDIR)
            {
                filePathToMovingFile=[url path];
            }
            else
            {
                NSMutableDictionary *favObj = [NSKeyedUnarchiver unarchiveObjectWithFile:[url path] ];
                
                filePathToMovingFile =[favObj objectForKey:@"filePath"];
                
            }
            if ([filePathToMovingFile isEqualToString:[self.collectionViewDataSource objectAtIndex:fromIndexPath.row]])
            {
                itemToMoveFromPath=[url path];
                break;
            }
        }
        
        for (NSURL *pathurl in dirContent) {
            
            NSURL *url = [pathurl URLByResolvingSymlinksInPath];    //This will remove private path component from path in iOS Device.
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDIR]&&isDIR)
            {
                filePathToDestinationFile=[url path];
            }
            else
            {
                NSMutableDictionary *favObj = [NSKeyedUnarchiver unarchiveObjectWithFile:[url path] ];
                
                filePathToDestinationFile =[favObj objectForKey:@"filePath"];
            }
            
            if ([filePathToDestinationFile isEqualToString:[self.collectionViewDataSource objectAtIndex:toIndexPath.row]])
            {
                itemToMoveToPath=[url path];
                break;
            }
        }

    }
    
    //"performAction cut paste");
    
    if ([itemToMoveFromPath isEqualToString:itemToMoveToPath])
    {
        
        NSString *foldername = [itemToMoveToPath lastPathComponent];
        NSString *message = [NSString stringWithFormat:@"You can’t paste “%@” at this location because you can’t paste an item into itself.",foldername];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"iDocViewer" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        if ([itemToMoveToPath isEqualToString:[itemToMoveFromPath stringByDeletingLastPathComponent]])
        {
            return;
        }
        
        NSError *error = nil;
       
        NSMutableDictionary *favouriteEntry=[[NSMutableDictionary alloc]init];
        [favouriteEntry setObject:filePathToMovingFile forKey:@"filePath"];

        
        if ([[DatasourceSingltonClass sharedInstance].FavCommonDirectoryPath isEqualToString:rootPath])
        {
            NSArray *pathSplitWords = [filePathToMovingFile componentsSeparatedByString:@"/"];
            if([pathSplitWords containsObject:@"favourites"])
            {
                [[NSFileManager defaultManager] moveItemAtPath:filePathToMovingFile toPath:[filePathToDestinationFile stringByAppendingPathComponent:[filePathToMovingFile lastPathComponent]] error:&error];
            }
            else
            {
             [NSKeyedArchiver archiveRootObject:favouriteEntry toFile:[filePathToDestinationFile stringByAppendingPathComponent:[filePathToMovingFile lastPathComponent]]];
                
            [[NSFileManager defaultManager] removeItemAtPath:itemToMoveFromPath error:&error];
            }
        }
        
        if (error) {
            
            NSLog(@"Error while pasting : %@",[error description]);
        }
        else {
            
            [self.collectionViewDataSource removeObjectAtIndex:fromIndexPath.row];
            
            [DatasourceSingltonClass sharedInstance].favSharedDataSource=[self.collectionViewDataSource mutableCopy];
            [self.idvCollectionViewDelegate updateCollectionDataSource];
        }
    } */
    
    
    
    //@@@
    INDDataModel *fileToMove=[[DatasourceSingltonClass sharedInstance].favSharedDataSource objectAtIndex:toIndexPath.row];
    INDDataModel *destinationFile=[[DatasourceSingltonClass sharedInstance].favSharedDataSource objectAtIndex:fromIndexPath.row];
    itemToMoveFromPath=destinationFile.fileFullPath;
    itemToMoveToPath=fileToMove.fileFullPath;
    NSError *error;
    
       [[NSFileManager defaultManager] moveItemAtPath:itemToMoveFromPath toPath:[itemToMoveToPath stringByAppendingPathComponent:[itemToMoveFromPath lastPathComponent]] error:&error];
   
    if (error) {
        
        NSLog(@"Error while pasting : %@",[error description]);
    }
    else {
        
        [self.collectionViewDataSource removeObjectAtIndex:fromIndexPath.row];
        
        [DatasourceSingltonClass sharedInstance].favSharedDataSource=[self.collectionViewDataSource mutableCopy];
        [self.idvCollectionViewDelegate updateCollectionDataSource];
    }

    //@@@
}

- (void)BIcollectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    NSLog(@"BI collectionView didMoveToIndexPath");
    
   
    [self getFavouriteDataSource];
  
   [DatasourceSingltonClass sharedInstance].favSharedDataSource=[self.collectionViewDataSource mutableCopy];
    

    [[DatasourceSingltonClass sharedInstance].favSharedDataSource removeAllObjects];
    [DatasourceSingltonClass sharedInstance].favSharedDataSource=[collectionViewDataSource mutableCopy];

    [self.collectionView performBatchUpdates:^() {
        [self.collectionView reloadData];
    } completion:^(BOOL finished) {
      // TODO: Whatever it is you want to do now that you know the contentSize.
    }];
    // [self.collectionView reloadData];
}

- (BOOL)BIcollectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"BI canMoveItemAtIndexPath");
    
    return YES;
}

- (BOOL)BIcollectionView:(UICollectionView *)aCollectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    INDDataModel *fileToMove=[self.collectionViewDataSource objectAtIndex:fromIndexPath.row];
    INDDataModel *destinationFile=[self.collectionViewDataSource objectAtIndex:toIndexPath.row];
    NSString *fromPath=fileToMove.fileFullPath;
    NSString *toPath=destinationFile.fileFullPath;
    if ([fromPath isEqualToString:toPath])
        return NO;
    else
    {
        if(destinationFile.isFolder)
            return YES;
            else
            return NO;
    }
    
   
 }

#pragma mark - ################################################ BIDragDropCollectionViewDelegateFlowLayout methods ################################################

- (void)BIcollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"BI will begin drag");
    
}

- (void)BIcollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"BI did begin drag");
}

- (void)BIcollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"BI will end drag");
}

- (void)BIcollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"BI did end drag");
    
    [self.collectionView reloadData];
    [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
    
}

-(void)removeOrderObject:(NSString*)obj AtOrderFilePath:(NSString*)path
{
    NSString *orderFileName = @".order";
    
    NSString *orderFilePath = [path stringByAppendingPathComponent:orderFileName];
    
    if ( [[NSFileManager defaultManager] fileExistsAtPath:orderFilePath] )
    {
        NSMutableArray*orderArray = [NSKeyedUnarchiver unarchiveObjectWithFile:orderFilePath];
        
        if ( [orderArray containsObject:obj] ) {
            
            [orderArray removeObject:obj];
            
            if ( [orderArray count] != 0 )
            {
                NSError *error = nil;
                
                if ( [[NSFileManager defaultManager] removeItemAtPath:orderFilePath error:&error] )
                {
                    if (!error)
                    {
                        [NSKeyedArchiver archiveRootObject:orderArray toFile:orderFilePath];
                    }
                }
            }
            else
            {
                [[NSFileManager defaultManager] removeItemAtPath:orderFilePath error:nil];
            }
        }
    }
}

-(void) getFavouriteDataSource
{
    NSLog(@"self.currentPath=%@",self.currentPath);
    BOOL isDIR;
    NSError *error;
    [self.collectionViewDataSource removeAllObjects];
    NSURL *directoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *rootPath = [[directoryURL path] stringByAppendingPathComponent:@"iDocDir/favourites"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.currentPath isDirectory:&isDIR]&&isDIR)
    {
        
        NSURL *favRootPath = [NSURL fileURLWithPath:rootPath];
        NSArray *dirContent = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:favRootPath
                                                            includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                               options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                 error:&error];
        NSLog(@"error=%@",error);
        NSString *filePathForDocumentDir;
        for (NSURL *pathurl in dirContent) {
            
            NSURL *url = [pathurl URLByResolvingSymlinksInPath];    //This will remove private path component from path in iOS Device.
            
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDIR]&&isDIR)
            {
                filePathForDocumentDir=[url path];
            }
            else
            {
                NSMutableDictionary *favObj = [NSKeyedUnarchiver unarchiveObjectWithFile:[url path] ];
                
                filePathForDocumentDir =[favObj objectForKey:@"filePath"];
            }
     
            if([[NSFileManager defaultManager] fileExistsAtPath:filePathForDocumentDir])
                [self.collectionViewDataSource addObject:filePathForDocumentDir];
                  }

    }

    
}


@end
