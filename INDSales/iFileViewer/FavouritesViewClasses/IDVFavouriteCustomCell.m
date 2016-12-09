//
//  IDVFavouriteCustomCell.m
//  iDocViewer
//
//  Created by Krishna on 21/10/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import "IDVFavouriteCustomCell.h"

@implementation IDVFavouriteCustomCell
@synthesize otl_BtnShare,otl_ImageView,otl_TextFileName,otl_TextFileSize,otl_TextFileCreationDate;
@synthesize favCustomCellDelegateObj,path,otl_imageLock;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
       // self.otl_BtnFavourite.hidden=YES;
        [self.otl_ImageView setContentMode:UIViewContentModeScaleAspectFit];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onClickShare:(id)sender
{
   
    [self.favCustomCellDelegateObj shareFileWithObject:self.file];
}


# pragma mark
#pragma AlertView Methods..

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"])
    {
        [favCustomCellDelegateObj removeFavouriteFiles:self.file];
    }
}


@end
