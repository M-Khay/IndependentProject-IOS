//
//  INDIntelligenceVC.m
//  INDSales
//
//  Created by Ashish on 05/02/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#define createNewPost @"Post new topic"

#import "INDIntelligenceVC.h"
#import "Post.h"
#import "PostResponse.h"
#import "INDWebservices.h"
#import "Reachability.h"
#import "Comment.h"
#import "HPGrowingTextView.h"
#import "INDPostInformation.h"
#import "INDTabBarVC.h"
#import "MMPickerView.h"
#import "treeNode.h"
#import "NSDate+TimeAgo.h"

#define offsetValueforBorder 6
#define borderwidth 3.0
#define cornerradius 10.0

@interface INDIntelligenceVC ()<HPGrowingTextViewDelegate,didSelectCategory>
@property(strong,nonatomic)NSMutableArray* postArray;
@property (strong, nonatomic)HPGrowingTextView *messageTextField;
@property (strong, nonatomic) INDMessageVC *msgVC;
@property (strong, nonatomic) IBOutlet UITableView *postTableView;
@property (strong, nonatomic) UIView *otlView;
@property (strong, nonatomic) Reachability* internetReachability;
@property (strong, nonatomic) MBProgressHUD* sendMessageHud;
@property (strong, nonatomic) MBProgressHUD* loadingHud;
@property(strong,nonatomic) UIPopoverController *popoverController;

@property (nonatomic, assign) BOOL selectCategoryVCIsVisible;
@property(nonatomic, strong) INDTabBarVC* tabBarVC;
@property(strong,nonatomic)NSMutableArray* tableArrayModel;
@property(strong,nonatomic)NSString* selectedCategory;
@property(strong, nonatomic)UIButton* CategoryForNewPostBtn;
@property(strong, nonatomic)UIButton* sendButton;
@property(strong,nonatomic)NSDictionary* postCommentOrResponseDic;
@property(strong,nonatomic)UIImage* straightArrow;
@property(strong,nonatomic)UIImage* downArrow;
@property(strong,nonatomic)UIImage* imgComment;
@property(strong,nonatomic)UIImage* imgComments;
@property(strong,nonatomic)UIImage* respondImg;

@end

@implementation INDIntelligenceVC
@synthesize postArray;
@synthesize postTableView,postCommentOrResponseDic;
@synthesize messageTextField,tableArrayModel,selectedCategory;
@synthesize otlView,sendMessageHud,indSelectCategoryVC,tabBarVC,sendButton;
@synthesize internetReachability,loadingHud,popoverController,selectCategoryVCIsVisible,msgVC,CategoryForNewPostBtn,straightArrow,downArrow;
@synthesize imgComment,imgComments,respondImg;

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
    
    // bar button item
    
    UIBarButtonItem *reqtestInfoButton=[[UIBarButtonItem alloc]initWithTitle:@"Request Info" style:UIBarButtonItemStyleDone target:self action:@selector(requestInfoButtonAction:)];
    
   
    
    UIBarButtonItem *selectCategoryButton=[[UIBarButtonItem alloc]initWithTitle:@"Competitive Intelligence" style:UIBarButtonItemStyleDone target:self action:@selector(selectCategoryButtonAction:)];
    
    selectedCategory=@"All category";
    self.navigationItem.title=[NSString stringWithString:selectedCategory];
    
    if (isiPhone5) {
        otlView=[[UIView alloc] initWithFrame:CGRectMake(0, 420, 320, 35)];
        messageTextField = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(3,3,200,10)];
        [messageTextField setFont:[UIFont systemFontOfSize:13.0]];
        CategoryForNewPostBtn=[[UIButton alloc] initWithFrame:CGRectMake(210, 5, 110,20)];
        [CategoryForNewPostBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
        sendButton=[[UIButton alloc] initWithFrame:CGRectMake(250, 5, 75, 5)];
        [messageTextField setMinHeight:10];
        [reqtestInfoButton setTitleTextAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]} forState:UIControlStateNormal];
         [selectCategoryButton setTitleTextAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0]} forState:UIControlStateNormal];

        [selectCategoryButton setTitle:@"Categories"];

    }else
    {
        otlView=[[UIView alloc] initWithFrame:CGRectMake(0, 928, 768, 40)];
        messageTextField = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(20,3,550,30)];
        CategoryForNewPostBtn=[[UIButton alloc] initWithFrame:CGRectMake(590, 3, 138, 33)];
        sendButton=[[UIButton alloc] initWithFrame:CGRectMake(580, 3, 138, 33)];
        messageTextField.font = [UIFont systemFontOfSize:15.0f];

    }
    
    [self.navigationItem  setRightBarButtonItem:selectCategoryButton animated:YES];
    [self.navigationItem  setLeftBarButtonItem:reqtestInfoButton animated:YES];
    
    
    [otlView setBackgroundColor:[UIColor colorWithRed:(236.0/256.0) green:(236.0/256.0) blue:(236.0/256.0) alpha:1.0]];
    [CategoryForNewPostBtn setTitle:@"Select category" forState:UIControlStateNormal];
    [CategoryForNewPostBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [CategoryForNewPostBtn addTarget:self action:@selector(OnSelectCategoryBtnClick:) forControlEvents:UIControlEventTouchDown];
    
    [otlView addSubview:CategoryForNewPostBtn];
    
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(OnSendBtnClick:) forControlEvents:UIControlEventTouchDown];
    sendButton.hidden=YES;
    [otlView addSubview:sendButton];
    
    [self.view addSubview:otlView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
	[self.internetReachability startNotifier];
    [self networkStatus:[self.internetReachability currentReachabilityStatus]];
    postArray=[[NSMutableArray alloc] init];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(364, 105, 40, 40)];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    
    [self.postTableView addSubview:refreshControl];
    [self callPost];
    
    
    messageTextField.isScrollable = NO;
    //messageTextField.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	messageTextField.minNumberOfLines = 1;
	messageTextField.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
