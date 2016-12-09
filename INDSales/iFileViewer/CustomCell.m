//
//  CustomCell.m
//  iDocViewer
//
//  Created by Krishna on 15/11/16.
//

#import "CustomCell.h"

@implementation CustomCell

@synthesize otl_ImgView;
@synthesize otl_FileSize;
@synthesize otl_CreationDate;
@synthesize otl_FileName;
@synthesize otl_BtnFavourite;
@synthesize otl_BtnShare;
//@synthesize favFlag;
@synthesize customCellDelegateObj;
@synthesize cellIndexPath;
@synthesize  otl_LockButton;
@synthesize otl_ImageViewLock;
@synthesize isLocked;
@synthesize favButton;
@synthesize lockButton;


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        // favFlag=0;
        isLocked = 0;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onClickShareFile:(id)sender
{
   
   // UIButton *btn=sender;
    [customCellDelegateObj shareFileWithObject:self.file];
}

- (IBAction)onClickAddToFavourite:(id)sender
{
   favButton = (UIButton*)sender;
    
    if(favButton.isSelected)
    {
        UIAlertView *myAlert = [[UIAlertView alloc]
                                initWithTitle:@"iDocViewer"
                                message:@"Do you want to remove the file from favourites?"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                otherButtonTitles:@"OK",nil];
        [myAlert setTag:1];
        [myAlert show];
    }
    else
    {
        [self.customCellDelegateObj saveFavouriteFiles:self.file];
        favButton.selected=YES;
    }
 }

- (IBAction)onClickLockFile:(id)sender
{
    lockButton = (UIButton*)sender;
    
    if(lockButton.isSelected)
    {
        [self.customCellDelegateObj removePasswordFromFile:self.file];
        lockButton.selected=NO;
    }
    else
    {
        [self.customCellDelegateObj addPasswordToFile:self.file];
        lockButton.selected=YES;
    }

}

# pragma mark
#pragma AlertView Methods..

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==1)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"OK"])
        {
        [self.customCellDelegateObj removeFavouriteFiles:self.file];
            favButton.selected=NO;
        }
    }
    
}

@end
