//
//  INDConstants.h
//  INDSales
//
//  Created by Kush on 04/10/16.
//
#import <Foundation/Foundation.h>

#define baseUrl [[INDConfigModel shared] baseUrlPath]

#define documentsDirectoryPath (NSString*)[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE
#define isiPhone  (UI_USER_INTERFACE_IDIOM() == 0)?TRUE:FALSE