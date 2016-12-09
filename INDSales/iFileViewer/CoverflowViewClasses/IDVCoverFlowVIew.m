//
//  IDVCoverFlowVIew.m
//  iDocViewer
//
//  Created by Krishna on 19/11/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import "IDVCoverFlowVIew.h"
#import "INDDataModel.h"

@implementation IDVCoverFlowVIew

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.coverFlowDataSource = [[NSMutableArray alloc]init];
        
        self.sortingOrderByDate=@"ascending";
        self.sortingOrderByName=@"ascending";
    }
    return self;
    
}

-(void)initialization
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    self.userInteractionEnabled=YES;
    //carousel
    iCarousel *carousel = [[iCarousel alloc] init];
    carousel.bounces=YES;
    carousel.scrollEnabled=YES;
    [self addSubview:carousel];
    self.carousel = carousel;
    
    _carousel.backgroundColor=[UIColor blackColor];
    _carousel.type=iCarouselTypeCoverFlow2;
    _carousel.dataSource=self;
    _carousel.delegate=self;
    self.wrap = NO;
    //// Label
    
    UILabel *otl_FilesNameLabel = [[UILabel alloc]init];
    otl_FilesNameLabel.numberOfLines = 1;
    otl_FilesNameLabel.baselineAdjustment = YES;
    otl_FilesNameLabel.adjustsFontSizeToFitWidth = YES;
    otl_FilesNameLabel.minimumScaleFactor = 10.0f/12.0f;
    otl_FilesNameLabel.clipsToBounds = YES;
    otl_FilesNameLabel.backgroundColor = [UIColor clearColor];
    otl_FilesNameLabel.textColor = [UIColor whiteColor];
    otl_FilesNameLabel.textAlignment = NSTextAlignmentCenter;
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        [otl_FilesNameLabel setFont:[UIFont systemFontOfSize:17]];
    }
    else
    {
        [otl_FilesNameLabel setFont:[UIFont systemFontOfSize:25]];
        
    }
    [self addSubview:otl_FilesNameLabel];
    self.otl_FilesNameLabel = otl_FilesNameLabel;
    
    UITableView *tableView = [[UITableView alloc]init];
    tableView.bounces=YES;
    [self addSubview:tableView];
    self.tableView = tableView;
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.scrollEnabled=YES;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    self.formatter = [[NSDateFormatter alloc] init];
    [_formatter setDateFormat:@"dd/MM/yyyy"];
    [_formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    if([DatasourceSingltonClass sharedInstance].viewControllerTag==1)
    {
        self.currentDirectoryPath= [DatasourceSingltonClass sharedInstance].CommonDirectoryPath;
        self.coverFlowDataSource=[DatasourceSingltonClass sharedInstance].sharedDataSource;
    }
    else
    {
        self.currentDirectoryPath= [DatasourceSingltonClass sharedInstance].FavCommonDirectoryPath;
        self.coverFlowDataSource=[DatasourceSingltonClass sharedInstance].favSharedDataSource;
    }
    
    // [self dataFetchMethod];
    [_carousel reloadData];
    
    [_carousel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    
    [self changeOrientation];
    
    UITapGestureRecognizer* doubleTapForTableview = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapMethodForTable:)];
    doubleTapForTableview.numberOfTapsRequired = 2;
    doubleTapForTableview.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:doubleTapForTableview];
    
    UITapGestureRecognizer* singleTapForTableview = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapMethodForTable:)];
    singleTapForTableview.numberOfTapsRequired = 1;
    singleTapForTableview.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:singleTapForTableview];
    
    _tableView.backgroundColor=[UIColor clearColor];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    
    if([DatasourceSingltonClass sharedInstance].viewControllerTag==1)
    {
        
        NSString *thumbnailFilePaths=[[documentsPath stringByAppendingPathComponent:@"iDocDir/thumbnails"] stringByAppendingPathComponent:[_currentDirectoryPath lastPathComponent]];
        self.thumbnailArray = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath: thumbnailFilePaths] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    }
    else
    {
       // NSString *favThumbnailFilePaths=[documentsPath stringByAppendingPathComponent:@"iDocDir/favouriteFileThumbnails"];
        
       // self.thumbnailArray = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath: favThumbnailFilePaths] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    }
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
-(void)setIconImageWithPath:(NSString*)iconPath
{
    
    if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"xls"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"xlsx"])
    {
        self.imgString=@"excel";
    }
    else if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"doc"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"docx"])
    {
        self.imgString=@"doc";
    }
    else if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"ppt"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"pptx"])
    {
        self.imgString=@"ppt";
    }
    else if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"mov"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"mp4"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"m4v"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"mpv"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"3gp"])
    {
        self.imgString=@"Grid_Video";
    }
    else if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"mp3"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"m4p"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"wav"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"caf"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"m4a"])
    {
        self.imgString=@"audio";
    }
    /* else if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"png"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"jpeg"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"jpg"])
     {
     imgString=@"image";
     }*/
    
    else if([[[iconPath pathExtension] lowercaseString]  isEqualToString:@"pdf"])
    {
        self.imgString=@"pdf";
    }
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"json"])
    {
        self.imgString=@"json";
    }
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"xml"])
    {
        self.imgString=@"xml";
    }
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"zip"])
    {
        self.imgString=@"zip";
    }
    
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"html"]||
             [[[iconPath pathExtension] lowercaseString] isEqualToString:@"htm"]||
             [[[iconPath pathExtension] lowercaseString] isEqualToString:@"htmls"]||
             [[[iconPath pathExtension] lowercaseString] isEqualToString:@"htt"]||
             [[[iconPath pathExtension] lowercaseString] isEqualToString:@"htx"])
    {
        self.imgString=@"html";
    }
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"txt"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"text"]||[[[iconPath pathExtension] lowercaseString] isEqualToString:@"rtf"])
    {
        self.imgString=@"text";
    }
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"plist"])
    {
        self.imgString=@"plist";
    }
    else  if([[[iconPath pathExtension] lowercaseString] isEqualToString:@"ipa"])
    {
        self.imgString=@"ipa";
    }
    
    else
        self.imgString=@"other";
    
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    
    return [self.coverFlowDataSource count];
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    //limit the number of items views loaded concurrently (for performance reasons)
    return 5;
}

