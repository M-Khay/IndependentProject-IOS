//
//  INDRSSFeedsVC.m
//  INDSales
//
//  Created by Ashish on 05/02/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import "INDRSSFeedsVC.h"
#import "Feeds.h"
#import "INDRSSFeedLinkInfVC.h"

@interface INDRSSFeedsVC ()

@property (strong, nonatomic) IBOutlet UITableView *feedsTableView;
@property (strong, nonatomic) NSMutableArray * feedsDataArray;
@property (strong, nonatomic) INDMessageVC *msgVCFeedObj;
@property (strong, nonatomic) INDMessageVC *msgVCRechabilityObj;
@property(strong, nonatomic)Reachability * internetReachability;
@property(strong,nonatomic)  INDWebServiceModel*webserviceModal;


@property (strong, nonatomic) UIActivityIndicatorView *activityView;

@end

@implementation INDRSSFeedsVC
@synthesize activityView,msgVCFeedObj,msgVCRechabilityObj,internetReachability,webserviceModal;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        //Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.feedsDataArray = [[NSMutableArray alloc]init];
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView setHidesWhenStopped:YES];
    if (isiPhone5) {
        activityView.frame=CGRectMake(250, 15, 50, 50);

    }else
        activityView.frame=CGRectMake(700, 15, 50, 50);
    
    [self.navigationController.view addSubview:activityView];
    
//    if (![[APP_DELEGATE.window subviews]containsObject:activityView]) {
//        [APP_DELEGATE.window insertSubview:activityView aboveSubview:self.navigationController.view];
//    }
//    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
	[self.internetReachability startNotifier];
    [self networkStatus:[self.internetReachability currentReachabilityStatus]];

    
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(364, 105, 40, 40)];
    
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.feedsTableView addSubview:refreshControl];
    [self checkNewFeeds];
   
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"RSS Feeds";
}
- (void)viewWillDisappear:(BOOL)animated
{
    //[[INDWebservices shared] cancelOperation:webserviceModal];
  //  [activityView stopAnimating];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark- add/remove subview

-(void)addMsgForReachability:(NSString*)ConnectionMessage
{
    if(![[self.view subviews]containsObject:msgVCRechabilityObj.view])
    {
        UIStoryboard *storyboard;
        
        if (isiPhone5) {
            storyboard= [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        }else
        {
            storyboard= [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];

        }
        
        
        
        msgVCRechabilityObj = (INDMessageVC *)[storyboard instantiateViewControllerWithIdentifier:@"INDMessageVC"];
        
        
        [self addChildViewController:msgVCRechabilityObj];
        
        [UIView animateWithDuration:0.50 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.msgVCRechabilityObj.view.frame = CGRectMake(0,60,768,0);
            
            self.msgVCRechabilityObj.view.frame = CGRectMake(0,60,768,50);
            
        } completion:^(BOOL finished) {
            
            [msgVCRechabilityObj setTextToLabel:ConnectionMessage];
        }];
        
        
        [self.view addSubview:msgVCRechabilityObj.view];
        
        [msgVCRechabilityObj didMoveToParentViewController:self];
    }
}


-(void)removeMsgVCForReachability
{
       [UIView animateWithDuration:0.50 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.msgVCRechabilityObj.view.frame = CGRectMake(0,60,768,50);
            
            self.msgVCRechabilityObj.view.frame = CGRectMake(0,60,768,0);
            self.msgVCRechabilityObj.msgLabel.hidden = TRUE;
            
        } completion:^(BOOL finished) {
            
            
            [msgVCRechabilityObj.view removeFromSuperview];
            
            [msgVCRechabilityObj removeFromParentViewController];
            
        }];
        
 
    
}

