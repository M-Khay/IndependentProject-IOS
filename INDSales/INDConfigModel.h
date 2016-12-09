//
//  INDAppConfigObject.h
//  
//
//  Created by kush on 21/10/16.
//
//

#import <Foundation/Foundation.h>

@interface INDConfigModel : NSObject
@property(strong,nonatomic)NSString* userName;
@property(strong,nonatomic)NSString* password;
@property(strong,nonatomic)NSString* deviceToken;
@property(strong,nonatomic)NSString* baseUrlPath;
@property(strong,nonatomic)NSArray* category;
@property(strong,nonatomic)NSArray* requestInfoCategory;

+ (INDConfigModel*)shared;
-(void)resetConfigModel;
- (id)init;

@end
