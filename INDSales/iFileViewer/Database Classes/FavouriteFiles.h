//
//  FavouriteFiles.h
//  iDocViewer
//
//  Created by Krishna on 10/01/14.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FavouriteFiles : NSManagedObject

@property (nonatomic, retain) NSString * filepath;

@end
