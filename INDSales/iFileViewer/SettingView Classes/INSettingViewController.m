//
//  INSettingViewController.m
//  TestPopover
//
//  Created by parth on 28/10/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import "INSettingViewController.h"

@interface INSettingViewController ()
{
    NSMutableArray *imageArray;
    NSMutableArray *nameArray;
    UISwitch *switchview;
}

@end

@implementation INSettingViewController
@synthesize otl_tableView,settingDelegateObj;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
//    BOOL test= [[NSUserDefaults standardUserDefaults] boolForKey:@"switch"];
//    NSLog(@"onoff=%hhd",test);
//   [switchview setOn:test animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    // Do any additional setup after loading the view from its nib.
    otl_tableView.dataSource=self;
    otl_tableView.delegate=self;
    otl_tableView.alwaysBounceVertical = NO;
   // imageArray=[[NSMutableArray alloc]initWithObjects:@"favourite2.png",@"help.png",@"email.png",@"password.png",@"multimedia",@"", nil];
   // nameArray=[[NSMutableArray alloc]initWithObjects:@"Favourites",@"Help",@"Support",@"Security",@"Import Media",@"BG Audio", nil];
    
    imageArray=[[NSMutableArray alloc]initWithObjects:@"favourite2.png",@"password.png",@"multimedia",@"", nil];
    nameArray=[[NSMutableArray alloc]initWithObjects:@"Favourites",@"Security",@"Import Media",@"BG Audio", nil];
    
   
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 4;
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
            cell.imageView.image=[UIImage imageNamed:[imageArray objectAtIndex:indexPath.row]];
            cell.textLabel.text=[nameArray objectAtIndex:indexPath.row];
   if(indexPath.row==3)
   {
       switchview = [[UISwitch alloc] initWithFrame:CGRectMake(05, 0, 30, 30)];
       [switchview addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventValueChanged];
       switchview.tag=1;
       cell.accessoryView = switchview;
       
       BOOL test= [[NSUserDefaults standardUserDefaults] boolForKey:@"switch"];
       NSLog(@"onoff=%hhd",test);
       [switchview setOn:test animated:NO];
       
       NSLog(@"switch added..");
   }
        //to hide cell's seperator lines..1
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        return 40;
    }
    else
    {
      return 50;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    if(indexPath.row==0)
    {
        [self.settingDelegateObj showFavourites];
    }
    else if(indexPath.row==1)
    {
//        NSLog(@"help");
//        [self.settingDelegateObj showHelpContent];
        
        NSLog(@"contact us");
        
        [self.settingDelegateObj showPasswordSection];

    }
    else if(indexPath.row==2)
    {
//        NSLog(@"contact us");
//        
//        [self.settingDelegateObj contactUs];
        [self.settingDelegateObj fetchMediaFiles];

    }
   
   }

-(void)updateSwitch:(id)sender
{
    UISwitch *switchView = sender;
    BOOL state = [sender isOn];
    NSString *rez = state == YES ? @"YES" : @"NO";
    NSLog(@"result=%@",rez);
    if(switchView.tag==1)
    {
    if ([switchView isOn])
    {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"switch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@")>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ON");
        BOOL test= [[NSUserDefaults standardUserDefaults] boolForKey:@"switch"];
        NSLog(@"onoff=%hhd",test);
        
    }
   
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"switch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@")>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OFF");
        BOOL test= [[NSUserDefaults standardUserDefaults] boolForKey:@"switch"];
        NSLog(@"onoff=%hhd",test);
    }
    }
    
    //[self.settingDelegateObj setBackgroundAudioOnOff];
}

- (IBAction)onClickDismissVC:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate {
    
    return NO;
}

@end
