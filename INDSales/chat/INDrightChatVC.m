//
//  INDrightChatVC.m
//  INDSales
//
//  Created by parth on 23/04/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import "INDrightChatVC.h"
#import "HPGrowingTextView.h"
#import "INDMessageModel.h"
#import "INDLeftTableVC.h"
#import "PTSMessagingCell.h"
#import "INDMessageModel.h"
#import "INDWebServiceModel.h"
#import "INDWebservices.h"
#import "INDMessageVC.h"
#import "NSDate+TimeAgo.h"
#import "INDContactCell.h"
#import "INDSendContactVC.h"
#import "INDLiveChatModel.h"

#define windowSize 50

@interface INDrightChatVC ()<HPGrowingTextViewDelegate,UITableViewDataSource,UITableViewDelegate,webServiceResponceProtocol,sendContactCard,liveChatProtocol>

@property (nonatomic,strong)UIPopoverController *popover;
@property (nonatomic,strong)UIView*otlView;
@property (nonatomic,strong)HPGrowingTextView* sendMessageView;
@property (nonatomic,strong)UIBarButtonItem* barButtonChat;
@property (nonatomic,strong)NSMutableArray* tableDataSource;
@property (strong, nonatomic)UITableView *chatTableView;
@property (nonatomic,strong)NSString* usernameWhenMsgSent;
@property (nonatomic,strong)UIButton* sendBtn;
@property (strong, nonatomic) INDMessageVC *msgVC;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

- (IBAction)didSwipeLeft:(id)sender;
- (IBAction)didSwipeRight:(id)sender;
- (IBAction)handleTap:(UITapGestureRecognizer *)sender;

@end

@implementation INDrightChatVC

@synthesize otlView,sendMessageView,popover,barButtonChat,userName,sendBtn,loadingIndicator;
@synthesize tableDataSource,chatTableView,msgVC;

#pragma mark - Managing the detail item

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
    [loadingIndicator stopAnimating];
    otlView=[[UIView alloc] init];
    [otlView setBackgroundColor:[UIColor colorWithRed:(236.0/256.0) green:(236.0/256.0) blue:(236.0/256.0) alpha:1.0]];
    
    sendMessageView=[[HPGrowingTextView alloc] init];
    sendMessageView.delegate=self;
    [sendMessageView setFont:[UIFont systemFontOfSize:13]];
    [otlView addSubview:sendMessageView];
    
    sendBtn=[[UIButton alloc] init];
    [sendBtn setTitle:@"Send" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [sendBtn addTarget:self
                action:@selector(sendMessage:)
      forControlEvents:UIControlEventTouchUpInside];
    [otlView addSubview:sendBtn];
    
    
    UIButton* contactButton=[[UIButton alloc] init];
    [contactButton setImage:[UIImage imageNamed:@"contactButtonImage.png"] forState:UIControlStateNormal];
    [contactButton addTarget:self action:@selector(sendContactBtnPressed) forControlEvents:UIControlEventTouchDown];
    [otlView addSubview:contactButton];
    
    
    chatTableView=[[UITableView alloc] init];
    chatTableView.dataSource=self;
    chatTableView.delegate=self;
    [chatTableView setBackgroundColor:[UIColor clearColor]];
    [chatTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:chatTableView];
    [self.view addSubview:otlView];
    
    UIRefreshControl *refreshControl;
    if (isiPhone5) {
        chatTableView.frame=CGRectMake(0, 63, 320, 425);
        
        [otlView setFrame:CGRectMake(0, self.view.frame.size.height-83, self.view.frame.size.width, 35)];
        [sendMessageView setFrame:CGRectMake(40, 2, 200, 32)];
        [sendBtn setFrame:CGRectMake(260, 13, 50, 10)];
        [self selectUser:userName];
        refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(160, 50, 30, 30)];
        //  [sendMessageView setMinHeight:24];
        [contactButton setFrame:CGRectMake(5, 6, 25, 25)];
        
        
        sendMessageView.internalTextView.layer.borderWidth=2.0;
        sendMessageView.internalTextView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
        sendMessageView.internalTextView.layer.cornerRadius=10.0;
        
        
    }else
    {
        UISplitViewController *splitViewController = (UISplitViewController *)self.parentViewController;
        splitViewController.delegate=self;
        [otlView setFrame:CGRectMake(0, self.view.frame.size.height-96, self.view.frame.size.width, 40)];
        refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(364, 105, 40, 40)];
        [contactButton setFrame:CGRectMake(5, 3, 34, 34)];
        
        
        //because rotation is blocked
        otlView.frame=CGRectMake(0, 928,768, 40);
        chatTableView.frame=CGRectMake(0, 65, 768, 852);
        sendBtn.frame=CGRectMake(660, 8, 50, 25);
        sendMessageView.frame=CGRectMake(60, 5, 560, 30);
    }
    
    
    
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Load previous conversations..."];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    
    [chatTableView addSubview:refreshControl];
    
    [INDLiveChatModel shared].delegate=self;
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}
- (void)keyboardWillShow:(NSNotification *)note
{
    if (!isiPhone5) {
        [self hideChatsView];
    }
    NSDictionary *userInfo = note.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    
    CGRect keyboardFrameForTextField = [self.otlView.superview convertRect:keyboardFrame fromView:nil];
    
    CGRect newTextFieldFrame = self.otlView.frame;
    
    
    newTextFieldFrame.origin.y = keyboardFrameForTextField.origin.y - newTextFieldFrame.size.height;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^
     {
         self.otlView.frame = newTextFieldFrame;
         
     }completion:^(BOOL finished){
     }];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameForTextField = [self.otlView.superview convertRect:keyboardFrame fromView:nil];
    
    CGRect newTextFieldFrame = self.otlView.frame;
    newTextFieldFrame.origin.y = keyboardFrameForTextField.origin.y - newTextFieldFrame.size.height;
    
    if (isiPhone5) {
        newTextFieldFrame.origin.y -= 50;
    }else
        newTextFieldFrame.origin.y -= 56;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^
     {
         self.otlView.frame = newTextFieldFrame;
     }
                     completion:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = otlView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	otlView.frame = r;
}


