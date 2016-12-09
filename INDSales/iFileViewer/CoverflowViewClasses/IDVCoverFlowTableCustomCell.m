//
//  IDVCoverFlowTableCustomCell.m
//  iDocViewer
//
//  Created by Krishna on 11/11/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import "IDVCoverFlowTableCustomCell.h"

@implementation IDVCoverFlowTableCustomCell
@synthesize otl_LblColumn1,otl_LblColumn2,otl_LblColumn3;
@synthesize otl_ShareBtn,otl_FavouriteBtn;
@synthesize coverFlowCustomCellDelegate;
@synthesize path,file;
@synthesize otl_ImageViewLock;
@synthesize favButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onClickAddToFavourite:(id)sender
{
    favButton=(UIButton*)sender;
    if(favButton.isSelected)
    {
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"iDocViewer"
                                                                message:@"Do you want to remove this file from favourites?"
                                                                delegate:self
                                                                cancelButtonTitle:@"Cancel"
                                                                otherButtonTitles:@"OK",nil];
        [myAlert show];
    }
    else
    {
        [self.coverFlowCustomCellDelegate saveFavouriteFilesAtPath:self.file];
        favButton.selected=YES;
    }
}

- (IBAction)onClickShare:(id)sender
{
    [coverFlowCustomCellDelegate shareFileAtPath:self.file];

}


# pragma mark
#pragma AlertView Methods..

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"])
    {
        [self.coverFlowCustomCellDelegate removeFavouriteFilesAtPath:self.file];
       // [otl_FavouriteBtn setBackgroundImage:[UIImage imageNamed:@"favourite"] forState:UIControlStateNormal];
      // favFlag=0;
        favButton.selected=NO;
        
    }
    
}


@end
