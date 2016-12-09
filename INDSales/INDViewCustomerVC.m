//
//  INDViewCustomerVC.m
//  INDSales
//
//////  Created by Kush on 13/11/16.
//

#import "INDViewCustomerVC.h"
#import "INDCustomerDetailViewController.h"
#import "Customer.h"
#import "INDTheme2CustomCell.h"

@interface INDViewCustomerVC ()

@property (strong, nonatomic) IBOutlet UITableView *customerTableView;
@property (strong, nonatomic) NSMutableArray * customerDataArray;
@property (strong, nonatomic) NSMutableArray * customerFilteredArray;
@property (strong, nonatomic) IBOutlet UISearchBar *otlSearchBar;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSString* phoneNo;
@property(strong, nonatomic)Reachability * internetReachability;
@property (strong, nonatomic) NSString* emailAddress;

@property (nonatomic, strong) NSMutableArray *arrContactsData;
@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;

@end

@implementation INDViewCustomerVC

@synthesize customerDataArray,customerTableView;

@synthesize otlSearchBar,fetchedResultsController;

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
	// Do any additional setup after loading the view.
    self.customerDataArray = [[NSMutableArray alloc]init];
    
    self.customerFilteredArray = [[NSMutableArray alloc]init];
    
    customerTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
	[self.internetReachability startNotifier];
    
    //[self.otlSearchBar setScopeButtonTitles:]
     // otlSearchBar.showsScopeBar = NO;
  
    
    UIBarButtonItem *addButton=[[UIBarButtonItem alloc]initWithTitle:@"Import Contact" style:UIBarButtonItemStyleBordered target:self action:@selector(showAddressBook)];
    
        NSArray *barItem=@[addButton];
    self.navigationItem.rightBarButtonItems = barItem;

}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:NO];
    self.tabBarController.navigationItem.title = @"All Customer";
    self.customerDataArray=[NSMutableArray arrayWithArray:[self reteriveCustomer]];
    
    // NSLog(@"customer %@", self.customerDataArray);
    
    [self.customerTableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"%@",[segue identifier]);
    if ([[segue identifier] isEqualToString:@"customerDetailSegue"]) {
        INDCustomerDetailViewController* customerDetail=(INDCustomerDetailViewController*)[segue destinationViewController];

        //customerDetail.customerDetails= (Customer*)[[fetchedResultsController sections] objectAtIndex:[self.customerTableView indexPathForSelectedRow].row];
        
        customerDetail.customerDetails= (Customer*)[self.fetchedResultsController objectAtIndexPath:self.customerTableView.indexPathForSelectedRow];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    //Dispose of any resources that can be recreated.
}


