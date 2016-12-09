//
//  INDSelectCategory.m
//  INDSales
//
//  Created by Piyush on 4/1/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import "INDSelectCategory.h"

@interface INDSelectCategory ()
@property(strong,nonatomic) NSMutableArray *tableDataSource;
@property (weak, nonatomic) IBOutlet UIView *shadowView;

@end

@implementation INDSelectCategory

@synthesize selectedIndexPath,otlTableView,tableDataSource,delegate,shadowView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    tableDataSource=[NSMutableArray arrayWithArray:[INDConfigModel shared].category];
    [tableDataSource insertObject:@"All category" atIndex:0];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return tableDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = [UIView new];
    UILabel* categoryText=(UILabel*)[cell.contentView viewWithTag:100];
    
    categoryText.text=[tableDataSource objectAtIndex:indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    [delegate categoryDidSelected:[tableDataSource objectAtIndex:indexPath.row]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
