//
//  INDWebServiceModel.m
//  PfizerMobileApp
//
//////  Created by Kush on 13/11/16.
//
//

#import "INDWebServiceModel.h"

@interface INDWebServiceModel ()
@end


@implementation INDWebServiceModel
@synthesize serviceName;
@synthesize operation;
@synthesize postData;

-(id)initWithDelegate: (id)delgate url: (NSURL*)serviceUrl NameOfWebService: (webServiceName) webServiceName
{
    self = [super init];
    
    self.delegate=delgate;

    self.url=serviceUrl;
    
    serviceName=webServiceName;
    self.postData = nil;
    return self;

}


@end
