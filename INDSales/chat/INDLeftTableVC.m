//
//  INDLeftTableVC.m
//  INDSales
//
//  Created by parth on 23/04/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import "INDLeftTableVC.h"
#import "INDWebservices.h"
#import "INDWebServiceModel.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "INDrightChatVC.h"

@interface INDLeftTableVC ()<webServiceResponceProtocol,MBProgressHUDDelegate>

@property(nonatomic, strong) NSArray* userNames;
@property(nonatomic, strong) MBProgressHUD* loadingHud;

@end

@implementation INDLeftTableVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@indegene_sales_app/getUser.jsp",baseUrl]];
    NSDictionary* dic = @{@"loginid": [INDConfigModel shared].userName};
    
    INDWebServiceModel*webserviceModal = [[INDWebServiceModel alloc]initWithDelegate:self url:url NameOfWebService:getUser];
    [webserviceModal setPostData:dic];
    [[INDWebservices shared] startWebserviceOperation:webserviceModal];
    
    self.loadingHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _loadingHud.mode = MBProgressHUDModeIndeterminate;
    _loadingHud.delegate = self;
    _loadingHud.labelText = @"Loading";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)completionOperationWithSuccess:(id)operation responseData:(id)responseObject webServiceOperationObject:(INDWebServiceModel *)webServiceOperationObject
{
    if(webServiceOperationObject.serviceName == getUser)
    {
        self.userNames = [NSArray arrayWithArray:[[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil] objectForKey:@"users"]];
        
        [self.tableView reloadData];
        [_loadingHud hide:YES];
    }
}

-(void)completionOperationWithFailure:(id)operation error:(NSError *)error webServiceOperationObject:(INDWebServiceModel *)webServiceOperationObject
{
    if(webServiceOperationObject.serviceName == getUser)
    {
        [_loadingHud hide:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _userNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
//    UILabel* userNameLabel = (UILabel*)[cell.contentView viewWithTag:200];
//    userNameLabel.text = [_userNames objectAtIndex:indexPath.row];
    cell.textLabel.text = [_userNames objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isiPhone5)
    {
        [self performSegueWithIdentifier:@"chatTableSegueiPhone" sender:self];
    }
    else
    {
        UISplitViewController *splitViewController = self.splitViewController;
        
        INDrightChatVC* chatView = (INDrightChatVC*)[[[splitViewController.viewControllers lastObject] viewControllers] firstObject];
        
        [chatView selectUser:[_userNames objectAtIndex:indexPath.row]];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"chatTableSegueiPhone"])
    {
        INDrightChatVC* chatVC = (INDrightChatVC*)segue.destinationViewController;
        chatVC.userName = [_userNames objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    }
}

@end
