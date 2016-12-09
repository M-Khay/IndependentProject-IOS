//
//  INDAppConfigObject.m
//  
//
//  Created by Kush on 21/11/16.//
//

#import "INDConfigModel.h"

@interface INDConfigModel()
@end


@implementation INDConfigModel

@synthesize userName;
@synthesize password;
@synthesize deviceToken;
@synthesize baseUrlPath;
@synthesize category,requestInfoCategory;

+ (INDConfigModel*)shared {
    
    static INDConfigModel *sharedclass = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedclass = [[self alloc] init];
    });
    
    return sharedclass;
}

- (id)init
{
    
    if (self = [super init]) {
        
    }
    
    return self;
}

-(void)resetConfigModel
{
    self.userName=nil;
    self.password=nil;
    self.category=nil;
    self.requestInfoCategory=nil;
}


@end
