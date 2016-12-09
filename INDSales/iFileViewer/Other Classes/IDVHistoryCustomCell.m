//
//  IDVHistoryCustomCell.m
//  iDocViewer
//
//  Created by Krishna on 25/10/13.
//  Copyright (c) 2013 Indegene. All rights reserved.
//

#import "IDVHistoryCustomCell.h"

@implementation IDVHistoryCustomCell
@synthesize otl_HIstoryTextLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
       /* 
        myLabel.numberOfLines = 0;
        
        CGRect currentFrame = otl_HIstoryTextLabel.frame;
        CGSize max = CGSizeMake(otl_HIstoryTextLabel.frame.size.width, 500);
        CGSize expected = [myString sizeWithFont:otl_HIstoryTextLabel.font constrainedToSize:max lineBreakMode:otl_HIstoryTextLabel.lineBreakMode];
        currentFrame.size.height = expected.height;
        otl_HIstoryTextLabel.frame = currentFrame; */

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