- (UIView *)carousel:(iCarousel *)carouselObj viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)reusableView
{
    //  UIView *viewForLabel = nil;
    BOOL isDirectory;
    INDDataModel *file=[self.coverFlowDataSource objectAtIndex:index];
    if(_coverFlowDataSource)
    {
        // if(coverFlowDataSource.count>index)
        // {
        self.pathForCurrentFile=file.fileFullPath;
        self.currentIndex=index;
        
        if (reusableView==nil) {
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                reusableView.contentMode = UIViewContentModeScaleToFill;
                reusableView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 75.0f)];
                reusableView.backgroundColor=[UIColor clearColor];
                UIImageView *imageViewForPreview= [[UIImageView alloc] initWithFrame:CGRectMake(00,00, 100.0f, 75.0f)];
                
                imageViewForPreview.backgroundColor = [UIColor clearColor];
                imageViewForPreview.tag = 1;
                imageViewForPreview.contentMode=UIViewContentModeScaleAspectFit;
                reusableView.contentMode = UIViewContentModeScaleToFill;
                [reusableView addSubview:imageViewForPreview];
                self.imageViewForPreview = imageViewForPreview;
                _carousel.backgroundColor=[UIColor blackColor];
            }
            else
            {
                reusableView.contentMode = UIViewContentModeScaleToFill;
                reusableView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 80, 320.0f, 270.0f)];
                reusableView.backgroundColor=[UIColor clearColor];
                UIImageView *imageViewForPreview = [[UIImageView alloc] initWithFrame:CGRectMake(50,11, 240.0f, 154.0f)];
                
                imageViewForPreview.backgroundColor = [UIColor clearColor];
                imageViewForPreview.tag = 1;
                imageViewForPreview.contentMode=UIViewContentModeScaleAspectFit;
                reusableView.contentMode = UIViewContentModeScaleToFill;
                [reusableView addSubview:imageViewForPreview];
                self.imageViewForPreview = imageViewForPreview;
                
                _carousel.backgroundColor=[UIColor blackColor];
            }
            [self setIconImageWithPath:_pathForCurrentFile];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:_pathForCurrentFile isDirectory:&isDirectory] && isDirectory)
            {
                self.imgString=@"folder";
            }
            
            if([[[_pathForCurrentFile pathExtension] lowercaseString] isEqualToString:@"png"]||[[[_pathForCurrentFile pathExtension] lowercaseString] isEqualToString:@"jpeg"]||[[[_pathForCurrentFile pathExtension] lowercaseString] isEqualToString:@"jpg"])
            {
                UIImage *image=nil;
               /* if([DatasourceSingltonClass sharedInstance].viewControllerTag==1)
                {
                    for(  NSString *imgFile in _thumbnailArray)
                    {
                        if([[imgFile lastPathComponent] isEqualToString:[_pathForCurrentFile lastPathComponent]])
                        {
                            NSData *pngData = [NSData dataWithContentsOfFile:_pathForCurrentFile];
                            image = [UIImage imageWithData:pngData];
                            _imageViewForPreview.image=image;
                        }
                    }
                    NSData *pngData = [NSData dataWithContentsOfFile:file.fileThumbnailPath];
                    image = [UIImage imageWithData:pngData];
                    _imageViewForPreview.image=image;
                }
                else
                {
                    NSData *pngData = [NSData dataWithContentsOfFile:file.fileThumbnailPath];
                    image = [UIImage imageWithData:pngData];
                    _imageViewForPreview.image=image;
                }*/
                NSData *pngData = [NSData dataWithContentsOfFile:file.fileThumbnailPath];
                image = [UIImage imageWithData:pngData];
                _imageViewForPreview.image=image;
                
            }
            else
            {
                UIImage *imageForCarousel=[UIImage imageNamed:_imgString];
                _imageViewForPreview.image=imageForCarousel;
            }
        }
        else
        {
            self.imageViewForPreview=(UIImageView*)[reusableView viewWithTag:1];
            
            [self setIconImageWithPath:_pathForCurrentFile];
            BOOL isDirectory;
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:_pathForCurrentFile isDirectory:&isDirectory] && isDirectory)
            {
                self.imgString=@"folder";
            }
            
            if([[[_pathForCurrentFile pathExtension] lowercaseString] isEqualToString:@"png"]||[[[_pathForCurrentFile pathExtension] lowercaseString] isEqualToString:@"jpeg"]||[[[_pathForCurrentFile pathExtension] lowercaseString] isEqualToString:@"jpg"])
            {
                for(  NSString *imgFile in _thumbnailArray)
                {
                    if([[imgFile lastPathComponent] isEqualToString:[_pathForCurrentFile lastPathComponent]])
                    {
                        NSData *pngData = [NSData dataWithContentsOfFile:_pathForCurrentFile];
                        UIImage *image = [UIImage imageWithData:pngData];
                        _imageViewForPreview.image=image;
                    }
                }
            }
            else
            {
                UIImage *imageForCarousel=[UIImage imageNamed:_imgString];
                _imageViewForPreview.image=imageForCarousel;
            }
        }
    }
    
    UITapGestureRecognizer *singleTapForCarousel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapMethodForCarousel:)];
    singleTapForCarousel.numberOfTapsRequired = 1;
    singleTapForCarousel.numberOfTouchesRequired = 1;
    [reusableView addGestureRecognizer:singleTapForCarousel];
    
    UITapGestureRecognizer *doubleTapForCarousel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapMethodForCarousel:)];
    doubleTapForCarousel.numberOfTapsRequired = 2;
    doubleTapForCarousel.numberOfTouchesRequired = 1;
    [singleTapForCarousel requireGestureRecognizerToFail:doubleTapForCarousel];
    [reusableView addGestureRecognizer:doubleTapForCarousel];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_imageViewForPreview.bounds];
    _imageViewForPreview.layer.masksToBounds = NO;
    _imageViewForPreview.layer.shadowColor = [UIColor blackColor].CGColor;
    _imageViewForPreview.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
    _imageViewForPreview.layer.shadowOpacity = 0.6f;
    _imageViewForPreview.layer.shadowPath = shadowPath.CGPath;
    _imageViewForPreview.layer.cornerRadius = 10;
    
    //  }
    
    return reusableView;
    
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
	//note: placeholder views are only displayed on some carousels if wrapping is disabled
    
	return 0;
}
- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    //usually this should be slightly wider than the item views
    CGFloat width;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        width= 110;
    }
    else
    {
        width= 340;
    }
    return width;
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    //wrap all carousels
    return _wrap;
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)aCarousel
{
    // nameLabel.text=[NSString stringWithFormat:@"%@",[arrOfFileName objectAtIndex:aCarousel.currentItemIndex]];
    int index=aCarousel.currentItemIndex;
    if(_coverFlowDataSource.count>0)
    {
        INDDataModel *file=[_coverFlowDataSource objectAtIndex:index];
        _otl_FilesNameLabel.text = file.fileName;
    }
    else
        _otl_FilesNameLabel.text=@"Currently No File Available";
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:_carousel.currentItemIndex inSection:0];
    
    if ( [self.tableView numberOfSections] > 0 && [self.tableView numberOfRowsInSection:0] > 0 )
        [_tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionNone animated:YES];
    
    [_tableView selectRowAtIndexPath:ip animated:NO scrollPosition:UITableViewScrollPositionNone];
}
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    
}
- (void)carouselCurrentItemIndexUpdated:(iCarousel *)carousel1
{
    // int index=carousel1.currentItemIndex;
    // otl_FilesNameLabel.text = [NSString stringWithFormat:@"%d",index];
    // NSLog(@"otl_FilesNameLabel.text=%@",otl_FilesNameLabel.text);
}