-(NSArray*)reteriveCustomer
{
    
    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Customer" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    //    // Edit the sort key as appropriate.
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userexists" ascending:NO];
    //    NSArray *sortDescriptors = @[sortDescriptor];
    
    //[fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
	if (error) {
        
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development .
	    NSLog(@"can not do fetch error %@, %@", error, [error userInfo]);
        
        
	}
    
    for (int i =0; i<[results count]; i++) {
        
        NSLog(@"fName: %@", [[results objectAtIndex:i] firstname]);
        NSLog(@"lastname: %@", [[results objectAtIndex:i] lastname]);
        NSLog(@"phNum: %@", [[results objectAtIndex:i] phone]);
    }
    
    return results;
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
    
    
    //    if (tableView == self.searchDisplayController.searchResultsTableView) {
    //
    //        return [self.customerFilteredArray count];
    //    }
    //
    //    return  [self.customerDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //    Customer*customer;
    //
    //    if (tableView == self.searchDisplayController.searchResultsTableView) {
    //      customer = [self.customerFilteredArray objectAtIndex:indexPath.row];
    //    } else {
    //        customer = [self.customerDataArray objectAtIndex:indexPath.row];
    //    }
    
    Customer *customer = [fetchedResultsController objectAtIndexPath:indexPath];
    
    INDTheme2CustomCell  *cell = (INDTheme2CustomCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[INDTheme2CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.otl_theme2View.backgroundColor = [UIColor clearColor];
    
    cell.otl_firstName.text=[NSString stringWithFormat:@"%@ %@",customer.firstname,customer.lastname];
    
    if (customer.countryCode==NULL) {
        [cell.otlPhoneBtn setTitle:[NSString stringWithFormat:@"%@",customer.phone] forState:UIControlStateNormal];
    }
    else{
        [cell.otlPhoneBtn setTitle:[NSString stringWithFormat:@"%@%@",customer.countryCode,customer.phone] forState:UIControlStateNormal];
    }
    
    if ([[cell.otlPhoneBtn titleForState:UIControlStateNormal] isEqualToString:@""]) {
        cell.otlPhoneBtn.hidden=YES;
    }else
        cell.otlPhoneBtn.hidden=NO;
    
    
    if ([customer.email isEqualToString:@""])
    {
        cell.otlEmailBtn.hidden=YES;
    }else
    {
        cell.otlEmailBtn.hidden=NO;
        [cell.otlEmailBtn setTitle:customer.email forState:UIControlStateNormal];
    }
    
    [cell.otlCountryLbl setText:customer.country];
    [cell.designationOtl setText:customer.designation];
    cell.otl_companyName.text=customer.company;
    if([[NSFileManager defaultManager] fileExistsAtPath:customer.photoPath])
    {
        NSLog(@"file exist");
        cell.otl_PhotoImageView.image=[UIImage imageWithContentsOfFile:customer.photoPath];
    }
    else
    {
        NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"avtar" ofType:@"png"];
        cell.otl_PhotoImageView.image=[UIImage imageWithContentsOfFile:imgPath];
    }
    
    CAGradientLayer *grad = [CAGradientLayer layer];
    grad.frame = cell.otl_theme2View.bounds;
    grad.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:.5] CGColor], nil];
    
    [cell.otl_theme2View.layer insertSublayer:grad atIndex:0];
    cell.otl_theme2View.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.otl_theme2View.layer.shadowOpacity = 0.7f;
    cell.otl_theme2View.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    
    cell.otl_theme2View.layer.shadowRadius = 10.0f;
    cell.otl_theme2View.layer.masksToBounds = NO;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:cell.otl_theme2View.bounds];
    cell.otl_theme2View.layer.shadowPath = path.CGPath;
    
    NSLog(@"indexpath %d",indexPath.row);
    NSLog(@"custname %@", customer.firstname);
    cell.backgroundColor=[UIColor clearColor];
    cell.selectionStyle=UITableViewCellSeparatorStyleNone;
    
    
    return cell;
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Customer* customerToBeDeleted=[self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:customerToBeDeleted.photoPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:customerToBeDeleted.photoPath error:nil];
        }
        
        [self.fetchedResultsController.managedObjectContext deleteObject:customerToBeDeleted];
        
        NSError *error = nil;
        BOOL searchDeletedFlag = [self.fetchedResultsController.managedObjectContext save:&error];
        
        if (searchDeletedFlag)
        {
            NSLog(@"Search record deleted successfully");
        }
        
        
    }
    
}



- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        
    }
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    INDTheme2CustomCell *theme2TableCell = (INDTheme2CustomCell *)[tableView cellForRowAtIndexPath:indexPath];
    // theme2TableCell.otl_theme2View.backgroundColor = [UIColor redColor];
    
    theme2TableCell.otl_ImageBackground.image=[UIImage imageNamed:@"BackgroundImage.png"];
    
}
- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    INDTheme2CustomCell *theme2TableCell = (INDTheme2CustomCell *)[tableView cellForRowAtIndexPath:indexPath];
    // theme2TableCell.otl_theme2View.backgroundColor = [UICol or clearColor];
    theme2TableCell.otl_ImageBackground.image=nil;
    
}



