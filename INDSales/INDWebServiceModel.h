//
//  INDWebServiceModel.h
//  PfizerMobileApp
//
//////  Created by Kush on 13/11/16.
//
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"
@class INDWebServiceModel;

@protocol webServiceResponceProtocol <NSObject>

@optional
-(void)completionOperationWithSuccess: (id)operation responseData:(id)responseObject webServiceOperationObject:(INDWebServiceModel*) webServiceOperationObject;
-(void)completionOperationWithFailure: (id)operation error:(NSError*)error webServiceOperationObject:(INDWebServiceModel*) webServiceOperationObject;
-(void)downloadProgress:(NSUInteger) bytesRead  totalBytesRead: (long long)tbytes totalBytesExpectedToRead: (long long) tbytesExpected;
@end


typedef enum {
    LoginService=1,
    RSSService,
    POSTService,
    post_Response,
    sendPost_Respose,
    requestinfo,
    sendComment,
    sendToken,
    getUser,
    getMessages,
    sendMessage,
    getliveChat
}webServiceName;

@interface INDWebServiceModel : NSObject

@property (strong,nonatomic) NSURL* url;
@property (weak)id<webServiceResponceProtocol>delegate;
@property (assign,nonatomic)webServiceName serviceName;
@property (strong,nonatomic)AFHTTPRequestOperation* operation;
@property (strong,nonatomic) NSDictionary*postData;
-(id)initWithDelegate: (id)delgate url: (NSURL*)serviceUrl NameOfWebService: (webServiceName) webServiceName;
@property (strong,nonatomic)NSString* downloadPath;

@end