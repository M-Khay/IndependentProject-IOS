//
//  IDVCollectionVIewCustomCell.m
//  iDocViewer
//
///  Created by Kush on 04/10/16.


#import "IDVCollectionVIewCustomCell.h"
//static UIImage *deleteButtonImg;
@implementation IDVCollectionVIewCustomCell
@synthesize path;
@synthesize otl_BtnShare,otl_BtnFavourite,otl_ImageView,otl_LblFileName,otl_LblSize,otl_CreationDate;
@synthesize deleteButton;
//@synthesize favFlag;
@synthesize collectionViewCellDelegate;
@synthesize otl_imageLock;
@synthesize otl_stripView;
@synthesize favButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
        return self;
    }

- (id)initWithCoder:(NSCoder *)encoder
{
    self = [super initWithCoder:encoder];
    if (self) {
        [self commonInit];
       // [self applyLayoutAttributes: ];
    }
    return self;
}
- (void)commonInit
{
    // set up your instance
   // self.otl_ImageView.layer.cornerRadius = 5;
   // self.otl_ImageView.layer.borderWidth = 1;
   // self.otl_ImageView.layer.borderColor = [UIColor blackColor].CGColor;
    //[self.otl_ImageView setFrame:AVMakeRectWithAspectRatioInsideRect(self.otl_ImageView.frame.size, self.otl_ImageView.frame)];
    
    self.layer.masksToBounds = NO;
    [[self layer] setShadowColor:[[UIColor lightGrayColor] CGColor]];
    
    [[self layer] setShadowOffset:CGSizeMake(0,0)];
    [[self layer] setShadowOpacity:.2];
    
    UIBezierPath *path1 = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:12];
    [[self layer] setShadowPath:[path1 CGPath]];
    
    deleteButton= [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(0,0, 30, 30);
    [self.deleteButton setImage:[UIImage imageNamed:@"deleteButtonImg.png"] forState:UIControlStateNormal];
    [self addSubview:self.deleteButton];
}


- (IBAction)onClickAddToFavourite:(id)sender
{
   favButton=(UIButton*)sender;
  
    
    if(favButton.isSelected)
    {
        UIAlertView *myAlert = [[UIAlertView alloc]
                                initWithTitle:@"iDocViewer"
                                message:@"Do you want to remove this file from favourites?"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                otherButtonTitles:@"OK",nil];
        [myAlert show];
    }
    else
    {
        [self.collectionViewCellDelegate saveFavouriteFilesAtPath:self.file];
        favButton.selected=YES;
    }

}

# pragma mark
#pragma AlertView Methods..

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"])
    {
        [self.collectionViewCellDelegate removeFavouriteFilesAtPath:self.file];
       // [otl_BtnFavourite setBackgroundImage:[UIImage imageNamed:@"favourite"] forState:UIControlStateNormal];
       // self.favFlag=0;
        favButton.selected=NO;
        
    }
    
}

- (IBAction)onClickShare:(id)sender
{
   // UIButton *btn=sender;

   // NSLog(@"sharing files...%ld",(long)btn.tag);
    [collectionViewCellDelegate shareFileAtPath:self.file];
}

- (void)delete:(id)sender
{
    if([self.delegate respondsToSelector:@selector(delete:forCell:)])
    {
        [self.delegate delete:sender forCell:self];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    NSLog(@"canPerformAction");
    // The selector(s) should match your UIMenuItem selector
    
    NSLog(@"Sender: %@", sender);
    if (action == @selector(delete:))
    {
        NSLog(@"deleting files...");

        return YES;
    }
    return NO;
}


@end
