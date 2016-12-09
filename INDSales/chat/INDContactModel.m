//
//  INDContactModel.m
//  INDSales
//
//  Created by parth on 05/05/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import "INDContactModel.h"

@implementation INDContactModel
@synthesize fname;
@synthesize lname;
@synthesize company;
@synthesize title;
@synthesize country;
@synthesize ccode;
@synthesize altcontact;
@synthesize contact;
@synthesize email;
@synthesize other;
-(NSString*)description
{
    NSString* description=[NSString stringWithFormat:@"first name: %@\nlast name: %@\ncompany: %@\ntitle: %@\ncountry: %@\ncountry code: %@\nContact: %@\naltcontactNo: %@\nemail: %@\nother %@",self.fname,self.lname,self.company,self.title,self.country,self.ccode,self.contact,self.altcontact,self.email,self.other];
    
    return description;
}

@end
