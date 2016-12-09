//
//  INDMessageModel.h
//  INDSales
//
//  Created by parth on 23/04/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INDContactModel.h"
@interface INDMessageModel : NSObject
@property(nonatomic,strong)NSString* messageid;
@property(nonatomic,assign)BOOL sent;
@property(nonatomic,strong)NSString* message;
@property(nonatomic,strong)NSString* when;
@property(nonatomic,strong)INDContactModel* contact;

@end