-(void)addMsgVC:(NSString*)message
{
    UIStoryboard *storyboard;
    
    if (isiPhone5) {
        storyboard= [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    }else
    {
        storyboard= [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
        
    }
        msgVCFeedObj = (INDMessageVC *)[storyboard instantiateViewControllerWithIdentifier:@"INDMessageVC"];
        
        
        [self addChildViewController:msgVCFeedObj];
        
        [UIView animateWithDuration:0.50 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.msgVCFeedObj.view.frame = CGRectMake(0,60,768,0);
            
            self.msgVCFeedObj.view.frame = CGRectMake(0,60,768,50);
            
        } completion:^(BOOL finished) {
            
            [msgVCFeedObj setTextToLabel:message];
        }];
        
        
        [self.view addSubview:msgVCFeedObj.view];
        
        [msgVCFeedObj didMoveToParentViewController:self];
  
}

-(void)removeMessagVC
{
    
    NSLog(@"Remove called");
    [UIView animateWithDuration:0.50 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.msgVCFeedObj.view.frame = CGRectMake(0,60,768,50);
        self.msgVCFeedObj.view.frame = CGRectMake(0,60,768,0);
        self.msgVCFeedObj.msgLabel.hidden = TRUE;
        
    } completion:^(BOOL finished) {
        
        
        [self.msgVCFeedObj.view removeFromSuperview];
        
        [self.msgVCFeedObj removeFromParentViewController];
        
    }];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"webViewSegue"])
        
    {
        
        // Get reference to the destination view controller
        INDRSSFeedLinkInfVC *linkObj =segue.destinationViewController;
        
        // Pass any objects to the view controller here, like.
        Feeds* feed=[_feedsDataArray objectAtIndex:[_feedsTableView indexPathForSelectedRow].row];
        linkObj.feedLink=feed.link;
        [_feedsTableView deselectRowAtIndexPath:[_feedsTableView indexPathForSelectedRow] animated:YES];
        NSLog(@"feedWebLink=%@",linkObj.feedLink);
    }
}
#pragma mark - refresh tble view

-(void)refreshView:(UIRefreshControl *)refresh

{
    [refresh beginRefreshing];
    [self checkNewFeeds];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    NSLog(@"refreshing");
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [refresh endRefreshing];
    
}




#pragma mark-  Reachablity

- (void) reachabilityChanged:(NSNotification *)note
{
    [self networkStatus:[[note object] currentReachabilityStatus]];
    
}