#pragma mark-
#pragma mark-UITableView methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _coverFlowDataSource.count;
}

-(UITableViewCell*)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"cell";
    
    IDVCoverFlowTableCustomCell *cell = (IDVCoverFlowTableCustomCell *) [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        NSArray* topLevelObjects = nil;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"IDVCoverFlowTableCustomCell_iPhone" owner:self options:nil];
        }
        else
        {
            topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"IDVCoverFlowTableCustomCell" owner:self options:nil];
        }
        
        for (id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (IDVCoverFlowTableCustomCell *)currentObject;
                break;
            }
        }
    }
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(_coverFlowDataSource.count > indexPath.row)
    {
        INDDataModel *file = [_coverFlowDataSource objectAtIndex:indexPath.row];
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
            {
                
                cell.otl_LblColumn2.frame=CGRectMake(150, 6, 50, 21);
                cell.otl_LblColumn3.frame=CGRectMake(207, 6, 75, 21);
            }
            else
            {
                cell.otl_LblColumn2.frame=CGRectMake(195, 6, 50, 21);
                
                cell.otl_LblColumn3.frame=CGRectMake(328, 6, 85, 21);
            }
        }
        else
        {
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
            {
                cell.otl_LblColumn2.frame=CGRectMake(350, 11, 100, 21);
                cell.otl_LblColumn3.frame=CGRectMake(500, 11, 175, 21);
            }
            else
            {
                cell.otl_LblColumn2.frame=CGRectMake(430, 0, 100, 30);
                
                cell.otl_LblColumn3.frame=CGRectMake(699, 11, 175, 21);
            }
        }
        
        cell.otl_FavouriteBtn.hidden = ([DatasourceSingltonClass sharedInstance].viewControllerTag == 2);
        _pathForCurrentFileInTableView = file.fileFullPath;

        cell.otl_LblColumn1.text = file.fileName;
        cell.otl_LblColumn2.text = [self countFileSizeForCell: cell file:file];
        cell.otl_LblColumn3.text = [_formatter stringFromDate:file.fileCreationDate];
        cell.coverFlowCustomCellDelegate = self;
        cell.path=file.fileFullPath;
        cell.file=file;
        UIImage *lockImage= [UIImage imageNamed: @"passwordLock.png"] ;
        cell.otl_ImageViewLock.hidden=YES;
        
        if(file.isLocked)
        {
            cell.otl_ImageViewLock.hidden=NO;
            cell.otl_ImageViewLock.image=lockImage;
        }
        else{}
        
        if(file.isFavourite)
            cell.otl_FavouriteBtn.selected=YES;
        else
            cell.otl_FavouriteBtn.selected=NO;
        
    }
    return cell;
}