-(void)selectUser:(NSString *)user
{
    if (popover != nil) {
        [popover dismissPopoverAnimated:YES];
    }
    
    if (isiPhone5) {
        [tableDataSource removeAllObjects];
        [chatTableView reloadData];
        self.navigationItem.title = [NSString stringWithFormat:@"%@",user];
        
        
        [self loadNextBatchOfConversation];
        [loadingIndicator startAnimating];
    }else
    {
        [self hideChatsView];
        if (![userName isEqualToString:user]) {
            userName=user;
            [tableDataSource removeAllObjects];
            [chatTableView reloadData];
            [self.navigationItem setTitle:[NSString stringWithFormat:@"%@",user]];
            
            
            [self loadNextBatchOfConversation];
            [loadingIndicator startAnimating];
        }
    }
}

-(void)refreshView:(UIRefreshControl *)refresh
{
    if (userName!=nil) {
        [refresh beginRefreshing];
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Load previous conversations..."];
        
        NSString *lastUpdated = [NSString stringWithFormat:@"Loading previous conversations..."];
        
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
        [self loadNextBatchOfConversation];
        [refresh endRefreshing];
    }
    
    
}

-(void)loadNextBatchOfConversation
{
    NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"%@indegene_sales_app/showMsg.jsp?",baseUrl]];
    
    int windowS=windowSize;
    
    NSString* upperLimit=[NSString stringWithFormat:@"%d",([tableDataSource count]+windowS)];
    
    NSString* lowerLimit=[NSString stringWithFormat:@"%d",([tableDataSource count]+1)];
    
    
    NSDictionary* getChatDic=@{@"loginid": [INDConfigModel shared].userName,@"chatuser":userName,@"minVal":lowerLimit,@"maxVal":upperLimit};
    NSLog(@"%@",getChatDic);
    
    INDWebServiceModel* getChat=[[INDWebServiceModel alloc] initWithDelegate:self url:url NameOfWebService:getMessages];
    [getChat setPostData:getChatDic];
    [[INDWebservices shared] startWebserviceOperation:getChat];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didTapChatsBtn:(id)sender
{
    [self.splitViewController.view bringSubviewToFront:popover.contentViewController.view];
    UIView *rootView = popover.contentViewController.view;
    popover.contentViewController.view.layer.borderWidth = 1.0;
    popover.contentViewController.view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    CGRect rootFrame = rootView.frame;
    rootFrame.size.height = 927.0;
    rootFrame.origin = CGPointZero;
    rootView.frame=CGRectMake(rootView.frame.origin.x, rootView.frame.origin.y, rootView.frame.size.width, 927);
    
    [UIView beginAnimations:@"showView" context:NULL];
    rootView.frame = rootFrame;
    [UIView commitAnimations];
    
    if (!isiPhone5) {
        [sendMessageView resignFirstResponder];
    }
    
//    [[self.splitViewController.viewControllers objectAtIndex:0] viewWillAppear:YES];
}

