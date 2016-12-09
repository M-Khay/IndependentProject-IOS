//
//  IDVHistoryDataViewController.m
//  iDocViewer
//
//  Created by Krishna on 18/10/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import "IDVHistoryDataViewController.h"

@interface IDVHistoryDataViewController ()
{
    int deleteIndex;
}
@property(strong,nonatomic)NSMutableArray *arrOfFetchedData;

@end

@implementation IDVHistoryDataViewController
@synthesize arrOfURLs,idvHistoryDelegateObj;
@synthesize  arrOfFetchedData;
@synthesize otl_tableView;



- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
   // id delegate = [[UIApplication sharedApplication] delegate];
    DatasourceSingltonClass *sharedObject=[DatasourceSingltonClass sharedInstance];

    if ([sharedObject performSelector:@selector(managedObjectContext)]) {
        context = [sharedObject managedObjectContext];
    }
    return context;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad)
    {
        deleteButton.frame = CGRectMake(220,15,90,20);
        [deleteButton setTitle:@"Clear History" forState:UIControlStateNormal];
        [deleteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [deleteButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [deleteButton addTarget:self action:@selector(deleteAllHistory)
         
               forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:deleteButton];

        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        {
            [otl_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    
    
    otl_tableView.delegate=self;
    otl_tableView.dataSource=self;
    
    NSManagedObjectContext *historyContex=[self managedObjectContext];
    NSFetchRequest *req=[[NSFetchRequest alloc]init];
    NSEntityDescription *entityDescription=[NSEntityDescription entityForName:@"HistoryFiles" inManagedObjectContext:historyContex];
    [req setEntity:entityDescription];
    
    NSError *error;
    
      NSArray *arr=[historyContex executeFetchRequest:req error:&error];
    
    arrOfFetchedData=[[NSMutableArray alloc]init];
    if(arr.count>0)
    for (HistoryFiles *historyfileObj in arr)
    {
    
        [arrOfFetchedData addObject:historyfileObj.historyData];
    }
    
    else
    {
        
    }
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrOfFetchedData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    IDVHistoryCustomCell *cell = (IDVHistoryCustomCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray* topLevelObjects;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
        {
           topLevelObjects  = [[NSBundle mainBundle] loadNibNamed:@"IDVHistoryCustomCell_iPhone" owner:self options:nil];
        }
        else
        {
            topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"IDVHistoryCustomCell" owner:self options:nil];
        }
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (IDVHistoryCustomCell *)currentObject;
                break;
            }
        }
    }
    // Configure the cell...
       cell.otl_HIstoryTextLabel.text=[arrOfFetchedData objectAtIndex:indexPath.row];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [idvHistoryDelegateObj ShowHistoryinTextBox:[arrOfFetchedData objectAtIndex:indexPath.row]];
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
    
    deleteIndex=indexPath.row;
    
        UIAlertView *confirmDelete=[[UIAlertView alloc] initWithTitle:@"iDocViewer" message:@"Do you want to delete the file?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete",nil];
            [confirmDelete setTag:1];
            [confirmDelete show];
    }
}

-(void)deleteAllHistory
{
    UIAlertView *confirmDelete=[[UIAlertView alloc] initWithTitle:@"iDocViewer" message:@"Do you want to clear history ?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Clear",nil];
    [confirmDelete setTag:2];
    [confirmDelete show];
    
}

#pragma mark-
#pragma mark- alerview delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSError *error;
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if(alertView.tag==1)
    {
    if([title isEqualToString:@"Delete"])
    {
        BOOL success=NO;
    
        NSString *deletPath=[self.arrOfFetchedData objectAtIndex:deleteIndex];
        
        NSManagedObjectContext *context=[self managedObjectContext];
        NSFetchRequest *req=[[NSFetchRequest alloc]init];
        NSEntityDescription *e=[NSEntityDescription entityForName:@"HistoryFiles" inManagedObjectContext:context];
        [req setEntity:e];
        NSArray *arrOfFetchedfile=[context executeFetchRequest:req error:nil];
        
        for (NSManagedObject *obj in arrOfFetchedfile)
        {
            if([[obj valueForKey:@"historyData"] isEqual:deletPath])
            {
                [context deleteObject:obj];
                
                if (![context save:&error])
                {
                    NSLog(@"error");
                }
                success=YES;
                break;
            }
        }
        
        if (success)
        {
            [self.arrOfFetchedData removeObjectAtIndex:deleteIndex];
            [self.otl_tableView reloadData];
            
            
            MBProgressHUD *updatehud = [MBProgressHUD showHUDAddedTo:otl_tableView animated:YES];;
            updatehud.mode = MBProgressHUDModeCustomView;
            if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            {
                updatehud.labelFont=[UIFont fontWithName:@"Helvetica" size:12];
            }
            updatehud.labelText = @"Deleted";
            
            [updatehud hide:YES afterDelay:1];
            
        }
        else
        {
            NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
        }

    }
  }
    
    else if(alertView.tag==2)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Clear"])
        {
        NSError *error;
        NSManagedObjectContext *context=[self managedObjectContext];
        NSFetchRequest *req=[[NSFetchRequest alloc]init];
        NSEntityDescription *e=[NSEntityDescription entityForName:@"HistoryFiles" inManagedObjectContext:context];
        [req setEntity:e];
        NSArray *arrOfFetchedfile=[context executeFetchRequest:req error:nil];
            
            
        for (NSManagedObject *obj in arrOfFetchedfile)
        {
           [context deleteObject:obj];
        }
        
        if (![context save:&error])
        {
            NSLog(@"error");
        }
        arrOfFetchedData=Nil;
        [otl_tableView reloadData];
        }
    }
}
- (IBAction)onClickCancelVC:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onClickClearHistory:(id)sender
{
    [self deleteAllHistory];
}
@end