-(NSString*)countFileSizeForCell:(IDVCoverFlowTableCustomCell*)cell file:(INDDataModel*)file
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

- (UIView *) tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    UIView* customView;
    if(section==0)
    {
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            customView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, aTableView.bounds.size.width, 30.0)];
        }
        else
        {
            customView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, aTableView.bounds.size.width, 40.0)];
        }
        customView.backgroundColor = [UIColor lightGrayColor];
        
        UIButton *nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [nameButton setTitle:@"File Name" forState:UIControlStateNormal];
        [nameButton.titleLabel setTextAlignment: NSTextAlignmentLeft];
        [nameButton setTintColor:[UIColor whiteColor]];
        [nameButton addTarget:self
                       action:@selector(nameButtonClicked)
             forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *sizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sizeButton setTitle:@"Size" forState:UIControlStateNormal];
        [sizeButton.titleLabel setTextAlignment: NSTextAlignmentCenter];
        [sizeButton setTintColor:[UIColor whiteColor]];
        [sizeButton addTarget:self
                       action:@selector(sizeButtonClicked)
             forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *creationDateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [creationDateButton setTitle:@"Creation Date" forState:UIControlStateNormal];
        [creationDateButton.titleLabel setTextAlignment: NSTextAlignmentLeft];
        [creationDateButton setTintColor:[UIColor whiteColor]];
        [creationDateButton addTarget:self
                               action:@selector(creationDateButtonClicked)
                     forControlEvents:UIControlEventTouchUpInside];
        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            [nameButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
            [sizeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
            [creationDateButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
        }
        else
        {
            [nameButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
            [sizeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
            [creationDateButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        }
        
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
            {
                nameButton.frame=CGRectMake(0, 03, 100, 30);
                sizeButton.frame=CGRectMake(150, 03, 50, 30);
                creationDateButton.frame=CGRectMake(205, 03, 90, 30);
                
            }
            else
            {
                nameButton.frame=CGRectMake(0, 03, 100, 30);
                sizeButton.frame=CGRectMake(195, 03, 50, 30);
                creationDateButton.frame=CGRectMake(320, 03, 100, 30);
            }
        }
        else
        {
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
            {
                nameButton.frame=CGRectMake(0, 05, 150, 30);
                sizeButton.frame=CGRectMake(350, 05, 100, 30);
                creationDateButton.frame=CGRectMake(500, 05, 175, 30);
            }
            else
            {
                nameButton.frame=CGRectMake(0, 05, 150, 30);
                sizeButton.frame=CGRectMake(430, 05, 100, 30);
                creationDateButton.frame=CGRectMake(699, 05, 175, 30);
            }
        }
        
        [customView addSubview:nameButton];
        [customView addSubview:sizeButton];
        [customView addSubview:creationDateButton];
    }
    
    return customView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        return 30.0;
    }
    else
    {
        return 40.0;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        self.deleteIndex=indexPath.row;
        
        UIAlertView *confirmDelete=[[UIAlertView alloc] initWithTitle:@"iDocViewer" message:@"Do you want to delete the file?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
        confirmDelete.tag=2;
        [confirmDelete show];
    }
}

-(NSString*) setFileSizeInTableViewWithPath:(NSString*)path
{
    BOOL isDirectory;
    // NSString *sizeOfFile;
    NSString * fileSizeInTable;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_pathForCurrentFileInTableView isDirectory:&isDirectory] && isDirectory)
    {
        
        fileSizeInTable=@"--";
        return fileSizeInTable;
    }
    else
    {
        NSURL *fileUrl=[NSURL fileURLWithPath:_pathForCurrentFileInTableView];
        NSMutableDictionary *urlWithSize = [NSMutableDictionary dictionaryWithCapacity:_coverFlowDataSource.count];
        
        NSNumber *size;
        if ([fileUrl getResourceValue:&size forKey:NSURLFileAllocatedSizeKey error:nil])
        {
            [urlWithSize setObject:size forKey:fileUrl];
        }
        
        NSString *fileSize;
        NSInteger value;
        CGFloat newValue;
        
        value=[size floatValue];
        NSString *kbMb;
        
        if(value<(1024*1024))
        {
            kbMb=@"KB";
            newValue=(float)value/1024;
        }
        else
        {
            kbMb=@"MB";
            newValue=(float)value/(1024*1024);
        }
        CGFloat rounded_down = floorf(newValue * 100) / 100;
        fileSize=[NSString stringWithFormat:@"%.02f",rounded_down];
        NSString *sizeOfFile=[NSString stringWithFormat:@"%@ %@",fileSize,kbMb];
        return sizeOfFile;
    }
}

#pragma mark- orientation change methods

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

-(void)changeOrientation
{
    _carousel.autoresizingMask=UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleRightMargin;
    self.autoresizesSubviews=YES;
    _carousel.autoresizesSubviews=YES;
    _tableView.autoresizesSubviews=YES;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
        {
            if ([[UIScreen mainScreen] bounds].size.height > 567.0f)
            {
                self.frame=CGRectMake(0,25, 320,568);
                self.tableView.frame=CGRectMake(0,125, 320, 353);
            }
            else
            {
                self.frame=CGRectMake(0,25, 320,480);
                self.tableView.frame=CGRectMake(0,125, 320, 260);
            }
            
            _carousel.frame=CGRectMake(0,0,320, 125);
            self.otl_FilesNameLabel.frame=CGRectMake(0, 95, 320, 30);
        }
        else
        {
            if ([[UIScreen mainScreen] bounds].size.height > 567.0f)
            {
                self.frame=CGRectMake(0,25, 568, 242);
                self.tableView.frame=CGRectMake(0, 125, 568,127);
                _carousel.frame=CGRectMake(0,0,568, 125);
            }
            else
            {
                self.frame=CGRectMake(0,25, 480, 242);
                self.tableView.frame=CGRectMake(0, 125, 480, 127);
                _carousel.frame=CGRectMake(0,0,480, 125);
            }
            
            if ([[UIScreen mainScreen] bounds].size.height > 567.0f)
            {
                self.otl_FilesNameLabel.frame=CGRectMake(0, 95,568, 30);
            }
            else
            {
                self.otl_FilesNameLabel.frame=CGRectMake(0, 95,480, 30);
            }
        }
    }
    else
    {
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
        {
            self.frame=CGRectMake(0,30, 768,1050);
            
            _carousel.frame=CGRectMake(0, 0,768, 264);
            self.otl_FilesNameLabel.frame=CGRectMake(0, 215, 768, 40);
            self.tableView.frame=CGRectMake(0, 263, 768, 664);
        }
        else
        {
            self.frame=CGRectMake(0,30, 1024, 750);
            
            _carousel.frame=CGRectMake(0, 0, 1024, 264);
            self.otl_FilesNameLabel.frame=CGRectMake(0, 215, 1024, 40);
            self.tableView.frame=CGRectMake(0, 263, 1024, 408);
        }
    }
    
    //  [self.tableView reloadData];
    if([DatasourceSingltonClass sharedInstance].viewStyle == eFileViewerTypeCarousel || [DatasourceSingltonClass sharedInstance].favViewStyle== eFileViewerTypeCarousel)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
        });
    }
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self changeOrientation];
}