//    textView.maxHeight = 200.0f;
	messageTextField.returnKeyType = UIReturnKeyDefault; //just as an example
	messageTextField.delegate = self;
    messageTextField.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    messageTextField.backgroundColor = [UIColor whiteColor];
    messageTextField.placeholder = createNewPost;
    messageTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [otlView addSubview:messageTextField];
    
    //---------
    tableArrayModel=[NSMutableArray new];
    

    
    NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"%@indegene_sales_app/token_collector.jsp?devicetoken=%@&loginid=%@",baseUrl,[INDConfigModel shared].deviceToken,[INDConfigModel shared].userName]];
    
    INDWebServiceModel* sendDeviceToken=[[INDWebServiceModel alloc] initWithDelegate:self url:url NameOfWebService:sendToken];
    [[INDWebservices shared] startWebserviceOperation:sendDeviceToken];
    
    straightArrow=[UIImage imageNamed:@"straightArrow.png"];
    downArrow=[UIImage imageNamed:@"downArrow.png"];
    imgComments=[UIImage imageNamed:@"comments.png"];
    imgComment=[UIImage imageNamed:@"comment.png"];
    respondImg=[UIImage imageNamed:@"response.png"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if (postArray.count!=0) {
//        [postTableView reloadData];
//    }

    self.tabBarController.navigationItem.title = @"Intelligence";
}

-(void)requestInfoButtonAction:(UIBarButtonItem*)sender
{
    if (isiPhone5) {
        [self performSegueWithIdentifier:@"requestInfoSegue" sender:self];
    }else
    {
        INDPostInformation *postInfVC=[self.storyboard instantiateViewControllerWithIdentifier:@"PostInformation"];
        
        if (self.selectCategoryVCIsVisible == YES){
            [self removeSelectCategoryVC];
        }
        
        UIPopoverController* aPopover = [[UIPopoverController alloc]
                                         initWithContentViewController:postInfVC];
        aPopover.delegate = self;
        postInfVC.mypopoverController=aPopover;
        // Store the popover in a custom property for later use.
        [aPopover setPopoverContentSize:CGSizeMake(450, 400)];
        if ([self.popoverController isPopoverVisible]) {
            //[self.popoverController dismissPopoverAnimated:YES];
            [popoverController setDelegate:nil];
        }
        
        else{
            self.popoverController = aPopover;
            [self.popoverController presentPopoverFromBarButtonItem:sender
                                           permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    
}

-(void)categoryDidSelected:(NSString *)category
{
    self.navigationItem.title=[NSString stringWithString:category];
    [self filterWithCategory:category];
    [postTableView reloadData];
    if (self.tableArrayModel.count==0) {
        
        [self showlabel:YES];
    }
    else{
        
        [self showlabel:NO];
    }
    
    [self removeSelectCategoryVC];
}

-(void)selectCategoryButtonAction:(UIBarButtonItem*)sender
{
    [messageTextField resignFirstResponder];
    if ([self.popoverController isPopoverVisible]) {
        [popoverController setDelegate:nil];
        [self.popoverController dismissPopoverAnimated:YES];
    }
    
    if (self.selectCategoryVCIsVisible == NO)
        [self addSelectCategoryVC];
    else if (self.selectCategoryVCIsVisible == YES)
        [self removeSelectCategoryVC];
    
}
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = otlView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	otlView.frame = r;
}


- (void) reachabilityChanged:(NSNotification *)note
{
    [self networkStatus:[[note object] currentReachabilityStatus]];
    
}

-(void)networkStatus:(NetworkStatus)networkStatus
{
    if (networkStatus==NotReachable)
    {
        [sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        sendButton.userInteractionEnabled=NO;
    }
    else
    {
        [sendButton setTitleColor:[UIColor colorWithRed:0 green:(126.0/256) blue:(246.0/256) alpha:1.0] forState:UIControlStateNormal];
        sendButton.userInteractionEnabled=YES;
    }
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}
- (IBAction)resumeKeyboardByTapOnTable:(UITapGestureRecognizer *)sender {
    
  //  [sender.]
    
    if ([messageTextField isFirstResponder]) {
        [messageTextField resignFirstResponder];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeSelectCategoryVC];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}




- (void)keyboardWillShow:(NSNotification *)note
{
    [self removeSelectCategoryVC];
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
    [self showCategoryBtn];
    NSDictionary *userInfo = note.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameForTextField = [self.otlView.superview convertRect:keyboardFrame fromView:nil];
    
    CGRect newTextFieldFrame = self.otlView.frame;
    newTextFieldFrame.origin.y = keyboardFrameForTextField.origin.y - newTextFieldFrame.size.height;
    
    if (isiPhone5) {
        newTextFieldFrame.origin.y-=49;
    }else
        newTextFieldFrame.origin.y -= 56;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        self.otlView.frame = newTextFieldFrame;}
                     completion:nil];
}

#pragma mark - refresh tble view

-(void)refreshView:(UIRefreshControl *)refresh

{
    [refresh beginRefreshing];
    [self callPost];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [refresh endRefreshing];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)callPost
{
    
    NSURL*url = [NSURL URLWithString:[NSString stringWithFormat:@"%@indegene_sales_app/user_posts.jsp?login=%@",baseUrl,[INDConfigModel shared].userName]];
    
    NSLog(@"%@",[url absoluteString]);
    INDWebServiceModel*webserviceModal = [[INDWebServiceModel alloc]initWithDelegate:self url:url NameOfWebService:POSTService];
    
    [[INDWebservices shared] startWebserviceOperation:webserviceModal];
    
    loadingHud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    loadingHud.mode=MBProgressHUDModeIndeterminate;
    loadingHud.delegate=self;
    loadingHud.labelText=@"Loading";
    
    
}


-(void)completionOperationWithSuccess:(id)operation responseData:(id)responseObject webServiceOperationObject:(INDWebServiceModel *)webServiceOperationObject
{
    NSError* errorfeed;
    
    NSArray* posts=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&errorfeed];
    
    if (webServiceOperationObject.serviceName==sendToken) {
        NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]);
    }

    if ([webServiceOperationObject serviceName]==POSTService)
    {
        [self loadDataInTableView:posts];
        [loadingHud hide:YES];
    }
    
    if (webServiceOperationObject.serviceName==post_Response)
    {
        [self loadDataInTableView:posts];
        sendMessageHud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        sendMessageHud.mode = MBProgressHUDModeCustomView;
        sendMessageHud.labelText = @"Message sent successful";

        [sendMessageHud hide:YES afterDelay:2];
        messageTextField.text=nil;
    }
    
    if (webServiceOperationObject.serviceName==sendPost_Respose)
    {
        
        NSDictionary* newlyCreatedResponse=[[[posts objectAtIndex:0] objectForKey:@"responses"] objectAtIndex:0];
        
        PostResponse* post_response=[PostResponse new];
        post_response.response_by=[newlyCreatedResponse objectForKey:@"response_by"];
        post_response.response=[newlyCreatedResponse objectForKey:@"response"];
        
        
        post_response.response_date=[APP_DELEGATE dateFormaterFromString:[newlyCreatedResponse objectForKey:@"response_date"]];
        post_response.response_id=[newlyCreatedResponse objectForKey:@"response_id"];
        
        
        
        Post* postDetails=[postCommentOrResponseDic objectForKey:@"post"];
        if (postDetails.responses==nil) {
            postDetails.responses=[NSMutableArray new];
        }
        [postDetails.responses addObject:post_response];
        
        treeNode* node=[postCommentOrResponseDic objectForKey:@"node"];
        
        if (node!=nil)
        {
            NSIndexPath *index=[NSIndexPath indexPathForRow:[tableArrayModel indexOfObject:node] inSection:0];
            
            
            if (node.children!=nil)
            {
                int count=index.row+[node.children count]+1;
                //remove previous node's border
                
                [self addRowForTreeNodeinTable:post_response atRow:count ofParentNode:node];
                 NSIndexPath *indexOfPrevNode=[NSIndexPath indexPathForRow:count-1 inSection:0];
                [self.postTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexOfPrevNode, nil] withRowAnimation:UITableViewRowAnimationNone];
                
            }
            
            [self.postTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:index, nil] withRowAnimation:UITableViewRowAnimationNone];
        }
        [self removeSendAfterSuccess];
    }
    
    if (webServiceOperationObject.serviceName==sendComment)
    {
        Comment* newComment=[[Comment alloc] init];
        newComment.comment=[postCommentOrResponseDic objectForKey:@"comment"];
        newComment.commented_by=[INDConfigModel shared].userName;
        newComment.commented_on= [[NSDate date] timeAgo];
        PostResponse* response=[postCommentOrResponseDic objectForKey:@"response"];
        
        if (response.comments==nil) {
            response.comments=[[NSMutableArray alloc] init];
        }
        
        [response.comments addObject:newComment];

        treeNode* node=[postCommentOrResponseDic objectForKey:@"node"];
        
        if (node!=nil)
        {
            NSIndexPath *index=[NSIndexPath indexPathForRow:[tableArrayModel indexOfObject:node] inSection:0];
            [self.postTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:index, nil] withRowAnimation:UITableViewRowAnimationNone];
            
            if (node.children!=nil)
            {
                int count=index.row+[node.children count]+1;
                
        
                [self addRowForTreeNodeinTable:newComment atRow:count ofParentNode:node];
                
                NSIndexPath *indexOfPrevNode=[NSIndexPath indexPathForRow:count-1 inSection:0];
                [self.postTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexOfPrevNode, nil] withRowAnimation:UITableViewRowAnimationNone];
            }
        }

        [self removeSendAfterSuccess];

    }
    
}
- (void)OnSelectCategoryBtnClick:(UIButton *)sender {
    
    [self removeSelectCategoryVC];
    NSString* postTitle=[NSString stringWithFormat:@"%@",messageTextField.text];
    [messageTextField resignFirstResponder];
    [MMPickerView pickerUseForCountry:NO];
    [MMPickerView showPickerViewInView:self.view
                           withStrings:[INDConfigModel shared].category
                           withOptions:@{MMselectedObject:[[INDConfigModel shared].category objectAtIndex:0]}
                            completion:^(NSString *selectedString)
                            {
                                NSLog(@"%@",selectedString);
                                if (![selectedString isEqualToString:@"-1"])
                                {
                                    if ([self validationForSendMsg:@"please enter the post title" forString:postTitle])
                                    {
                                        [messageTextField resignFirstResponder];
                                        INDWebServiceModel* sendPostRequest=[[INDWebServiceModel alloc] initWithDelegate:self url:[NSURL URLWithString:[NSString stringWithFormat:@"%@indegene_sales_app/user_posts.jsp",baseUrl]] NameOfWebService:post_Response];
                                        
                                        NSDictionary* postDic=@{@"login":[INDConfigModel shared].userName,@"post":postTitle,@"category":selectedString};
                                        [sendPostRequest setPostData:postDic];
                                        [[INDWebservices shared] startWebserviceOperation:sendPostRequest];
                                        [self showSendHud];
                                    }
                                }
                                
                            }];
}