- (void)hideChatsView
{
    UIViewController *rootViewController = popover.contentViewController;
    
    UIView *rootView = rootViewController.view;
    CGRect rootFrame = rootView.frame;
    rootFrame.origin.x -= rootFrame.size.width;
    
    [UIView beginAnimations:@"hideView" context:NULL];
    rootView.frame = rootFrame;
    [UIView commitAnimations];
}

#pragma mark - UISplitViewDelegate methods
-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    //Grab a reference to the popover
    //potraite
    
    self.popover = pc;
    
    //Set the title of the bar button item
    barButtonItem.target = self;
    barButtonItem.action = @selector(didTapChatsBtn:);
    barButtonItem.title = NSLocalizedString(@"Chats", @"Chats");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    
//    otlView.frame=CGRectMake(0, 928,768, 40);
//    chatTableView.frame=CGRectMake(0, 65, 768, 852);
//    sendBtn.frame=CGRectMake(660, 8, 50, 25);
//    sendMessageView.frame=CGRectMake(60, 5, 560, 30);
    //Set the bar button item as the Nav Bar's leftBarButtonItem
    [self.parentViewController.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    //Remove the barButtonItem.
    //landscape
    
    //Nil out the pointer to the popover
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.popover = nil;
    
    
    chatTableView.frame=CGRectMake(0, 65, 703, 600);
    otlView.frame=CGRectMake(0, 672,768, 40);
    sendBtn.frame=CGRectMake(625, 8, 50, 25);
    sendMessageView.frame=CGRectMake(60, 5, 540, 30);
}

-(void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController
{
    [sendMessageView resignFirstResponder];
    
}

-(void)newMessageRecievedOfLoginId:(NSString *)loginId
{
    if ([loginId isEqualToString:userName])
    {
        _usernameWhenMsgSent=userName;
        NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"%@indegene_sales_app/showMsg.jsp?",baseUrl]];
        
        
        NSString* upperLimit=[NSString stringWithFormat:@"%d",50];
        
        NSString* lowerLimit=[NSString stringWithFormat:@"%d",1];
        
        
        NSDictionary* getChatDic=@{@"loginid": [INDConfigModel shared].userName,@"chatuser":userName,@"minVal":lowerLimit,@"maxVal":upperLimit};
        
        INDWebServiceModel* getChat=[[INDWebServiceModel alloc] initWithDelegate:self url:url NameOfWebService:getliveChat];
        [getChat setPostData:getChatDic];
        [[INDWebservices shared] startWebserviceOperation:getChat];
    }
    
}


-(void)sendMessage:(UIButton*)sender
{
    // [sendMessageView resignFirstResponder];
    if (userName!=nil)
    {
        if ([self validationForSendMsg:@"Enter the message"])
        {
            
            _usernameWhenMsgSent=[NSString stringWithFormat:@"%@",userName];
            
            NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"%@indegene_sales_app/sendMsg.jsp?",baseUrl]];
            INDWebServiceModel* sendMessageWebServiceModel=[[INDWebServiceModel alloc] initWithDelegate:self url:url NameOfWebService:sendMessage];
            
            
            NSDictionary* dic=@{@"loginid":[INDConfigModel shared].userName,@"chatuser":userName,@"message":[NSString stringWithFormat:@"%@",sendMessageView.text],@"iscontact":@"n"};
            
            [sendMessageWebServiceModel setPostData:dic];
            
            [[INDWebservices shared] startWebserviceOperation:sendMessageWebServiceModel];
            sendMessageView.text=nil;
            [sendMessageView resignFirstResponder];
            
        }
    }else
    {
        [self addMsgVC:@"select the user to chat"];
        [self performSelector:@selector(removeMsgVC) withObject:self afterDelay:2.0];
    }
    
    
}

