//
//  IDVSortOptionsViewController.m
//  iDocViewer
//
//  Created by Krishna on 28/01/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import "IDVSortOptionsViewController.h"

@interface IDVSortOptionsViewController ()
{
    NSMutableArray *sortTypeArray;
}

@end

@implementation IDVSortOptionsViewController
@synthesize otl_tableView;
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
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    otl_tableView.dataSource=self;
    otl_tableView.delegate=self;
    otl_tableView.alwaysBounceVertical = NO;
       
    sortTypeArray=[[NSMutableArray alloc]initWithObjects:@"Name",@"Size",@"CreationDate", nil];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier] ;
    }
    
    // Here we use the provided setImageWithURL: method to load the web image
    // Ensure you use a placeholder image otherwise cells will be initialized with     return cell;
    cell.textLabel.text=[sortTypeArray objectAtIndex:indexPath.row];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 35;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row==0)
    {
       [self.sortingDelegateObj sortByName];
        
    }
    else if(indexPath.row==1)
    {
       
        [self.sortingDelegateObj sortBySize];
    }
    else if(indexPath.row==2)
    {
               
        [self.sortingDelegateObj sortByCreationDate];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