-(void)loadDataInTableView:(NSArray*)posts
{
    [postArray removeAllObjects];
    
    for (NSDictionary* postDic in posts) {
        
        Post* postData=[Post new];
        postData.client_id=[postDic objectForKey:@"client_id"];
        postData.createddate=[APP_DELEGATE dateFormaterFromString:[postDic objectForKey:@"createddate"]];
        postData.posted_by=[postDic objectForKey:@"posted_by"];
        postData.topic=[postDic objectForKey:@"post"];
        postData.topic_id=[postDic objectForKey:@"post_id"];
        postData.category=[postDic objectForKey:@"category"];
        postData.responses=[NSMutableArray new];
        
        treeNode* postNode=[treeNode new];
        postNode.value=postData;
        postNode.parent=nil;
        postNode.children=nil;
        
        for (NSDictionary* responcesDic in [postDic objectForKey:@"responses"])
        {
            PostResponse* postresponse=[PostResponse new];
            postresponse.response=[responcesDic objectForKey:@"response"];
            postresponse.response_by=[responcesDic objectForKey:@"response_by"];
            postresponse.response_date=[APP_DELEGATE dateFormaterFromString:[responcesDic objectForKey:@"response_date"]];
            postresponse.response_id=[responcesDic objectForKey:@"response_id"];
            postresponse.comments=[NSMutableArray new];
            
            for (NSDictionary* dic in [responcesDic objectForKey:@"comments"])
            {
                
                Comment* comment=[Comment new];
                
                comment.commented_on=[APP_DELEGATE dateFormaterFromString:[dic objectForKey:@"commented_on"]];
                
                
                comment.commented_by=[dic objectForKey:@"commented_by"];
                comment.comment=[dic objectForKey:@"comment"];
                [postresponse.comments addObject:comment];
                
            }
            [postData.responses addObject:postresponse];
            
        }
        
        
        [postArray addObject:postData];
    }
    [self filterWithCategory:selectedCategory];
    [postTableView reloadData];
}

-(void)filterWithCategory:(NSString*)categoryName
{
    [tableArrayModel removeAllObjects];
    
    if ([categoryName isEqualToString:@"All category"])
    {
        for (Post* postDetails in postArray) {
            treeNode* postNode=[treeNode new];
            postNode.value=postDetails;
            postNode.parent=nil;
            postNode.children=nil;
            [tableArrayModel addObject:postNode];
        }
    }
    else
    {
        
        for (Post* postDetails in postArray) {
            if ([postDetails.category isEqualToString:categoryName]) {
                treeNode* postNode=[treeNode new];
                postNode.value=postDetails;
                postNode.parent=nil;
                postNode.children=nil;
                [tableArrayModel addObject:postNode];
            }
        }
    }
}


-(void)completionOperationWithFailure:(id)operation error:(NSError *)error webServiceOperationObject:(INDWebServiceModel *)webServiceOperationObject
{
    if (webServiceOperationObject.serviceName==post_Response || webServiceOperationObject.serviceName==sendPost_Respose || webServiceOperationObject.serviceName==sendComment)
    {
        sendMessageHud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"close.png"]];
        sendMessageHud.mode = MBProgressHUDModeCustomView;
        sendMessageHud.delegate = self;
        sendMessageHud.labelText = @"Failed to send the message";
        sendMessageHud.delegate=nil;
        [sendMessageHud show:YES];
        [sendMessageHud hide:YES afterDelay:2];
        messageTextField.text=nil;

    }
    
    if (webServiceOperationObject.serviceName==POSTService) {
        [loadingHud hide:YES];
    }
    
    if (webServiceOperationObject.serviceName==sendToken) {
        ;
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	
}