-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    // Filter the array using NSPredicate
    
    [self.customerFilteredArray removeAllObjects];
    
    
    if ([scope isEqualToString:@"Country"]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.country contains[c] %@",searchText];
        
        self.customerFilteredArray = [NSMutableArray arrayWithArray:[self.customerDataArray filteredArrayUsingPredicate:predicate]];
        
    }else if([scope isEqualToString:@"company"]) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.company contains[c] %@",searchText];
        
        self.customerFilteredArray = [NSMutableArray arrayWithArray:[self.customerDataArray filteredArrayUsingPredicate:predicate]];
    }else if([scope isEqualToString:@"Name"]){
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.firstname contains[c] %@",searchText];
        
        self.customerFilteredArray = [NSMutableArray arrayWithArray:[self.customerDataArray filteredArrayUsingPredicate:predicate]];
    }
    
}

#pragma mark - UISearchBar Delegate Method's

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"searchBar textDidChange searchText = %@",searchText);
    /*
     // We use an NSPredicate combined with the fetchedResultsController to perform the search
     if ([searchBar.text isEqualToString:@""])
     {
     [self.fetchedResultsController.fetchRequest setPredicate:nil];
     }
     
     NSError *error = nil;
     if (![[self fetchedResultsController] performFetch:&error])
     {
     // Handle error
     NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
     exit(-1);// Fail
     }
     
     // this array is just used to tell the table view how many rows to show
     // reload the table view
     [self.customerTableView reloadData];
     */
    
    // We use  an NSPredicate combined with the fetchedResultsController to perform the search
    
    if (![searchBar.text isEqualToString:@""])
    {
        NSString *columnName = nil;
        NSPredicate *predicate = nil;
        
        switch (self.searchType) {
            case kSearchTypeName:
                columnName = @"firstname";
                predicate = [NSPredicate predicateWithFormat:@"firstname CONTAINS[cd] %@",searchBar.text];
                break;
            case kSearchTypeCountry:
                columnName = @"country";
                predicate = [NSPredicate predicateWithFormat:@"country CONTAINS[cd] %@",searchBar.text];
                break;
            case kSearchTypeCompanyName:
                columnName = @"company";
                predicate = [NSPredicate predicateWithFormat:@"company CONTAINS[cd] %@",searchBar.text];
                break;
                
            default:
                break;
        }
        
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ CONTAINS[cd] %@",columnName,searchBar.text];
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        if (![[self fetchedResultsController] performFetch:&error])
        {
            // Handle error
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);// Fail
        }
        
        
        // reload the table view
        [self.customerTableView reloadData];
    }
    
    /*
     if (![searchBar.text isEqualToString:@""])
     {
     NSPredicate *predicate =[NSPredicate predicateWithFormat:@"firstname CONTAINS[cd] %@", searchBar.text];
     
     [self.fetchedResultsController.fetchRequest setPredicate:predicate];
     }
     else
     {
     [self.fetchedResultsController.fetchRequest setPredicate:nil];
     }
     
     NSError *error = nil;
     if (![[self fetchedResultsController] performFetch:&error])
     {
     // Handle error
     NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
     exit(-1);// Fail
     }
     
     
     // reload the table view
     [self.customerTableView reloadData];
     */
    
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar;
{
    searchBar.showsCancelButton = YES;
    searchBar.showsScopeBar = YES;
    return YES;
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;
{
    
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar;
{
    /*
     self.isSearching = NO;
     
     CGRect headerViewRect = self.otlHeaderView.frame;
     headerViewRect.origin.y += 44;
     
     CGRect searcViewRect = self.otlSearchView.frame;
     searcViewRect.origin.y += 44;
     
     CGRect tableRect = self.tableView.frame;
     tableRect.origin.y += 44;
     //tableRect.origin.y -= 44;
     
     [UIView animateWithDuration:0.50 animations:^{
     
     [self.otlHeaderView setFrame:headerViewRect];
     [self.otlSearchView setFrame:searcViewRect];
     [self.tableView setFrame:tableRect];
     
     } completion:^(BOOL finished) {
     
     }];
     */
    
    return YES;
}



- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;
{
}

//- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//
//}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
{
    NSLog(@"searchBarSearchButtonClicked");
    
    [searchBar resignFirstResponder];
    
    
    // We use an NSPredicate combined with the fetchedResultsController to perform the search
    if (![searchBar.text isEqualToString:@""])
    {
        NSString *columnName = nil;
        NSPredicate *predicate = nil;
        
        switch (self.searchType) {
            case kSearchTypeName:
                columnName = @"firstname";
                predicate = [NSPredicate predicateWithFormat:@"firstname CONTAINS[cd] %@",searchBar.text];
                break;
            case kSearchTypeCountry:
                columnName = @"country";
                predicate = [NSPredicate predicateWithFormat:@"country CONTAINS[cd] %@",searchBar.text];
                break;
            case kSearchTypeCompanyName:
                columnName = @"company";
                predicate = [NSPredicate predicateWithFormat:@"company CONTAINS[cd] %@",searchBar.text];
                break;
                
            default:
                break;
        }
        
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ CONTAINS[cd] %@",columnName,searchBar.text];
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    }
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error])
    {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);// Fail
    }
    
    // this array is just used to tell the table view how many rows to show
    
    // reload the table view
    [self.customerTableView reloadData];
}

//- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar;                   // called when bookmark button pressed

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;                    // called when cancel button pressed
{
    NSLog(@"searchBarCancelButtonClicked");
    
    searchBar.text = @"";
    
    [searchBar resignFirstResponder];
    
    [self.fetchedResultsController.fetchRequest setPredicate:nil];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error])
    {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);// Fail
    }
    
    // this array is just used to tell the table view how many rows to show
    
    // reload the table view
    [self.customerTableView reloadData];
    
    
    searchBar.showsScopeBar = YES;
    searchBar.showsCancelButton = NO;
}

//- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar NS_AVAILABLE_IOS(3_2); // called when search results button pressed


- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    NSLog(@"selectedScopeButtonIndexDidChange selectedScope = %d",selectedScope);
    switch (selectedScope)
    {
        case kSearchTypeName:
            self.searchType = kSearchTypeName;
            break;
        case kSearchTypeCountry:
            self.searchType = kSearchTypeCountry;
            break;
        case kSearchTypeCompanyName:
            self.searchType = kSearchTypeCompanyName;
            break;
        default:
            break;
    }
    
    
    if (![searchBar.text isEqualToString:@""])
    {
        NSString *columnName = nil;
        NSPredicate *predicate = nil;
        
        switch (self.searchType) {
            case kSearchTypeName:
                columnName = @"firstname";
                predicate = [NSPredicate predicateWithFormat:@"firstname CONTAINS[cd] %@",searchBar.text];
                break;
            case kSearchTypeCountry:
                columnName = @"country";
                predicate = [NSPredicate predicateWithFormat:@"country CONTAINS[cd] %@",searchBar.text];
                break;
            case kSearchTypeCompanyName:
                columnName = @"company";
                predicate = [NSPredicate predicateWithFormat:@"company CONTAINS[cd] %@",searchBar.text];
                break;
                
            default:
                break;
        }
        
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ CONTAINS[cd] %@",columnName,searchBar.text];
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        if (![[self fetchedResultsController] performFetch:&error])
        {
            // Handle error
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);// Fail
        }
        
        
        // reload the table view
        [self.customerTableView reloadData];
    }
    

    
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    //[NSFetchedResultsController deleteCacheWithName:@"TD_SEARCH_CACHE"];
    
    if (fetchedResultsController != nil)
        return fetchedResultsController;
    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Customer" inManagedObjectContext:managedObjectContext];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstname" ascending:NO];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    //Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return fetchedResultsController;
}

#pragma mark - Fetched Results Controller Delegate Method's

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.customerTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.customerTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.customerTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.customerTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
        {
            //Search *searchRecord = [self.fetchedResultsController objectAtIndexPath:indexPath];
            //[self.indCommonOperation deleteSearchRecord:searchRecord];
            
            [self.customerTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
                  }
            break;
        case NSFetchedResultsChangeUpdate:
            //  [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    [self.customerTableView endUpdates];
}


