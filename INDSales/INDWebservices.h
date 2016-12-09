//
//  INDWebservices.h
//  PfizerMobileApp
//
//  Created by kush on 16/10/16.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "INDWebServiceModel.h"
@interface INDWebservices : NSObject


+(INDWebservices*)shared;

-(id)init;
-(void)startWebserviceOperation: (INDWebServiceModel*) webserviceOperationObject;
-(void)cancelOperation: (INDWebServiceModel*) webserviceOperationObject;
-(void)message:(NSString*)msg;
-(void)pauseOperation: (INDWebServiceModel*) webserviceOperationObject;
-(void)resumeOperation: (INDWebServiceModel*) webserviceOperationObject;
-(BOOL)isWebServiceOperationExecuting: (INDWebServiceModel*)webServiceModel;

@end