-(void)networkStatus:(NetworkStatus)networkStatus
{
    if (!(networkStatus==NotReachable))
    {
        [self removeMsgVCForReachability];
    }
    else
    {
        [self addMsgForReachability:@"Internet connection not available"];
        [activityView stopAnimating];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return  [self.feedsDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UITableViewCell *cell = [self.feedsTableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSLog(@"indexpath %ld",(long)indexPath.row);
    
    [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
    cell.selectedBackgroundView = [UIView new];

    Feeds*feeds = [self.feedsDataArray objectAtIndex:indexPath.row];
    
    
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = [UIView new];

    UIView* cellView=(UIView*)[cell.contentView viewWithTag:305];
    if(cellView==nil)
     {
        cellView=[[UIView alloc] init];
        cellView.tag=305;
        [cellView setBackgroundColor:[UIColor colorWithRed:(238.0/255) green:(243.0/255) blue:(239.0/255) alpha:1.0]];
        cellView.layer.borderWidth=2.0;
        cellView.layer.borderColor=[[UIColor colorWithRed:(238.0/256) green:(243.0/256) blue:(239.0/256) alpha:1.0] CGColor];
        cellView.layer.cornerRadius=10.0;

    }


    UILabel *labeltitle = (UILabel *)[cellView viewWithTag:100];
    
    if (labeltitle==nil) {
        labeltitle=[[UILabel alloc] init];
        labeltitle.tag=100;
        labeltitle.numberOfLines = 0;
        labeltitle.textColor =[UIColor blueColor];
        labeltitle.text = feeds.title;
        labeltitle.lineBreakMode=NSLineBreakByWordWrapping;
        if (isiPhone5) {
            labeltitle.font= [UIFont fontWithName:@"helvetica" size:12];
        }else
            labeltitle.font= [UIFont fontWithName:@"helvetica" size:17];
        [cellView addSubview: labeltitle];
    }
    

    UILabel *labeldesc = (UILabel *)[cell.contentView viewWithTag:102];
    if (labeldesc==nil) {
        labeldesc=[[UILabel alloc] init];
        labeldesc.numberOfLines = 0;
        labeldesc.textColor =[UIColor blackColor];
        labeldesc.text = feeds.desc;
        labeldesc.tag=102;
        labeldesc.lineBreakMode=NSLineBreakByWordWrapping;
        
        if (isiPhone5) {
            labeldesc.font= [UIFont fontWithName:@"helvetica" size:10];
        }else
            labeldesc.font= [UIFont fontWithName:@"helvetica" size:14];
        
        
        [cellView addSubview: labeldesc];
    }
    
    UILabel *labelpub = (UILabel *)[cell.contentView viewWithTag:101];
    if (labelpub==nil) {
        
        labelpub=[[UILabel alloc] init];
        labelpub.tag=101;
        labelpub.font= [UIFont fontWithName:@"helvetica" size:17];
        [labelpub setTextColor:[UIColor blueColor]];
        labelpub.text = feeds.pubdate;
        [cellView addSubview:labelpub];
        
    }
    
    
    
    if (isiPhone5) {
        CGSize sizeOfTitle = [APP_DELEGATE sizeOfText:feeds.title withFont:[UIFont fontWithName:@"helvetica" size:12] widthOflabel:175];
        CGSize sizeOfDesc=[APP_DELEGATE sizeOfText:feeds.desc withFont:[UIFont fontWithName:@"helvetica" size:10] widthOflabel:300];
        
        
        cellView.frame=CGRectMake(3, 3, 314, (sizeOfTitle.height+sizeOfDesc.height+20));
        
        labeltitle.frame=CGRectMake(7,7,175, sizeOfTitle.height);
        labeldesc.frame=CGRectMake(7,sizeOfTitle.height+15,300, sizeOfDesc.height);
        
        
        labelpub.frame= CGRectMake(450 ,10, 331, 31);
    }else
    {
        CGSize sizeOfTitle = [APP_DELEGATE sizeOfText:feeds.title withFont:[UIFont fontWithName:@"helvetica" size:17] widthOflabel:360];
        CGSize sizeOfDesc=[APP_DELEGATE sizeOfText:feeds.desc withFont:[UIFont fontWithName:@"helvetica" size:14] widthOflabel:710];
        
        
        cellView.frame=CGRectMake(5, 5, 758, (sizeOfTitle.height+sizeOfDesc.height+30));
        
        labeltitle.frame=CGRectMake(10,10,360, sizeOfTitle.height);
        labeldesc.frame=CGRectMake(10,sizeOfTitle.height+20,710, sizeOfDesc.height);
        
        
        labelpub.frame= CGRectMake(450 ,10, 331, 31);
    }
    
    
    
    
    if (![[cell.contentView subviews]containsObject:cellView]) {
        [cell.contentView addSubview:cellView];
    }

    return cell;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feeds *feeds = [self.feedsDataArray objectAtIndex:indexPath.row];
    
    if (isiPhone5) {
        CGSize sizeOfTitle = [APP_DELEGATE sizeOfText:feeds.title withFont:[UIFont fontWithName:@"helvetica" size:12] widthOflabel:175];
        CGSize sizeOfDesc=[APP_DELEGATE sizeOfText:feeds.desc withFont:[UIFont fontWithName:@"helvetica" size:10] widthOflabel:300];
        return (sizeOfTitle.height+sizeOfDesc.height+25);
    }else
    {
        CGSize sizeOfTitle = [APP_DELEGATE sizeOfText:feeds.title withFont:[UIFont fontWithName:@"helvetica" size:17] widthOflabel:360];
        CGSize sizeOfDesc=[APP_DELEGATE sizeOfText:feeds.desc withFont:[UIFont fontWithName:@"helvetica" size:14] widthOflabel:710];
        return (sizeOfTitle.height+sizeOfDesc.height+40);
    }
    
}



//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        
//        Feeds*feeds;
//        
//        feeds = [self.feedsDataArray objectAtIndex:indexPath.row];
//        
//        feedWebLink=feeds.link;
//        
//        NSLog(@"====>link index %ld,Link===%@",(long)indexPath.row,feedWebLink);
//        
//        [self performSegueWithIdentifier:@"webViewSegue" sender:self];
//    }
// 
//   
//    
//}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        //[context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // NSError *error = nil;
        // if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        //  NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
        //}
    }
}



# pragma mark- web services

-(void)checkNewFeeds{
    
    [activityView startAnimating];
    
    NSURL*url = [NSURL URLWithString:@"http://devweb.indegene.com/indegene_sales_app/rssfeeds.jsp"];
    
    [[INDWebservices shared] cancelOperation:webserviceModal];
   webserviceModal = [[INDWebServiceModel alloc]initWithDelegate:self url:url NameOfWebService:RSSService];
    [[INDWebservices shared] startWebserviceOperation:webserviceModal];
}


-(void)completionOperationWithSuccess:(id)operation responseData:(id)responseObject webServiceOperationObject:(INDWebServiceModel *)webServiceOperationObject
{
    
    
    if ([webServiceOperationObject serviceName]==RSSService) {
        NSString*datastring = [[NSString alloc]initWithData:responseObject encoding:NSASCIIStringEncoding];
        NSData* data = [datastring dataUsingEncoding:NSUTF8StringEncoding];
        
        NSLog(@"response data %@", datastring);
        NSError* errorfeed;
     
        
        NSArray* feedResponce=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&errorfeed];
        
        NSLog(@"feedResonse %@", feedResponce);
        
        if (feedResponce) {
            
            //
            
        }
        
        //NSError * error;
        
        
        //NSManagedObjectContext *managedObjectContext  = [(INDAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        //[APP_DELEGATE managedObjectContext];
     
        [self.feedsDataArray removeAllObjects];
        for (int i =0; i<[feedResponce count]; i++) {
            
            NSString*title = [NSString stringWithFormat:@"%@",[[feedResponce objectAtIndex:i]objectForKey:@"title"]];
            
            NSString*desc = [NSString stringWithFormat:@"%@",[[feedResponce objectAtIndex:i]objectForKey:@"desc"]];
            
            NSString*pubdate = [NSString stringWithFormat:@"%@",[[feedResponce objectAtIndex:i]objectForKey:@"pubdate"]];
            
            NSString*link = [NSString stringWithFormat:@"%@",[[feedResponce objectAtIndex:i]objectForKey:@"link"]];
            
//            Feeds *newManagedObject =[NSEntityDescription insertNewObjectForEntityForName:@"Feeds" inManagedObjectContext:managedObjectContext];
//            newManagedObject.title = title;
//            newManagedObject.desc = desc;
//            newManagedObject.pubdate = pubdate;
//            newManagedObject.link = link;
            
            Feeds *feeds = [[Feeds alloc]init];
            feeds.title = title;
            feeds.desc = desc;
            feeds.pubdate = pubdate;
            feeds.link = link;
            [self.feedsDataArray addObject:feeds];
            
        }
        
                //[self refreshFeeds];  //can be used if we use db
            [self.feedsTableView reloadData];
        
        
        [UIView animateWithDuration:0.50 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.msgVCFeedObj.view.frame = CGRectMake(0,60,768,0);
            
            self.msgVCFeedObj.view.frame = CGRectMake(0,60,768,50);
            
        }completion:^(BOOL finished) {
            
            if ([feedResponce count]>0) {
                [self addMsgVC:@"Feed Avalible"];
                
            }else{
                [self addMsgVC:@"No Feeds Received"];
            }
            
            
        }];
        
    [self performSelector:@selector(removeMessagVC) withObject:self afterDelay:2.0];
        
        }
    
    [activityView stopAnimating];

}