#pragma mark - Table View

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return  [self.tableArrayModel count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [self.postTableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    treeNode* node = [self.tableArrayModel objectAtIndex:indexPath.row];
    UIFont *font;
    UIFont*bottomLineFont;

    if (isiPhone5)
    {
        font = [UIFont fontWithName:@"helvetica" size:14];
        bottomLineFont=[UIFont fontWithName:@"helvetica" size:12];
    }
    else
    {
        font = [UIFont fontWithName:@"helvetica" size:17];
        bottomLineFont=[UIFont fontWithName:@"helvetica" size:14];
    }
    
    

    UIView* cellView=(UIView*)[cell.contentView viewWithTag:205];
    if (cellView==nil) {
        cellView=[[UIView alloc] init];
        cellView.tag=205;
        
    }
   
    UILabel *topicLabel=(UILabel*)[cellView viewWithTag:200];
    if (topicLabel==nil) {
        topicLabel=[[UILabel alloc] init];
        topicLabel.tag=200;
        topicLabel.numberOfLines = 0;
        topicLabel.lineBreakMode = NSLineBreakByWordWrapping;
        topicLabel.font = font;
        [cellView addSubview: topicLabel];
    }
    
    UILabel *labelPostedBy = (UILabel *)[cellView viewWithTag:201];
    if(labelPostedBy==nil)
    {
        labelPostedBy=[[UILabel alloc] init];
        labelPostedBy.tag=201;
        labelPostedBy.font= bottomLineFont;
        [labelPostedBy setTextColor:[UIColor darkGrayColor]];
        [cellView addSubview:labelPostedBy];
    }
    
    UILabel *labelDate = (UILabel *)[cellView viewWithTag:202];
    if (labelDate==nil) {
        labelDate=[[UILabel alloc] init];
        labelDate.tag=202;
        labelDate.font=bottomLineFont;
        labelDate.textColor=[UIColor darkGrayColor];
        [cellView addSubview:labelDate];
        
    }
    
    

    if ([node.value isKindOfClass:[Post class]])
    {
        
        Post* postDetails=node.value;
        CGSize size;
        if (isiPhone5) {
            size= [APP_DELEGATE sizeOfText:postDetails.topic withFont:font widthOflabel:200];
        }else
        {
            size= [APP_DELEGATE sizeOfText:postDetails.topic withFont:font widthOflabel:560];
        }
        
        
        
        [cellView setBackgroundColor:[UIColor colorWithRed:(133.0/255) green:(195.0/255) blue:(214.0/255) alpha:1.0]];
        
        cellView.layer.borderWidth=borderwidth;
        cellView.layer.borderColor=[[UIColor darkGrayColor] CGColor];
        cellView.layer.cornerRadius=cornerradius;
        
        UIImageView* arrowImageView=(UIImageView*)[cellView viewWithTag:601];
        
        if (arrowImageView==nil) {
            arrowImageView=[[UIImageView alloc] init];
            arrowImageView.tag=601;
            [cellView addSubview:arrowImageView];
        }
        
        if (postDetails==nil||([node.children count]==0)) {
            arrowImageView.image=straightArrow;
        }
        else
            arrowImageView.image=downArrow;
        
        
        if (postDetails.responses==nil || [postDetails.responses count]==0) {
            arrowImageView.image=nil;
        }else if (postDetails==nil||([node.children count]==0)) {
            arrowImageView.image=straightArrow;
        }
        else
            arrowImageView.image=downArrow;

        if([node.children count]==0||node.children==nil)
        {
            
            [self addBottomBorderForPostOnCellView:cellView forNode:node atIndex:indexPath.row];
        }
        else
        {
            [self removeBottomBorderForPostOnCellView:cellView forNode:node atIndex:indexPath.row];
        }
        
        topicLabel.text = (postDetails.topic ? postDetails.topic : @"");
        
        
        
        UILabel *response= (UILabel*)[cellView viewWithTag:203];
        
        if (response==nil) {
            response=[[UILabel alloc] init];
            response.tag=203;
            response.font=[UIFont systemFontOfSize:12];
            response.textColor=[UIColor darkGrayColor];
            response.textAlignment=NSTextAlignmentRight;
            [cellView addSubview:response];
        }
        
        if ([postDetails.responses count]==0 || (postDetails.responses==nil))
            response.text=@"";

        else
            response.text=[NSString stringWithFormat:@"%d",[postDetails.responses count]];
        
        
        
        UIButton* commentBtn=(UIButton*)[cellView viewWithTag:207];
        
        if ([[cellView subviews] containsObject:commentBtn]) {
            [commentBtn removeFromSuperview];
        }
        
        
        UIButton* responseBtn=(UIButton*)[cellView viewWithTag:206];
        
        if (responseBtn==nil) {
            responseBtn=[[UIButton alloc] init];
            responseBtn.tag=206;
            [responseBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            responseBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            [cellView addSubview:responseBtn];
            [responseBtn addTarget:self action:@selector(postResponse:) forControlEvents:UIControlEventTouchDown];
            [responseBtn setImage:respondImg forState:UIControlStateNormal];
            responseBtn.showsTouchWhenHighlighted=YES;
        }
        
        //  topicLabel.text = postDetails.topic;
        labelPostedBy.text = [NSString stringWithFormat:@"- %@",postDetails.posted_by];
        labelDate.text = postDetails.createddate;
        
        UIView* leftSideBorder=(UIView*)[cellView viewWithTag:209];
        
        if (leftSideBorder!=nil) {
            [leftSideBorder removeFromSuperview];
        }
        
        UIView* rightSideBorder=(UIView*)[cellView viewWithTag:210];
        
        if (rightSideBorder!=nil) {
            [rightSideBorder removeFromSuperview];
        }
        
        if (isiPhone5) {
            topicLabel.frame=CGRectMake(26,10,200, size.height+3);
            labelPostedBy.frame= CGRectMake(35, size.height+20, 150, 20);

            labelDate.frame=CGRectMake(230, 10, 90, 15);
            arrowImageView.frame=CGRectMake(5,(size.height/2+5) , 20, 20);
            response.frame=CGRectMake(195, size.height+20,30,15);
            responseBtn.frame=CGRectMake(230, size.height+20, 73, 15);
        }else
        {
            topicLabel.frame=CGRectMake(50,10, 560, size.height+3);
            labelPostedBy.frame= CGRectMake(55, size.height+15, 150, 20);
            labelDate.frame=CGRectMake(640, 10, 100, 20);
            arrowImageView.frame=CGRectMake(10,(size.height/2+5) , 30, 30);
            responseBtn.frame=CGRectMake(cellView.frame.size.width/2-30, size.height+18, 73, 15);
            response.frame=CGRectMake(cellView.frame.size.width/2-75, size.height+18, 40, 15);

        }
        
        
        

    }else
        if ([node.value isKindOfClass:[PostResponse class]])
    {
        
        PostResponse* postResponceDetails=node.value;
        
        CGSize size = [APP_DELEGATE sizeOfText:postResponceDetails.response withFont:font widthOflabel:560];


        [cellView setBackgroundColor:[UIColor colorWithRed:(172.0/255) green:(214.0/255) blue:(228.0/255) alpha:1.0]];

        cellView.frame=CGRectMake(0, 0, postTableView.frame.size.width, size.height+45);
        
        topicLabel.text = (postResponceDetails.response ? postResponceDetails.response : @"");
        topicLabel.frame=CGRectMake(50,10, 550, size.height);
        
        labelPostedBy.frame= CGRectMake(55, size.height+15, 200, 20);
        
        labelDate.frame=CGRectMake(644, 10, 100, 20);
        
        UILabel *response= (UILabel*)[cellView viewWithTag:203];
        
        if (response==nil) {
            response=[[UILabel alloc] init];
            response.tag=203;
            response.textColor=[UIColor darkGrayColor];
            response.textAlignment=NSTextAlignmentRight;

            [cellView addSubview:response];
        }
        response.font=[UIFont fontWithName:@"helvetica" size:12];

        UIButton* commentBtn=(UIButton*)[cellView viewWithTag:207];
        
        if (commentBtn==nil) {
            commentBtn=[[UIButton alloc] init];
            commentBtn.tag=207;
            [commentBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            commentBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            [cellView addSubview:commentBtn];
            [commentBtn addTarget:self action:@selector(commentToResponse:) forControlEvents:UIControlEventTouchDown];
            //    [commentBtn setTitle:@"comment" forState:UIControlStateNormal];
            
            commentBtn.showsTouchWhenHighlighted=YES;
            
            if ([postResponceDetails.comments count]>1)
                [commentBtn setImage:imgComments forState:UIControlStateNormal];
            else
                [commentBtn setImage:imgComment forState:UIControlStateNormal];
        }

        
        if ([postResponceDetails.comments count]!=0) {
            response.text=[NSString stringWithFormat:@"%d",[postResponceDetails.comments count]];
        }
        else
            response.text=@"";
        
        UIButton* responseBtn=(UIButton*)[cellView viewWithTag:206];
        
        if ([[cellView subviews] containsObject:responseBtn]) {
            [responseBtn removeFromSuperview];
        }
        
        
        UIImageView* arrowIV=(UIImageView*)[cellView viewWithTag:601];
        
        if ([[cellView subviews] containsObject:arrowIV]) {
            [arrowIV removeFromSuperview];
        }

        
        
        topicLabel.text = (postResponceDetails.response ? postResponceDetails.response : @"");
        

        treeNode* parentNode=node.parent;
        Post* parentPost=(Post*)parentNode.value;
        
        if (([parentPost.responses lastObject]==postResponceDetails)&& (node.children==nil || [node.children count]==0))
        {
            //add bottom border
            
            
            [self addBottomBorderForResponseOnCellView:cellView forNode:node atIndex:indexPath.row];

        }else
        {
            //remove bottom border
            cellView.frame=CGRectMake(0, 0, postTableView.frame.size.width, size.height+45);
            
            [self removeBottomBorderForResponseOnCellView:cellView forNode:node atIndex:indexPath.row];

            
        }

       // response.frame=CGRectOffset(commentBtn.frame, -20, 0);
        labelPostedBy.text = [NSString stringWithFormat:@"- %@",postResponceDetails.response_by];
        labelDate.text = postResponceDetails.response_date;
        
        
    }else if ([node.value isKindOfClass:[Comment class]])
    {
        
        Comment* commentResponse=node.value;

        [cellView setBackgroundColor:[UIColor colorWithRed:(211.0f/255) green:(234.0f/255) blue:(241.0f/255) alpha:1.0]];
        topicLabel.text = (commentResponse.comment ? commentResponse.comment : @"");

        UIImageView* arrowIV=(UIImageView*)[cellView viewWithTag:601];
        
        if ([[cellView subviews] containsObject:arrowIV]) {
            [arrowIV removeFromSuperview];
        }
        
        UILabel *response= (UILabel*)[cellView viewWithTag:203];

        if ([[cellView subviews] containsObject:response]) {
            [response removeFromSuperview];
        }
        
        UIButton* responseBtn=(UIButton*)[cellView viewWithTag:206];

        if ([[cellView subviews] containsObject:responseBtn]) {
            [responseBtn removeFromSuperview];
        }
        
        UIButton* commentBtn=(UIButton*)[cellView viewWithTag:207];
        
        if ([[cellView subviews] containsObject:commentBtn]) {
            [commentBtn removeFromSuperview];
        }
        
        labelDate.text = commentResponse.commented_on;
        labelPostedBy.text = [NSString stringWithFormat:@"- %@",commentResponse.commented_by];
    
        treeNode* parentNode=node.parent;
        PostResponse* parentPost=(PostResponse*)parentNode.value;
        
        treeNode* gParentNode=parentNode.parent;
        Post* postDetails=gParentNode.value;
        
        if (([parentPost.comments lastObject]==commentResponse)&& (node.children==nil || [node.children count]==0)&&([postDetails.responses lastObject]==parentPost))
        {

            [self addBottomBorderForCommentOnCellView:cellView forNode:node atIndex:indexPath.row];
        }
        else
        {

            [self removeBottomBorderForCommentOnCellView:cellView forNode:node atIndex:indexPath.row];
        }
    }
    
    
    if (![[cell.contentView subviews]containsObject:cellView]) {
        [cell.contentView addSubview:cellView];
    }

    
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString* topic;
    treeNode *treeNode = [self.tableArrayModel objectAtIndex:indexPath.row];
    
    
    
    if ([treeNode.value isKindOfClass:[Post class]])
    {
        
        Post* postDetails=treeNode.value;
        topic=postDetails.topic;
        if (indexPath.row!=0) {
            if (isiPhone5) {
                return ([APP_DELEGATE sizeOfText:topic withFont:[UIFont fontWithName:@"helvetica" size:14] widthOflabel:200].height+53);
            }else
            {
                return ([APP_DELEGATE sizeOfText:topic withFont:[UIFont fontWithName:@"helvetica" size:17] widthOflabel:560].height+52);
            }
            
        }
        
    }else if ([treeNode.value isKindOfClass:[PostResponse class]])
    {
        PostResponse* responseDetails=treeNode.value;
        topic=responseDetails.response;
    }else if ([treeNode.value isKindOfClass:[Comment class]])
    {
        Comment* commentDetails=treeNode.value;
        topic=commentDetails.comment;
    }
    
    if (isiPhone5) {

        return ([APP_DELEGATE sizeOfText:topic withFont:[UIFont fontWithName:@"helvetica" size:14] widthOflabel:200].height+46);
    }else
    {

        return ([APP_DELEGATE sizeOfText:topic withFont:[UIFont fontWithName:@"helvetica" size:17] widthOflabel:560].height+42);
    }
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [self.postTableView cellForRowAtIndexPath:indexPath];
    
    UIView* cellView=(UIView*)[cell.contentView viewWithTag:205];
    
    treeNode* node=[tableArrayModel objectAtIndex:indexPath.row];
    
    if ([node.children count]==0)
    {
        //add rows
        int count=indexPath.row;
        if ([node.value isKindOfClass:[Post class]])
        {
            Post* postDetails=node.value;
            
            for (PostResponse* response in postDetails.responses)
            {
                count++;
                //change arrow direction to down
                UIImageView* arrowIV=(UIImageView*)[cellView viewWithTag:601];
                
                arrowIV.image=downArrow;
                
                [self addRowForTreeNodeinTable:response atRow:count ofParentNode:node];
                
                [self performBlock:^{
                     [self removeBottomBorderForPostOnCellView:cellView forNode:node atIndex:indexPath.row];
                } afterDelay:.1];
                
                [self removeBottomBorderForPostOnCellView:cellView forNode:node atIndex:indexPath.row];
            }
            
        }else if ([node.value isKindOfClass:[PostResponse class]])
        {
            PostResponse* postResposeDetails=node.value;
            
            
            for (Comment* commentDetails in postResposeDetails.comments) {
                count++;
                
               

                [self addRowForTreeNodeinTable:commentDetails atRow:count ofParentNode:node];
                
                [self performBlock:^{
                    [self removeBottomBorderForResponseOnCellView:cellView forNode:node atIndex:indexPath.row];
                } afterDelay:.1];
                
                [self removeBottomBorderForResponseOnCellView:cellView forNode:node atIndex:indexPath.row];

            }
        }
    }
    else
    {
        //remove rows
        
        [self removeChildrenNodesOfNode:node];

        
        if ([node.value isKindOfClass:[Post class]])
        {
            
            UIImageView* arrowIV=(UIImageView*)[cellView viewWithTag:601];
            arrowIV.image=straightArrow;
            [self performBlock:^{
                [self addBottomBorderForPostOnCellView:cellView forNode:node atIndex:indexPath.row];
            } afterDelay:.2];
            
            
            
        }else if ([node.value isKindOfClass:[PostResponse class]])
        {
            
            PostResponse* postResponseDetail=node.value;
            
            treeNode* parentNode=node.parent;
            Post* parentPost=(Post*)parentNode.value;
            
            if ([parentPost.responses lastObject]==postResponseDetail)
            {
                UIView* cellView=(UIView*)[cell.contentView viewWithTag:205];
                
                [self performBlock:^{
                    [self addBottomBorderForResponseOnCellView:cellView forNode:node atIndex:indexPath.row];
                } afterDelay:0.2];
                
            }
            

        }
        
    }
    
}

- (void)performBlock:(void (^)(void))block
          afterDelay:(NSTimeInterval)delay
{
    block = [block copy] ;
    [self performSelector:@selector(fireBlockAfterDelay:)
               withObject:block
               afterDelay:delay];
}

- (void)fireBlockAfterDelay:(void (^)(void))block {
    block();
}



-(void)addBottomBorderForPostOnCellView:(UIView*)cellView forNode:(treeNode*)node atIndex:(int)row
{

    Post* postDetails=node.value;
    UIFont* font =[UIFont fontWithName:@"helvetica" size:17];

    CGSize size;
    if (isiPhone5) {
        size= [APP_DELEGATE sizeOfText:postDetails.topic withFont:font widthOflabel:200];
    }else
    {
        size= [APP_DELEGATE sizeOfText:postDetails.topic withFont:font widthOflabel:560];
    }
    
    if(row!=0)
        cellView.frame=CGRectMake(0, 8, postTableView.frame.size.width, size.height+42);
    else
        cellView.frame=CGRectMake(0, 0, postTableView.frame.size.width, size.height+42);


}

-(void)removeBottomBorderForPostOnCellView:(UIView*)cellView forNode:(treeNode*)node atIndex:(int)row

{
    Post* postDetails=node.value;
    UIFont* font =[UIFont fontWithName:@"helvetica" size:17];
    
    CGSize size = [APP_DELEGATE sizeOfText:postDetails.topic withFont:font widthOflabel:560];
    
    if(row!=0)
        cellView.frame=CGRectMake(0, 8, postTableView.frame.size.width, size.height+42+borderwidth+offsetValueforBorder);
    else
        cellView.frame=CGRectMake(0, 0, postTableView.frame.size.width, size.height+42+borderwidth+offsetValueforBorder);
}

-(void)addBottomBorderForResponseOnCellView:(UIView*)cellView forNode:(treeNode*)node atIndex:(int)row
{
    PostResponse* postResposeDetails=node.value;
    UIFont* font =[UIFont fontWithName:@"helvetica" size:17];

    CGSize size = [APP_DELEGATE sizeOfText:postResposeDetails.response withFont:font widthOflabel:560];
    
    cellView.layer.borderWidth=borderwidth;
    cellView.layer.borderColor=[[UIColor darkGrayColor] CGColor];
    cellView.layer.cornerRadius=cornerradius;
    
    UILabel *topicLabel=(UILabel*)[cellView viewWithTag:200];
    UILabel *labelPostedBy = (UILabel *)[cellView viewWithTag:201];
    UILabel *labelDate = (UILabel *)[cellView viewWithTag:202];
    UILabel *response= (UILabel*)[cellView viewWithTag:203];
    UIButton* commentBtn=(UIButton*)[cellView viewWithTag:207];
    
    UIView* rightSideBorder=(UIView*)[cellView viewWithTag:210];
    UIView* leftSideBorder=(UIView*)[cellView viewWithTag:209];
    
    cellView.frame=CGRectMake(0, -offsetValueforBorder-4, postTableView.frame.size.width, size.height+45);
   
    if (isiPhone5) {
        topicLabel.frame=CGRectMake(26,10+offsetValueforBorder, 550, size.height);
        labelDate.frame=CGRectMake(230, 10+offsetValueforBorder, 100, 20);
        labelPostedBy.frame= CGRectMake(27, size.height+15+offsetValueforBorder, 200, 20);
        commentBtn.frame=CGRectMake(230, size.height+18+offsetValueforBorder, 75, 15);
        response.frame=CGRectMake(195, size.height+16+offsetValueforBorder, 30, 15);

    }else
    {
        topicLabel.frame=CGRectMake(50,10+offsetValueforBorder, 550, size.height);
        labelDate.frame=CGRectMake(644, 10+offsetValueforBorder, 100, 20);
        labelPostedBy.frame= CGRectMake(55, size.height+15+offsetValueforBorder, 200, 20);
        commentBtn.frame=CGRectMake(cellView.frame.size.width/2-30, size.height+18+offsetValueforBorder, 75, 15);
        response.frame=CGRectMake(cellView.frame.size.width/2-60, size.height+16+offsetValueforBorder, 20, 15);

    }
    
    
    
    if (rightSideBorder!=nil) {
        [rightSideBorder removeFromSuperview];
    }
    
    if (leftSideBorder!=nil) {
        [leftSideBorder removeFromSuperview];
    }
}

-(void)removeBottomBorderForResponseOnCellView:(UIView*)cellView forNode:(treeNode*)node atIndex:(int)row
{
    
    PostResponse* postResposeDetails=node.value;
    UIFont* font =[UIFont fontWithName:@"helvetica" size:17];
    
    CGSize size = [APP_DELEGATE sizeOfText:postResposeDetails.response withFont:font widthOflabel:560];
    
    UILabel *topicLabel=(UILabel*)[cellView viewWithTag:200];
    UILabel *labelPostedBy = (UILabel *)[cellView viewWithTag:201];
    UILabel *labelDate = (UILabel *)[cellView viewWithTag:202];
    UILabel *response= (UILabel*)[cellView viewWithTag:203];
    UIButton* commentBtn=(UIButton*)[cellView viewWithTag:207];
    
    cellView.frame=CGRectMake(0, 0, postTableView.frame.size.width, size.height+45);
    
    if (isiPhone5) {
        topicLabel.frame=CGRectMake(26,10, 550, size.height);
        labelPostedBy.frame= CGRectMake(27, size.height+15, 200, 20);
        labelDate.frame=CGRectMake(230, 10, 100, 20);
        commentBtn.frame=CGRectMake(230, size.height+18, 70, 15);
        response.frame=CGRectMake(195, size.height+16, 30, 15);

    }else
    {
        topicLabel.frame=CGRectMake(50,10, 550, size.height);
        labelPostedBy.frame= CGRectMake(55, size.height+15, 200, 20);
        labelDate.frame=CGRectMake(644, 10, 100, 20);
        commentBtn.frame=CGRectMake(cellView.frame.size.width/2-30, size.height+18, 70, 15);
        response.frame=CGRectMake(cellView.frame.size.width/2-60, size.height+16, 20, 15);

    }
    
    
    cellView.layer.borderWidth=0.0;
    cellView.layer.cornerRadius=0.0;
    
    UIView* rightSideBorder=(UIView*)[cellView viewWithTag:210];
    UIView* leftSideBorder=(UIView*)[cellView viewWithTag:209];
    
    
    if (leftSideBorder==nil) {
        leftSideBorder=[[UIView alloc] init];
        leftSideBorder.tag=209;
        [leftSideBorder setBackgroundColor:[UIColor darkGrayColor]];
        [cellView addSubview:leftSideBorder];
    }
    
    
    if (rightSideBorder==nil) {
        rightSideBorder=[[UIView alloc] init];
        rightSideBorder.tag=210;
        [rightSideBorder setBackgroundColor:[UIColor darkGrayColor]];
        [cellView addSubview:rightSideBorder];
    }
    
    leftSideBorder.frame=CGRectMake(0, 0, borderwidth, cellView.frame.size.height);
    
    rightSideBorder.frame=CGRectMake(cellView.frame.size.width-borderwidth, 0, borderwidth, cellView.frame.size.height);
    
}

-(void)addBottomBorderForCommentOnCellView:(UIView*)cellView forNode:(treeNode*)node atIndex:(int)row
{

    Comment* commentD=node.value;
    UIFont* font =[UIFont fontWithName:@"helvetica" size:17];
    
    CGSize size = [APP_DELEGATE sizeOfText:commentD.comment withFont:font widthOflabel:560];
    
    UIView* rightSideBorder=(UIView*)[cellView viewWithTag:210];
    UIView* leftSideBorder=(UIView*)[cellView viewWithTag:209];
    
    cellView.layer.borderWidth=borderwidth;
    cellView.layer.borderColor=[[UIColor darkGrayColor] CGColor];
    cellView.layer.cornerRadius=cornerradius;
    
    if (rightSideBorder!=nil) {
        [rightSideBorder removeFromSuperview];
    }
    
    if (leftSideBorder!=nil) {
        [leftSideBorder removeFromSuperview];
    }
    UILabel *topicLabel=(UILabel*)[cellView viewWithTag:200];
    UILabel *labelPostedBy = (UILabel *)[cellView viewWithTag:201];
    UILabel *labelDate = (UILabel *)[cellView viewWithTag:202];
    
    cellView.frame=CGRectMake(0,0-offsetValueforBorder-4, postTableView.frame.size.width, size.height+45);

   
    
    if (isiPhone5) {
        topicLabel.frame=CGRectMake(26,10+offsetValueforBorder, 550, size.height);
        
        labelPostedBy.frame= CGRectMake(27, size.height+15+offsetValueforBorder, 200, 20);
        
        labelDate.frame=CGRectMake(230,(cellView.frame.size.height/2)-10+offsetValueforBorder, 100, 20);
    }else
    {
        topicLabel.frame=CGRectMake(50,10+offsetValueforBorder, 550, size.height);
        
        labelPostedBy.frame= CGRectMake(55, size.height+15+offsetValueforBorder, 200, 20);
        
        labelDate.frame=CGRectMake(644,(cellView.frame.size.height/2)-10+offsetValueforBorder, 100, 20);
    }
    
    
}

-(void)removeBottomBorderForCommentOnCellView:(UIView*)cellView forNode:(treeNode*)node atIndex:(int)row
{
    cellView.layer.borderWidth=0.0;
    cellView.layer.cornerRadius=0.0;
    
    UILabel *topicLabel=(UILabel*)[cellView viewWithTag:200];
    UILabel *labelPostedBy = (UILabel *)[cellView viewWithTag:201];
    UILabel *labelDate = (UILabel *)[cellView viewWithTag:202];
    
    Comment* commentD=node.value;
    UIFont* font =[UIFont fontWithName:@"helvetica" size:17];
    
    CGSize size = [APP_DELEGATE sizeOfText:commentD.comment withFont:font widthOflabel:560];
    
    UIView* rightSideBorder=(UIView*)[cellView viewWithTag:210];
    UIView* leftSideBorder=(UIView*)[cellView viewWithTag:209];
    
    
    if (leftSideBorder==nil) {
        leftSideBorder=[[UIView alloc] init];
        leftSideBorder.tag=209;
        [leftSideBorder setBackgroundColor:[UIColor darkGrayColor]];
        [cellView addSubview:leftSideBorder];
    }
    
    
    if (rightSideBorder==nil) {
        rightSideBorder=[[UIView alloc] init];
        rightSideBorder.tag=210;
        [rightSideBorder setBackgroundColor:[UIColor darkGrayColor]];
        [cellView addSubview:rightSideBorder];
    }
    cellView.frame=CGRectMake(0,0, postTableView.frame.size.width, size.height+45);
    leftSideBorder.frame=CGRectMake(0, 0, 3, cellView.frame.size.height);
    
    rightSideBorder.frame=CGRectMake(cellView.frame.size.width-borderwidth, 0, 3, cellView.frame.size.height);
    
    
    if (isiPhone5) {
        topicLabel.frame=CGRectMake(26,10, 550, size.height);
        labelPostedBy.frame= CGRectMake(27, size.height+15, 200, 20);
        labelDate.frame=CGRectMake(230,(cellView.frame.size.height/2)-10, 100, 20);
    }else
    {
        topicLabel.frame=CGRectMake(50,10, 550, size.height);
        labelPostedBy.frame= CGRectMake(55, size.height+15, 200, 20);
        labelDate.frame=CGRectMake(644,(cellView.frame.size.height/2)-10, 100, 20);
    }
    
}

-(void)postResponse:(UIButton*)sender
{
    NSIndexPath* index=[self.postTableView indexPathForCell:(UITableViewCell*)sender.superview.superview.superview.superview];
    treeNode* node=[tableArrayModel objectAtIndex:index.row];
    Post* postDetails=node.value;
    
    postCommentOrResponseDic=@{@"type": @"response",@"post":postDetails,@"node":node};
    [messageTextField becomeFirstResponder];
    [self hideCategoryBtnWithPlaceholder:[NSString stringWithFormat:@"Respond to the post: %@",postDetails.topic]];
}

-(void)commentToResponse:(UIButton*)sender
{
    NSIndexPath* index=[self.postTableView indexPathForCell:(UITableViewCell*)sender.superview.superview.superview.superview];
    
    treeNode* node=[tableArrayModel objectAtIndex:index.row];
    PostResponse* responseDetails=node.value;
    
    Post* postDetails=node.parent.value;
    postCommentOrResponseDic=@{@"type": @"comment",@"postid":postDetails.topic_id,@"response":responseDetails,@"node":node};
    
    [messageTextField becomeFirstResponder];
    [self hideCategoryBtnWithPlaceholder:[NSString stringWithFormat:@"comment to the response: %@",responseDetails.response]];
}

-(void)OnSendBtnClick:(UIButton*)sender
{
    
    if ([[postCommentOrResponseDic objectForKey:@"type"] isEqualToString:@"response"])
    {
        if ([self validationForSendMsg:@"Enter the response text" forString:messageTextField.text])
        {
            INDWebServiceModel* sendPostResponseRequest=[[INDWebServiceModel alloc] initWithDelegate:self url:[NSURL URLWithString:[NSString stringWithFormat:@"%@indegene_sales_app/user_posts.jsp",baseUrl]] NameOfWebService:sendPost_Respose];
            Post* postDetails=[postCommentOrResponseDic objectForKey:@"post"];
            
            NSDictionary* postDic=@{@"login":[INDConfigModel shared].userName,@"postid":postDetails.topic_id,@"response":messageTextField.text};
            
            
            [sendPostResponseRequest setPostData:postDic];
            [[INDWebservices shared] startWebserviceOperation:sendPostResponseRequest];
            [messageTextField resignFirstResponder];
            messageTextField.text=nil;
            [self showSendHud];
        }
        
    }else
    {
        if ([self validationForSendMsg:@"Enter the comment" forString:messageTextField.text])
        {
            INDWebServiceModel* sendPostResponseRequest=[[INDWebServiceModel alloc] initWithDelegate:self url:[NSURL URLWithString:[NSString stringWithFormat:@"%@indegene_sales_app/user_posts.jsp",baseUrl]] NameOfWebService:sendComment];
            
            PostResponse* responseDetail=[postCommentOrResponseDic objectForKey:@"response"];
            NSDictionary* postDic=@{@"login":[INDConfigModel shared].userName,@"postid":[postCommentOrResponseDic objectForKey:@"postid"],@"responseid":responseDetail.response_id,@"comment":messageTextField.text};
            
            treeNode* node=[postCommentOrResponseDic objectForKey:@"node"];
            postCommentOrResponseDic=@{@"type": @"comment",@"response":responseDetail, @"node":node,@"comment":messageTextField.text};

            [sendPostResponseRequest setPostData:postDic];
            [[INDWebservices shared] startWebserviceOperation:sendPostResponseRequest];
            
            [messageTextField resignFirstResponder];
            messageTextField.text=nil;

            [self showSendHud];
        }
        
        
    }
}

-(void)hideCategoryBtnWithPlaceholder: (NSString*)placeholder
{
    messageTextField.placeholder=placeholder;
    CategoryForNewPostBtn.hidden=YES;
    sendButton.hidden=NO;
}

-(void)showCategoryBtn
{
  //  messageTextField.text=nil;
    CategoryForNewPostBtn.hidden=NO;
    sendButton.hidden=YES;
    messageTextField.placeholder=createNewPost;
    
}



-(void)showSendHud
{
    sendMessageHud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    sendMessageHud.mode=MBProgressHUDModeIndeterminate;
    sendMessageHud.delegate=self;
    sendMessageHud.labelText=@"Sending";
}

-(void)removeSendAfterSuccess
{
    sendMessageHud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    sendMessageHud.mode = MBProgressHUDModeCustomView;
    sendMessageHud.delegate = self;
    sendMessageHud.labelText = @"Message sent successful";
    sendMessageHud.delegate=nil;
    [sendMessageHud show:YES];
    [sendMessageHud hide:YES afterDelay:2];

}

-(void)removeChildrenNodesOfNode:(treeNode*)node
{
    for (treeNode*childNode in node.children)
    {
        [self removeChildrenNodesOfNode:childNode];
        NSIndexPath* indexPathToBeDeleted=[NSIndexPath indexPathForRow:[self.tableArrayModel indexOfObject:childNode] inSection:0];
        [self.tableArrayModel removeObject:childNode];
      //  [self.postTableView beginUpdates];
        [self.postTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPathToBeDeleted, nil] withRowAnimation:UITableViewRowAnimationTop];
      //  [self.postTableView endUpdates];
        childNode.children=nil;
    }
    node.children=nil;
}

-(void)addRowForTreeNodeinTable: (id)nodeValue atRow: (int)count ofParentNode: (treeNode*)parentNode
{
    treeNode * responseNode=[treeNode new];
    responseNode.value=nodeValue;
    responseNode.children=nil;
    responseNode.parent=parentNode;
    
    if (parentNode.children==nil) {
        parentNode.children=[NSMutableArray new];
    }
    
    [parentNode.children addObject:responseNode];
    
    [self.tableArrayModel insertObject:responseNode atIndex:count];
    [self.postTableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:count inSection:0], nil] withRowAnimation:UITableViewRowAnimationTop];

}


