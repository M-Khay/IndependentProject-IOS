//
//  INDDataModel.h
//  INDSales
//
//////  Created by Kush on 13/11/16.
//  Copyright (c) 2014 Indegene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INDDataModel : NSObject

@property(strong, nonatomic) NSString *fileName;
//@property(strong, nonatomic) NSString *fileSize;
@property(unsafe_unretained, nonatomic) float fileSize;
//@property(strong, nonatomic) NSString *fileCreationDate;
@property(strong, nonatomic) NSDate *fileCreationDate;
@property(strong, nonatomic) NSString *fileFullPath;
@property(strong, nonatomic) NSString *fileThumbnailPath;
@property(strong, nonatomic) UIImage *fileThumbnail;
@property(unsafe_unretained, nonatomic) BOOL isFavourite;
@property(unsafe_unretained, nonatomic) BOOL isLocked;
@property(unsafe_unretained, nonatomic) BOOL isFolder;

@property(strong, nonatomic) NSString *favouritePath;

@end