-(BOOL)validationForSendMsg:(NSString*)msg
{
    if ([sendMessageView.text isEqualToString:@""]) {
        [self addMsgVC:msg];
        [self performSelector:@selector(removeMsgVC) withObject:self afterDelay:2.0];
        return NO;
    }else
        return YES;
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



-(void)completionOperationWithSuccess:(id)operation responseData:(id)responseObject webServiceOperationObject:(INDWebServiceModel *)webServiceOperationObject
{
    NSError* errorfeed;
    if (webServiceOperationObject.serviceName==getMessages)
    {
        [loadingIndicator stopAnimating];
        NSArray* chats=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&errorfeed];
        if (chats!=0) {
            BOOL bringRowDown=NO;
            
            if ([tableDataSource count]==0) {
                bringRowDown=YES;
            }
            
            NSMutableArray* recentChats=[[NSMutableArray alloc] init];
            for (NSDictionary* dic in chats) {
                INDMessageModel* messageModel=[self createMessage:dic];
                [recentChats addObject:messageModel];
            }
            
            NSIndexSet* indexSet=[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, ([chats count]))];
            [tableDataSource insertObjects:recentChats atIndexes:indexSet];
            
            
            NSMutableArray*x=[NSMutableArray new];
            for (int i=0; i<[chats count]; i++) {
                [x addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
            [chatTableView insertRowsAtIndexPaths:x withRowAnimation:UITableViewRowAnimationNone];
            
            
            if (bringRowDown) {
                if ([tableDataSource count]!=0) {
                    [chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[tableDataSource count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
            }
            
        }
        
    }
    
    if (webServiceOperationObject.serviceName==sendMessage)
    {
        if ([_usernameWhenMsgSent isEqualToString:userName])
        {
            NSDictionary*dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&errorfeed];
            NSLog(@"response object class %@",NSStringFromClass([dic class]));
            NSLog(@"dic= %@",dic);
            INDMessageModel* messageModel=[self createMessage:dic];
            messageModel.when=[[NSDate date] timeAgo];
            [tableDataSource addObject:messageModel];
            
            [chatTableView beginUpdates];
            [chatTableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:[tableDataSource count]-1 inSection:0], nil] withRowAnimation:UITableViewRowAnimationBottom];
            [chatTableView endUpdates];
            [chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[tableDataSource count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
    
    if (webServiceOperationObject.serviceName==getliveChat)
    {
        
        if ([_usernameWhenMsgSent isEqualToString:userName]) {
            NSArray* chats=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&errorfeed];
            
            NSMutableArray* recentChats=[[NSMutableArray alloc] init];
            for (NSDictionary* dic in chats)
            {
                INDMessageModel* messageModel=[self createMessage:dic];
                [recentChats addObject:messageModel];
            }
            
            INDMessageModel* lastObjectOfCurrentChat=[tableDataSource lastObject];
            
            int i=0;
            BOOL copyRestChats=NO;
            for (INDMessageModel* msgModel in recentChats)
            {
                if (copyRestChats==YES) {
                    [tableDataSource addObject:msgModel];
                }
                
                if ([msgModel.messageid isEqualToString:lastObjectOfCurrentChat.messageid])
                {
                    copyRestChats=YES;
                    
                    i=[recentChats indexOfObject:msgModel];
                }
            }
            i++;
            NSMutableArray*x=[NSMutableArray new];
            for (int j=i; j<[tableDataSource count]; j++) {
                [x addObject:[NSIndexPath indexPathForRow:j inSection:0]];
            }
            
            [chatTableView insertRowsAtIndexPaths:x withRowAnimation:UITableViewRowAnimationBottom];
            
            if ([tableDataSource count]!=0) {
                [chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[tableDataSource count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
            
            
        }
        
        
    }
    
}

-(INDMessageModel*)createMessage:(NSDictionary*)dic
{
    INDMessageModel* messageModel=[INDMessageModel new];
    
    messageModel.messageid=[dic objectForKey:@"messageid"];
    
    if ([[dic objectForKey:@"message"] isKindOfClass:[NSString class]]) {
        messageModel.message=[dic objectForKey:@"message"];
        messageModel.contact=nil;
    }
    else
    {
        messageModel.message=@"contact";
        messageModel.contact=[INDContactModel new];
        
        messageModel.contact.fname=[[dic objectForKey:@"message"] objectForKey:@"fname"];
        messageModel.contact.lname=[[dic objectForKey:@"message"] objectForKey:@"lname"];
        messageModel.contact.company=[[dic objectForKey:@"message"] objectForKey:@"company"];
        messageModel.contact.title=[[dic objectForKey:@"message"] objectForKey:@"title"];
        messageModel.contact.country=[[dic objectForKey:@"message"] objectForKey:@"country"];
        messageModel.contact.ccode=[[dic objectForKey:@"message"] objectForKey:@"ccode"];
        messageModel.contact.contact=[[dic objectForKey:@"message"] objectForKey:@"contact"];
        messageModel.contact.altcontact=[[dic objectForKey:@"message"] objectForKey:@"altcontact"];
        messageModel.contact.email=[[dic objectForKey:@"message"] objectForKey:@"email"];
        messageModel.contact.other=[[dic objectForKey:@"message"] objectForKey:@"other"];
        
        
    }
    
    
    if ([[dic objectForKey:@"message_from"] isEqualToString:[INDConfigModel shared].userName]) {
        messageModel.sent=YES;
    }
    else
        messageModel.sent=NO;
    
    messageModel.when=[APP_DELEGATE dateFormaterFromString:[dic objectForKey:@"date_created"]];
    return messageModel;
}

-(void)completionOperationWithFailure:(id)operation error:(NSError *)error webServiceOperationObject:(INDWebServiceModel *)webServiceOperationObject
{
    
}

-(void)createNewCustomer:(INDContactModel*)contact
{
    NSManagedObjectContext *managedObjectContext  = [APP_DELEGATE managedObjectContext];
    
    NSError *error = nil;
    NSManagedObject *newManagedObject =[NSEntityDescription insertNewObjectForEntityForName:@"Customer" inManagedObjectContext:managedObjectContext];
    [newManagedObject setValue:contact.fname forKey:@"firstname"];
    [newManagedObject setValue:contact.lname forKey:@"lastname"];
    [newManagedObject setValue:contact.company forKey:@"company"];
    [newManagedObject setValue:contact.contact forKey:@"phone"];
    [newManagedObject setValue:contact.email forKey:@"email"];
    [newManagedObject setValue:contact.altcontact forKey:@"alternatenumber"];
    [newManagedObject setValue:contact.other forKey:@"otherinfo"];
    [newManagedObject setValue:contact.title forKey:@"designation"];
    [newManagedObject setValue:contact.country forKey:@"country"];
    [newManagedObject setValue:contact.ccode forKey:@"countryCode"];
    
    BOOL isDIR=YES;
    
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
    
    
    [newManagedObject setValue:customerPhotoPath forKey:@"photoPath"];
    
    if (![managedObjectContext save:&error])
    {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    This method sets up the table-view.
    
    INDMessageModel* messageModel=[tableDataSource objectAtIndex:indexPath.row];
    
    if (messageModel.contact==nil)
    {
        static NSString* cellIdentifier = @"messagingCell";
        
        PTSMessagingCell * cell = (PTSMessagingCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[PTSMessagingCell alloc] initMessagingCellWithReuseIdentifier:cellIdentifier];
        }
        
        [self configureCell:cell atIndexPath:indexPath];
        cell.backgroundColor=[UIColor clearColor];
        cell.contentView.backgroundColor=[UIColor clearColor];
        return cell;
    }else
    {
        static NSString *CellIdentifier = @"contactCell";
        INDContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            
            cell = [[INDContactCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectedBackgroundView = [UIView new];
            
        }
        
        [cell.button addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchDown];
        [cell.button setTitle:[NSString stringWithFormat:@"%@ %@",messageModel.contact.fname,messageModel.contact.lname] forState:UIControlStateNormal];
        cell.whenLabel.text=messageModel.when;
        cell.sent=messageModel.sent;
        
        return cell;
    }
}


-(void)addContact:(UIButton*)sender
{
    
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [sender setBackgroundColor:[UIColor lightGrayColor]];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [sender setBackgroundColor:[UIColor colorWithRed:(248/256.0) green:(248/256.0) blue:(248/256.0) alpha:1.0]];
        } completion:^(BOOL finished) {
        }];
    }];
    NSIndexPath* index=[self.chatTableView indexPathForCell:(UITableViewCell*)sender.superview.superview.superview];
    
    INDMessageModel* message=[self.tableDataSource objectAtIndex:index.row];
    [self createNewCustomer:message.contact];
    
    [APP_DELEGATE flasfAlert:[NSString stringWithFormat:@"%@ %@",message.contact.fname,message.contact.lname] withheader:@"New contact added"];
}

-(void)sendContactBtnPressed
{
    if (userName!=nil) {
        [self performSegueWithIdentifier:@"selectContactSegue" sender:self];
    }
    else
    {
        [self addMsgVC:@"select the user to send the contact card"];
        [self performSelector:@selector(removeMsgVC) withObject:self afterDelay:2.0];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    INDMessageModel* messageModel=[tableDataSource objectAtIndex:indexPath.row];
    NSString *message;
    
    if (messageModel.contact==nil) {
        message=messageModel.message;
        CGSize messageSize = [PTSMessagingCell messageSize:message];
        return messageSize.height + 2*[PTSMessagingCell textMarginVertical] + 40.0f;
    }
    else
        return 120.0;
}

-(void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    PTSMessagingCell* ccell = (PTSMessagingCell*)cell;
    
    INDMessageModel* messageModel=[tableDataSource objectAtIndex:indexPath.row];
    
    NSString* message;
    if (messageModel.contact!=nil) {
        message=[NSString stringWithFormat:@"Add contact of:\n%@ %@",messageModel.contact.fname,messageModel.contact.lname];
        ccell.isSelectable=YES;
    }
    else{
        message=messageModel.message;
        ccell.isSelectable=NO;
    }
    
    ccell.sent=messageModel.sent;
    ccell.timeLabel.text = messageModel.when;
    
    ccell.messageLabel.text = message;
    
}

-(void)sendContact:(INDContactModel*)contact
{
    _usernameWhenMsgSent=[NSString stringWithFormat:@"%@",userName];
    
    NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"%@indegene_sales_app/sendMsg.jsp?",baseUrl]];
    INDWebServiceModel* sendMessageWebServiceModel=[[INDWebServiceModel alloc] initWithDelegate:self url:url NameOfWebService:sendMessage];
    
    
    NSDictionary* dic1=@{@"loginid":[INDConfigModel shared].userName,@"chatuser":userName,@"fname":contact.fname ,@"lname":contact.lname,@"company":contact.company,@"title":contact.title,@"country":contact.country,@"ccode":contact.ccode,@"contact":contact.contact,@"altcontact":contact.altcontact,@"email":contact.email,@"other":contact.other,@"iscontact":@"y"};
    
    
    [sendMessageWebServiceModel setPostData:dic1];
    
    [[INDWebservices shared] startWebserviceOperation:sendMessageWebServiceModel];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"selectContactSegue"]) {
        INDSendContactVC* contactVC=[segue destinationViewController];
        contactVC.delegate=self;
    }
    
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -
#pragma mark === Gesture Handlers ===
#pragma mark -

- (IBAction)didSwipeLeft:(UISwipeGestureRecognizer *)sender
{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        [self hideChatsView];
    }
}

- (IBAction)didSwipeRight:(UISwipeGestureRecognizer *)sender
{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        [self didTapChatsBtn:nil];
    }
}

- (IBAction)handleTap:(UITapGestureRecognizer *)sender
{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        [self hideChatsView];
    }
}

@end