#pragma mark- tapGesture recognizer methods

-(void) singleTapMethodForTable:(UISwipeGestureRecognizer*)tap
{
    if (UIGestureRecognizerStateEnded == tap.state)
    {
        CGPoint p = [tap locationInView:tap.view];
        NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:p];
        INDDataModel *file=[_coverFlowDataSource objectAtIndex:indexPath.row];
        
        [self.carousel setCurrentItemIndex:indexPath.row ];
        _otl_FilesNameLabel.text = [file.fileName lastPathComponent];
        
        [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

-(void) doubleTapMethodForTable:(UISwipeGestureRecognizer*)tap
{
    if (UIGestureRecognizerStateEnded == tap.state)
    {
        CGPoint p = [tap locationInView:tap.view];
        NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:p];
        if(indexPath)
            [_idvCoverFlowViewDelegateObj coverFlowDidSelectAtindexPath:indexPath];
    }
}

-(void) singleTapMethodForCarousel:(UISwipeGestureRecognizer*)tap
{
    if (UIGestureRecognizerStateEnded == tap.state)
    {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:_carousel.currentItemIndex inSection:0];
        
        if ( [self.tableView numberOfSections] > 0 && [self.tableView numberOfRowsInSection:0] > 0 )
            [_tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}

-(void) doubleTapMethodForCarousel:(UISwipeGestureRecognizer*)tap
{
    if (UIGestureRecognizerStateEnded == tap.state)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_carousel.currentItemIndex inSection:0];
        
        [_idvCoverFlowViewDelegateObj coverFlowDidSelectAtindexPath:indexPath];
    }
}