-(BOOL)validationForSendMsg:(NSString*)msg forString:(NSString*)validString
{
    if ([validString isEqualToString:@""]) {
        [self addMsgVC:msg];
        [self performSelector:@selector(removeMsgVC) withObject:self afterDelay:2.0];
        return NO;
    }else
        return YES;
}




- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    [APP_DELEGATE pushiDocViewerWithUrlPath:[URL absoluteString] withViewController:self];
    return NO;
}

#pragma mark-category

-(void)selectCategoryButtonAction

{
    [messageTextField resignFirstResponder];
    if ([self.popoverController isPopoverVisible]) {
        [popoverController setDelegate:nil];
        [self.popoverController dismissPopoverAnimated:YES];
    }
    
    if (self.selectCategoryVCIsVisible == NO)
        [self addSelectCategoryVC];
    else if (self.selectCategoryVCIsVisible == YES)
        [self removeSelectCategoryVC];
}


-(void)addTabBarVC
{
   // UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    self.tabBarVC = (INDTabBarVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"TabBar"];
    
    
    [self addChildViewController:self.tabBarVC];
    
    [self.view addSubview:self.tabBarVC.view];
    
    [self.tabBarVC didMoveToParentViewController:self];
}

-(void)removeTabBarVC
{
    [self.tabBarVC.view removeFromSuperview];
    
    [self.tabBarVC removeFromParentViewController];
}