- (IBAction)phoneBtnClicked:(UIButton *)sender
{
    INDTheme2CustomCell* cell=(INDTheme2CustomCell*)sender.superview.superview.superview.superview;

    
    _phoneNo=[NSString stringWithFormat:@"%@",[sender titleForState:UIControlStateNormal]];
    
    NSMutableArray* menuItemsArray=[[NSMutableArray alloc] init];
    
    UIMenuItem *copyPhoneNo = [[UIMenuItem alloc] initWithTitle:@"copy" action:@selector(copyPhoneNumber)];
    
    [menuItemsArray addObject:copyPhoneNo];
    
    NSURL* callUrl=[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",_phoneNo]];
    
    if([[UIApplication sharedApplication] canOpenURL:callUrl])
    {
        UIMenuItem *makeCall = [[UIMenuItem alloc] initWithTitle:@"call" action:@selector(makeACall)];
        [menuItemsArray addObject:makeCall];
    }
    CGRect myrect;
    if (isiPhone5) {
        myrect = CGRectOffset(sender.frame,0, sender.frame.size.height/2);

    }else
    {
        myrect = CGRectOffset(sender.frame, 130, sender.frame.size.height/2);

    }
    
    
    [self showMenuController:menuItemsArray frame:myrect cell:cell];
}

- (IBAction)emailBtnClicked:(UIButton *)sender
{
    INDTheme2CustomCell* cell=(INDTheme2CustomCell*)sender.superview.superview.superview.superview;
    
    _emailAddress=[NSString stringWithFormat:@"%@",[sender titleForState:UIControlStateNormal]];
    NSMutableArray* menuItemsArray=[[NSMutableArray alloc] init];
    
    UIMenuItem *copyPhoneNo = [[UIMenuItem alloc] initWithTitle:@"copy" action:@selector(copyEmail)];
    [menuItemsArray addObject:copyPhoneNo];
    
    UIMenuItem *sendMailItem = [[UIMenuItem alloc] initWithTitle:@"send mail" action:@selector(sendMail)];
    [menuItemsArray addObject:sendMailItem];
    
    CGRect myrect = CGRectOffset(sender.frame,80, sender.frame.size.height/2);
    
    [self showMenuController:menuItemsArray frame:myrect cell:cell];
}


-(void)showMenuController:(NSMutableArray*)menuItems frame:(CGRect)myrect cell:(INDTheme2CustomCell*)cell
{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    
    [menu setMenuItems:menuItems];
    
    [self becomeFirstResponder];
    
    [menu update];
    
    
    [menu setTargetRect:myrect inView:cell];
    
    [menu setMenuVisible:YES animated:YES];
}


-(void)copyPhoneNumber
{
    [self copyToClipBoard:_phoneNo];
}

-(void)copyToClipBoard: (NSString*)string
{
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:string];
}

