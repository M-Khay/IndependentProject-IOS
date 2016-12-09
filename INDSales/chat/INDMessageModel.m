//
//  INDMessageModel.m
//  INDSales
//
//  Created by parth on 23/04/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import "INDMessageModel.h"

@implementation INDMessageModel
@synthesize sent;
@synthesize message;
@synthesize when;
@synthesize messageid;
@synthesize contact;

-(NSString*)description
{
    NSString*description;
    
    if (contact==nil) {
        description=[NSString stringWithFormat:@"{\nmessageid: %@\nmessage: %@\nwhen: %@\nsent: %hhd\n}",self.messageid,self.message,self.when,self.sent];
    }
    else
       description=[NSString stringWithFormat:@"{\nmessageid: %@\nwhen: %@\nsent: %hhd\ncontact:\n{%@\n}\n}",self.messageid,self.when,self.sent,self.contact];
    
    
    return description;
}
@end
