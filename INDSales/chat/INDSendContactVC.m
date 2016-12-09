//
//  INDSendContactVC.m
//  INDSales
//
//  Created by parth on 06/05/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import "INDSendContactVC.h"
#import "INDrightChatVC.h"
#import "INDMessageVC.h"
@interface INDSendContactVC ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *contactTableView;
@property (strong, nonatomic)NSMutableArray* tableDataSource;
@property (strong, nonatomic) IBOutlet UIButton *sendBtn;
@property (strong, nonatomic) INDMessageVC *msgVC;


@end

@implementation INDSendContactVC
@synthesize contactTableView,tableDataSource,sendBtn,msgVC;
@synthesize delegate;
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
    tableDataSource=[[NSMutableArray alloc] init];
}
-(void)viewWillAppear:(BOOL)animated
{
//    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        sendBtn.frame=CGRectMake(690, 20, 46, 30);
    } else
    {
        sendBtn.frame=CGRectMake(950, 20, 46, 30);

    }

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
    NSLog(@"%@",results);
    [tableDataSource removeAllObjects];
    for (Customer* custmer in results) {
        INDContactModel* contact=[INDContactModel new];

        contact.fname=[NSString stringWithFormat:@"%@",custmer.firstname];
        contact.lname=[NSString stringWithFormat:@"%@",custmer.lastname];
        contact.company=[NSString stringWithFormat:@"%@",custmer.company];
        contact.title=[NSString stringWithFormat:@"%@",custmer.designation];
        contact.country=[NSString stringWithFormat:@"%@",custmer.country];
        contact.ccode=[NSString stringWithFormat:@"%@",custmer.countryCode];
        contact.altcontact=[NSString stringWithFormat:@"%@",custmer.alternatenumber];
        contact.contact=[NSString stringWithFormat:@"%@",custmer.phone];
        contact.email=[NSString stringWithFormat:@"%@",custmer.email];
        contact.other=[NSString stringWithFormat:@"%@",custmer.otherinfo];
        [tableDataSource addObject:contact];
    }
    [contactTableView reloadData];
    [super viewWillAppear:animated];
    
}

-(void)viewDidDisappear:(BOOL)animated{
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [super viewDidDisappear:animated];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}
- (IBAction)cancelBtnClick:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)sendButtonClick:(UIButton *)sender
{
    
    
    NSIndexPath* index=[contactTableView indexPathForSelectedRow];
    
    if (index) {
        INDContactModel*contact=[tableDataSource objectAtIndex:index.row];
        
        [delegate sendContact:contact];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else
    {
        [self addMsgVC:@"Select the contact"];
        [self performSelector:@selector(removeMsgVC) withObject:self afterDelay:2.0];

    }
  

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    INDContactModel* contact=[tableDataSource objectAtIndex:indexPath.row];
    
    UILabel* contactNameLabel=(UILabel*)[cell.contentView viewWithTag:101];
    
    contactNameLabel.text=[NSString stringWithFormat:@"%@ %@",contact.fname,contact.lname];
    
    return cell;
}

-(void)addMsgVC:(NSString*)message
{
    if(![[self.view subviews]containsObject:msgVC.view])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
        
        self.msgVC = (INDMessageVC *)[storyboard instantiateViewControllerWithIdentifier:@"INDMessageVC"];
        
        [self addChildViewController:self.msgVC];
        
        
        [UIView animateWithDuration:0.50 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.msgVC.view.frame = CGRectMake(0,60,768,0);
            self.msgVC.view.frame = CGRectMake(0,60,768,50);
        } completion:^(BOOL finished) {
            msgVC.msgLabel.text=message;
        }];
        
        [self.view addSubview:self.msgVC.view];
        [self.msgVC didMoveToParentViewController:self];
        
    }
}

-(void)removeMsgVC
{
    if([[self.view subviews]containsObject:msgVC.view])
    {
        [UIView animateWithDuration:0.50 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.msgVC.view.frame = CGRectMake(0,60,768,50);
            
            self.msgVC.view.frame = CGRectMake(0,60,768,0);
            self.msgVC.msgLabel.hidden = TRUE;
            
        } completion:^(BOOL finished) {
            
            [self.msgVC.view removeFromSuperview];
            [self.msgVC removeFromParentViewController];
        }];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