-(void)makeACall
{
    NSString *number = [NSString stringWithFormat:@"%@",_phoneNo];
    NSURL* callUrl=[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",number]];
    
    [[UIApplication sharedApplication] openURL:callUrl];
    
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

-(BOOL)resignFirstResponder
{
    [UIMenuController sharedMenuController].menuItems=nil;
    return [super resignFirstResponder];
}


-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    [super canPerformAction:action withSender:sender];
    if ( action == @selector(makeACall) || action == @selector(copyPhoneNumber) ||action == @selector(sendMail) || action == @selector(copyEmail))
    {
        return YES;  // Logic here for context menu show/hide
    }
    
    return NO;
}

-(void)copyEmail
{
    [self copyToClipBoard:_emailAddress];
    
}

-(void)sendMail
{
    
    if (_internetReachability.currentReachabilityStatus!=NotReachable) {
        MFMailComposeViewController *composer=[[MFMailComposeViewController alloc]init];
        composer.mailComposeDelegate=self;
        if ([MFMailComposeViewController canSendMail]) {
            [composer setToRecipients:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",_emailAddress], nil]];
            [composer setSubject:@"iSalesAssist-support"];
            
            [composer setMessageBody:@"" isHTML:NO];
            [composer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
            [composer setModalPresentationStyle:UIModalPresentationFormSheet];
            [self presentViewController:composer animated:YES completion:nil];
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iSalesAssist" message:[NSString stringWithFormat: @"Please check your Network Settings"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}



-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    if (error) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"error %@",[error description]] delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
        [alert show];
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        
        NSString* resultString;
        
        if (result==MFMailComposeResultCancelled) {
            resultString=@"Message canceled";
        } else if (result==MFMailComposeResultSaved)
        {
            resultString=@"Mail saved in Draft";
        }else if (result==MFMailComposeResultSent)
        {
            resultString=@"Mail successfully sent";
        }else if (result==MFMailComposeResultFailed) {
            resultString=@"Mail failed to send";
        }
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Message" message:resultString delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
        [alert show];
        
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark-Import contacts

-(void)showAddressBook{
    _addressBookController = [[ABPeoplePickerNavigationController alloc] init];
    [_addressBookController setPeoplePickerDelegate:self];
    [self presentViewController:_addressBookController animated:YES completion:nil];
    
    
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    
    // Initialize a mutable dictionary and give it initial values.
    NSMutableDictionary* contactInfoDict = [[NSMutableDictionary alloc]
                                            initWithObjects:@[@"", @"", @"", @"", @"", @"", @"", @"", @"", @"",@"",@""]
                                            forKeys:@[@"firstName", @"lastName", @"mobileNumber", @"homeNumber", @"homeEmail", @"workEmail", @"address", @"zipCode", @"city",@"company",@"country",@"imagePath"]];
    
    // Use a general Core Foundation object.
    CFTypeRef generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    // Get the first name.
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"firstName"];
        CFRelease(generalCFObject);
    }
    
    // Get the last name.
    generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"lastName"];
        CFRelease(generalCFObject);
    }
    //Get Company name
    generalCFObject = ABRecordCopyValue(person, kABPersonOrganizationProperty);
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"company"];
        CFRelease(generalCFObject);
    }
    
    //Get country name
    generalCFObject = ABRecordCopyValue(person, kABPersonAddressProperty);
    
    NSDictionary* x=(__bridge NSDictionary *)(generalCFObject);
    NSLog(@"%@",x);
    
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"country"];
        CFRelease(generalCFObject);
    }
    
    // Get the phone numbers as a multi-value property.
    ABMultiValueRef phonesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    for (int i=0; i<ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
        }
        
        if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"homeNumber"];
        }
        
        CFRelease(currentPhoneLabel);
        CFRelease(currentPhoneValue);
    }
    CFRelease(phonesRef);
    
    
    // Get the e-mail addresses as a multi-value property.
    ABMultiValueRef emailsRef = ABRecordCopyValue(person, kABPersonEmailProperty);
    for (int i=0; i<ABMultiValueGetCount(emailsRef); i++) {
        CFStringRef currentEmailLabel = ABMultiValueCopyLabelAtIndex(emailsRef, i);
        CFStringRef currentEmailValue = ABMultiValueCopyValueAtIndex(emailsRef, i);
        
        if (CFStringCompare(currentEmailLabel, kABWorkLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentEmailValue forKey:@"workEmail"];
        }
        
        CFRelease(currentEmailLabel);
        CFRelease(currentEmailValue);
    }
    CFRelease(emailsRef);
    
    NSLog(@"Contact Info Dict=%@",contactInfoDict);
    
    
    
    // If the contact has an image then get it too.
    if (ABPersonHasImageData(person)) {
        NSData *contactImageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        
        NSString *str=[self saveImageInDataBase:contactImageData];
        
        [contactInfoDict setValue:str forKey:@"imagePath"];
        
        // NSLog(@"contact info dict=%@",contactInfoDict);
        
    }
    
    
    [self addCustomerDetailsInDatabase:contactInfoDict];
    return NO;
}


-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return YES
    ;
}