-(void)completionOperationWithFailure:(id)operation error:(NSError *)error webServiceOperationObject:(INDWebServiceModel *)webServiceOperationObject
{
    [activityView stopAnimating];

}

-(void)deleteFeeds
{
    NSManagedObjectContext *managedObjectContext  = [APP_DELEGATE managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feeds" inManagedObjectContext:managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    //Edit the sort key as appropriate.
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userexists" ascending:NO];
    //    NSArray *sortDescriptors = @[sortDescriptor];
    
    //[fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error = nil;
    
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject * feed in results) {
       
        [managedObjectContext deleteObject:feed];
    }
    
    NSError *saveError = nil;
    
    [managedObjectContext save:&saveError];
    
	if (error) {
        
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"can not do fetch error %@, %@", error, [error userInfo]);
        
        
	}
  
}

-(void)refreshFeeds{
    
    NSArray* data = [self reterivefeeds];
    
    [self.feedsDataArray addObjectsFromArray:data];
    
    //NSLog(@"feeds %@", self.customerDataArray);
    
    [self.feedsTableView reloadData];
    
}

-(NSArray*)reterivefeeds{
    
    NSManagedObjectContext *managedObjectContext  = [APP_DELEGATE managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feeds" inManagedObjectContext:managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSError *error = nil;
    
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
	if (error) {
        
       	    NSLog(@"can not do fetch error %@, %@", error, [error userInfo]);
	}
    
    return results;
}

#pragma mark- orientation methods
-(BOOL)shouldAutorotate
{
    // forcing the rotate IOS6 Only
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