-(void)addSelectCategoryVC
{
    self.selectCategoryVCIsVisible = YES;
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(SwipeRecognizer:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.indSelectCategoryVC.view addGestureRecognizer:swipeGesture];
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    self.indSelectCategoryVC = (INDSelectCategory *)[self.storyboard instantiateViewControllerWithIdentifier:@"INDSelectCategory"];
    [indSelectCategoryVC setDelegate:self];
    
    self.indSelectCategoryVC.view.layer.opacity = 0.5f;
    self.indSelectCategoryVC.view.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
    self.indSelectCategoryVC.view.layer.opacity = 1.0f;
    
    [self addChildViewController:self.indSelectCategoryVC];
    
    CGRect menuRect = self.indSelectCategoryVC.view.frame;
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        if(isiPhone5)
        {
            self.indSelectCategoryVC.view.frame = CGRectMake(320,0,menuRect.size.width,menuRect.size.height);
            self.indSelectCategoryVC.view.frame = CGRectMake(150,0,menuRect.size.width,menuRect.size.height);
        }else
        {
            self.indSelectCategoryVC.view.frame = CGRectMake(768,0,menuRect.size.width,1024);
            self.indSelectCategoryVC.view.frame = CGRectMake(400,0,menuRect.size.width,930);
        }

    } completion:^(BOOL finished) {
        
    }];
    
    [self.view addSubview:self.indSelectCategoryVC.view];
    
    [self.indSelectCategoryVC didMoveToParentViewController:self];
}