-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [_addressBookController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark-Import and save contact in database

-(void)addCustomerDetailsInDatabase:(NSMutableDictionary*)userDetailDict
{
    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE managedObjectContext];
    
    NSFetchRequest *fetcedValue=[[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Customer" inManagedObjectContext:managedObjectContext];
    [fetcedValue setEntity:entity];
    NSMutableArray *customerArr=[[NSMutableArray alloc]initWithArray:[managedObjectContext executeFetchRequest:fetcedValue error:nil]];
    
    BOOL isContactExistInDB=NO;
    
    for (int i=0; i<[customerArr count]; i++) {
        
        if ([[[customerArr objectAtIndex:i] valueForKey:@"firstname"] isEqualToString:[userDetailDict valueForKey:@"firstName"]]) {
            if ([[[customerArr objectAtIndex:i] valueForKey:@"lastname"] isEqualToString:[userDetailDict valueForKey:@"lastName"]]) {
                if ([[[customerArr objectAtIndex:i] valueForKey:@"company"] isEqualToString:[userDetailDict valueForKey:@"company"]]) {
                    if ([[[customerArr objectAtIndex:i] valueForKey:@"email"] isEqualToString:[userDetailDict valueForKey:@"workEmail"]]) {
                        
                        isContactExistInDB=YES;
                        NSLog(@"contact found");
                    }
                }
            }
            
        }
        
        else{
            
            NSLog(@"not found");
        }
        
    }
    
    if (isContactExistInDB==YES) {
        
        NSLog(@"do not save");
    }
    else{
        [self saveContactInDataBase:userDetailDict];
        NSLog(@"contact saved");
    }
    
    
}

-(void)saveContactInDataBase :(NSMutableDictionary*)CustomerDict

{
    
    NSManagedObjectContext *context =[APP_DELEGATE managedObjectContext];
    Customer *CustomerObj=[NSEntityDescription insertNewObjectForEntityForName:@"Customer" inManagedObjectContext:context];
    // NSLog(@"customer dic %@",CustomerDict);
    [CustomerObj  setValue:[NSString stringWithString:[CustomerDict valueForKey:@"firstName"]] forKey:@"firstname"];
    [CustomerObj  setValue:[NSString stringWithString:[CustomerDict valueForKey:@"lastName"]] forKey:@"lastname"];
    [CustomerObj  setValue:[NSString stringWithString:[CustomerDict valueForKey:@"company"]] forKey:@"company"];
    [CustomerObj  setValue:[NSString stringWithString:[CustomerDict valueForKey:@"workEmail"]] forKey:@"email"];
    [CustomerObj  setValue:[NSString stringWithString:[CustomerDict valueForKey:@"mobileNumber"]] forKey:@"phone"];
    [CustomerObj  setValue:[NSString stringWithString:[CustomerDict valueForKey:@"imagePath"]] forKey:@"photoPath"];
    
    NSError *error;
    if (![context save:&error])
    {
        NSLog(@"%@",error);
    }
}

-(NSString*)saveImageInDataBase:(NSData*)imageData
{
    BOOL isDIR;
    NSError *error;
    // NSManagedObjectContext *managedObjectContext  = [APP_DELEGATE managedObjectContext];
    // NSManagedObject *newManagedObject =[NSEntityDescription insertNewObjectForEntityForName:@"Customer" inManagedObjectContext:managedObjectContext];
    NSInteger customer_ID = [[NSUserDefaults standardUserDefaults] integerForKey:@"customer_ID"];
    NSString* customerID = [NSString stringWithFormat:@"%i", customer_ID];
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *fileName=[documentsPath stringByAppendingPathComponent:@"Customer_Photos"];
    
    NSString *customerPhotoPath = [fileName stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",customerID,@"png"]];
    
    customer_ID++;
    
    [[NSUserDefaults standardUserDefaults]setInteger:customer_ID forKey:@"customer_ID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName isDirectory:&isDIR])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:fileName withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    
    // [newManagedObject setValue:customerPhotoPath forKey:@"photoPath"];
    
    if (imageData!=nil) {
        [imageData writeToFile:customerPhotoPath atomically:YES];
        
    }
    
    NSLog(@"customerPhotoPath====>%@",customerPhotoPath);
    return customerPhotoPath;
}

#pragma mark-orientation
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