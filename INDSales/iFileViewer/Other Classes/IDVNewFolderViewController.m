//
//  IDVNewFolderViewController.m
//  iDocViewer
//
//  Created by Krishna on 25/11/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import "IDVNewFolderViewController.h"

@interface IDVNewFolderViewController ()

@end

@implementation IDVNewFolderViewController
@synthesize delegate;
@synthesize otl_FolderName;

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
    [otl_FolderName becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickSetPassword:(id)sender
{
    NSLog(@"otl_FolderName.text=%@",otl_FolderName.text);
    [delegate createNewFolderWithName:otl_FolderName.text];
    otl_FolderName.text=@"";
   // [delegate cancelNewFolderPopover];
}

- (IBAction)onClickCancel:(id)sender
{
    [delegate cancelNewFolderPopover];
}
@end