-(void)removeSelectCategoryVC
{
    
    self.selectCategoryVCIsVisible = NO;
    
        CGRect tabbarRect = self.tabBarVC.view.frame;
    CGRect menuRect = self.indSelectCategoryVC.view.frame;
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        
        if (isiPhone5) {
            self.indSelectCategoryVC.view.frame = CGRectMake(150,0,menuRect.size.width,menuRect.size.height);
            self.indSelectCategoryVC.view.frame = CGRectMake(320,0,menuRect.size.width,menuRect.size.height);
        }else
        {
            self.indSelectCategoryVC.view.frame = CGRectMake(400,0,menuRect.size.width,930);
            self.indSelectCategoryVC.view.frame = CGRectMake(768,0,menuRect.size.width,930);
             self.tabBarVC.view.frame = CGRectMake(0,tabbarRect.origin.y,tabbarRect.size.width,tabbarRect.size.height);
        }
        
        
        
       
        
        //        self.indMenuVC.view.frame = CGRectMake(160,0,160,568);
        //        self.indMenuVC.view.frame = CGRectMake(320,0,0,568);
        //
        //        self.tabBarVC.view.frame = CGRectMake(0,0,320,568);
        
    } completion:^(BOOL finished) {
        
        [self.indSelectCategoryVC.view removeFromSuperview];
        
        [self.indSelectCategoryVC removeFromParentViewController];
    }];
}

