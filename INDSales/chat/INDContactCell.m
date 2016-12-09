//
//  INDContactCell.m
//  INDSales
//
//  Created by parth on 07/05/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import "INDContactCell.h"

@implementation INDContactCell
@synthesize contactBubbleIV,contactName,button,sent,whenLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        contactBubbleIV=[[UIImageView alloc] init];
        contactBubbleIV.userInteractionEnabled=YES;
        button=[[UIButton alloc] initWithFrame:CGRectMake(15, 18, 215, 50)];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        [button setBackgroundColor:[UIColor colorWithRed:(248/256.0) green:(248/256.0) blue:(248/256.0) alpha:1.0]];
        whenLabel=[[UILabel alloc] init];
        whenLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        whenLabel.textColor = [UIColor darkGrayColor];
        whenLabel.backgroundColor = [UIColor clearColor];
        
        [contactBubbleIV addSubview:button];
        contactBubbleIV.userInteractionEnabled=YES;
       // [self.contentView addSubview:contactBubbleIV];
        
        [self addSubview:whenLabel];
        
        [self addSubview:contactBubbleIV];


    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setSent:(BOOL)sentMessage
{
    sent=sentMessage;
    if (sentMessage)
    {
        contactBubbleIV.image=[[UIImage imageNamed:@"leftCBubbleSelected.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
        contactBubbleIV.frame=CGRectMake(self.frame.size.width-250, 25, 245, 100);
        whenLabel.frame=CGRectMake(self.frame.size.width-200, 10, 200, 20);
        
    }
    else
    {
        contactBubbleIV.image=[[UIImage imageNamed:@"rightCBubbleSelected.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
        contactBubbleIV.frame=CGRectMake(3, 25, 250, 100);
        whenLabel.frame=CGRectMake(50,10,200, 20);

        
    }
   // contactBubbleIV.userInteractionEnabled=YES;

}

- (void)layoutSubviews
{
    if (sent)
    {
        contactBubbleIV.frame=CGRectMake(self.frame.size.width-245, 25, 250, 100);
        whenLabel.frame=CGRectMake(self.frame.size.width-200, 10, 200, 20);
    }
}


@end