#pragma mark- custom cell delegate method

-(void)saveFavouriteFilesAtPath:(INDDataModel *)file
{
    [self.idvCoverFlowViewDelegateObj saveFavouriteFiles:file];
}

-(void)removeFavouriteFilesAtPath:(INDDataModel*)file
{
    [self.idvCoverFlowViewDelegateObj removeFavouriteFiles:file];
}

#pragma mark- sharing file method
-(void)shareFileAtPath:(INDDataModel *)file
{
    [self.idvCoverFlowViewDelegateObj shareFileWithObject:file];
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
            [self.idvCoverFlowViewDelegateObj deleteFileAtIndex:_deleteIndex];
        }
    }
}

-(void)dealloc
{
    self.formatter = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _tableView.dataSource=nil;
    _tableView.delegate=nil;
}

#pragma mark-header button action methods
-(void) nameButtonClicked
{
    if(_coverFlowDataSource.count>0)
    {
        NSArray *sortedArray;
        if([_sortingOrderByName isEqualToString:@"ascending"])
        {
            sortedArray = [_coverFlowDataSource sortedArrayUsingComparator:^NSComparisonResult(INDDataModel *file1, INDDataModel *file2){
                
                return [file1.fileName compare:file2.fileName];
            }];
            _sortingOrderByName=@"descending";
        }
        else
        {
            sortedArray = [_coverFlowDataSource sortedArrayUsingComparator:^NSComparisonResult(INDDataModel *file1, INDDataModel *file2){
                
                return [file2.fileName compare:file1.fileName];
            }];
            
            _sortingOrderByName=@"ascending";
        }
        
        [_coverFlowDataSource removeAllObjects];
        _coverFlowDataSource= [NSMutableArray arrayWithArray:sortedArray];
        
        if([DatasourceSingltonClass sharedInstance].viewControllerTag==1)
        {
            [[DatasourceSingltonClass sharedInstance].sharedDataSource removeAllObjects];
            
            [DatasourceSingltonClass sharedInstance].sharedDataSource=[_coverFlowDataSource mutableCopy];
        }
        else
        {
            [[DatasourceSingltonClass sharedInstance].favSharedDataSource removeAllObjects];
            [DatasourceSingltonClass sharedInstance].favSharedDataSource=[_coverFlowDataSource mutableCopy];
        }
        [_carousel reloadData];
        [_tableView reloadData];
    }
    
}
-(void) sizeButtonClicked
{
    
    if(_coverFlowDataSource.count>0)
    {
        
        NSArray *sortedArray;
        if([_sortingOrderByDate isEqualToString:@"ascending"])
        {
            sortedArray = [_coverFlowDataSource sortedArrayUsingComparator:^NSComparisonResult(INDDataModel *file1, INDDataModel *file2){
                
                // return [file1.fileSize compare:file2.fileSize];
                
                if (file1.fileSize > file2.fileSize)
                    return NSOrderedDescending;
                else if (file1.fileSize < file2.fileSize)
                    return NSOrderedAscending;
                return NSOrderedSame;
                
            }];
            
            _sortingOrderBySize=@"descending";
        }
        else
        {
            sortedArray = [_coverFlowDataSource sortedArrayUsingComparator:^NSComparisonResult(INDDataModel *file1, INDDataModel *file2){
                
                // return [file1.fileSize compare:file2.fileSize];
                
                if (file2.fileSize > file1.fileSize)
                    return NSOrderedDescending;
                else if (file1.fileSize < file2.fileSize)
                    return NSOrderedAscending;
                return NSOrderedSame;
                
            }];
            
            _sortingOrderBySize=@"ascending";
        }
        
        [_coverFlowDataSource removeAllObjects];
        _coverFlowDataSource=[NSMutableArray arrayWithArray:sortedArray];
        
        if([DatasourceSingltonClass sharedInstance].viewControllerTag==1)
        {
            [[DatasourceSingltonClass sharedInstance].sharedDataSource removeAllObjects];
            [DatasourceSingltonClass sharedInstance].sharedDataSource=[_coverFlowDataSource mutableCopy];
        }
        else
        {
            [[DatasourceSingltonClass sharedInstance].favSharedDataSource removeAllObjects];
            [DatasourceSingltonClass sharedInstance].favSharedDataSource=[_coverFlowDataSource mutableCopy];
        }
        
        [_carousel reloadData];
        [_tableView reloadData];
    }
}
-(void) creationDateButtonClicked
{
    NSLog(@"creationDatebutton");
    if(_coverFlowDataSource.count>0)
    {
        NSArray *sortedArray;
        if([_sortingOrderByDate isEqualToString:@"ascending"])
        {
            sortedArray = [_coverFlowDataSource sortedArrayUsingComparator:^NSComparisonResult(INDDataModel *file1, INDDataModel *file2){
                
                return [file1.fileCreationDate compare:file2.fileCreationDate];
            }];
            _sortingOrderByDate=@"descending";
        }
        else
        {
            sortedArray = [_coverFlowDataSource sortedArrayUsingComparator:^NSComparisonResult(INDDataModel *file1, INDDataModel *file2){
                
                return [file2.fileCreationDate compare:file1.fileCreationDate];
            }];
            
            _sortingOrderByDate=@"ascending";
        }
        
        [_coverFlowDataSource removeAllObjects];
        _coverFlowDataSource=[NSMutableArray arrayWithArray:sortedArray];
        
        if([DatasourceSingltonClass sharedInstance].viewControllerTag==1)
        {
            [[DatasourceSingltonClass sharedInstance].sharedDataSource removeAllObjects];
            [DatasourceSingltonClass sharedInstance].sharedDataSource=[_coverFlowDataSource mutableCopy];
        }
        else
        {
            [[DatasourceSingltonClass sharedInstance].favSharedDataSource removeAllObjects];
            [DatasourceSingltonClass sharedInstance].favSharedDataSource=[_coverFlowDataSource mutableCopy];
        }
        [_carousel reloadData];
        [_tableView reloadData];
    }
}


@end