#pragma mark - Gesture Related Method's

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([touch.view isKindOfClass:[UIView class]])
        return YES;
    
    return NO;
}


- (void) SwipeRecognizer:(UISwipeGestureRecognizer *)sender
{
    NSLog(@"touchedswipe");
    if ( sender.direction == UISwipeGestureRecognizerDirectionLeft ){
        
        NSLog(@" *** WRITE CODE FOR SWIPE LEFT ***");
        
    }
    if ( sender.direction == UISwipeGestureRecognizerDirectionRight ){
        
        NSLog(@" *** WRITE CODE FOR SWIPE RIGHT ***");
        
        [self removeSelectCategoryVC];
        
    }
    if ( sender.direction== UISwipeGestureRecognizerDirectionUp ){
        
        NSLog(@" *** WRITE CODE FOR  SWIPE UP ***");
        
    }
    if ( sender.direction == UISwipeGestureRecognizerDirectionDown ){
        
        NSLog(@" *** SWIPE DOWN ***");
        
    }
}

-(void)addMsgVC:(NSString*)message
{
    if(![[self.view subviews]containsObject:msgVC.view])
    {
        
        self.msgVC = (INDMessageVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"INDMessageVC"];
        
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
        msgVC.msgLabel.hidden=YES;
        [UIView animateWithDuration:0.50 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.msgVC.view.frame = CGRectMake(0,60,768,50);
            self.msgVC.view.frame = CGRectMake(0,60,768,0);
            
        } completion:^(BOOL finished) {
            
            [self.msgVC.view removeFromSuperview];
            [self.msgVC removeFromParentViewController];
        }];
    }
    
}
-(void)showlabel:(BOOL)isShow
{
    UILabel* labelmsg=(UILabel*)[self.view viewWithTag:500];
    
    if (isShow) {
        
        if (labelmsg==nil)
        {
            labelmsg=[[UILabel alloc] initWithFrame:CGRectMake(0, 402, 768, 60)];
            labelmsg.tag=500;
            labelmsg.textAlignment =  NSTextAlignmentCenter;
            labelmsg.textColor = [UIColor blackColor];
            labelmsg.backgroundColor = [UIColor clearColor];
            labelmsg.font = [UIFont fontWithName:@"Helvetica" size:(25.0)];
            [self.view addSubview:labelmsg];
        }
        labelmsg.text=@"No Post Avalible";
    }
    else{
        if ([[self.view subviews]containsObject:labelmsg]) {
            [labelmsg removeFromSuperview];
        }
    }
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
