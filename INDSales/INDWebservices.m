//
//  INDWebservices.m
//  PfizerMobileApp
//
//  Created by Kush on 16/10/16.
//
//

#import "INDWebservices.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"

@implementation INDWebservices

+ (INDWebservices*)shared {
    
    static INDWebservices *sharedclass = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedclass = [[self alloc] init];
    });
    
    return sharedclass;
}

- (id)init {
    
    if (self = [super init]) {
    
    }
    
    return self;
}

-(void)startWebserviceOperation: (INDWebServiceModel*) webserviceOperationObject
{
    if (webserviceOperationObject.postData)
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager POST:[webserviceOperationObject.url absoluteString]  parameters:webserviceOperationObject.postData success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            if ([webserviceOperationObject.delegate respondsToSelector:@selector(completionOperationWithSuccess:responseData:webServiceOperationObject:)])
                    [webserviceOperationObject.delegate completionOperationWithSuccess:operation responseData:responseObject webServiceOperationObject:webserviceOperationObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            if([webserviceOperationObject.delegate respondsToSelector:@selector(completionOperationWithFailure:error:webServiceOperationObject:)])
                [webserviceOperationObject.delegate completionOperationWithFailure:operation error:error webServiceOperationObject:webserviceOperationObject];
        }];
        
    } else {
        
        AFHTTPRequestOperation* operation=[[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:webserviceOperationObject.url]];
        
        webserviceOperationObject.operation=operation;
        [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:nil];
        
        if (webserviceOperationObject.downloadPath!=nil) {
            
            operation.outputStream=[NSOutputStream outputStreamToFileAtPath:webserviceOperationObject.downloadPath append:YES];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:[webserviceOperationObject.downloadPath stringByDeletingLastPathComponent]])
                
                [[NSFileManager defaultManager] createDirectoryAtPath:[webserviceOperationObject.downloadPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
            
        }
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([webserviceOperationObject.delegate respondsToSelector:@selector(completionOperationWithSuccess:responseData:webServiceOperationObject:)])
                [webserviceOperationObject.delegate completionOperationWithSuccess:operation responseData:responseObject webServiceOperationObject:webserviceOperationObject];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if([webserviceOperationObject.delegate respondsToSelector:@selector(completionOperationWithFailure:error:webServiceOperationObject:)])
                [webserviceOperationObject.delegate completionOperationWithFailure:operation error:error webServiceOperationObject:webserviceOperationObject];
        }];
        
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            
            if([webserviceOperationObject.delegate respondsToSelector:@selector(downloadProgress:totalBytesRead:totalBytesExpectedToRead:)])
                [webserviceOperationObject.delegate downloadProgress:bytesRead totalBytesRead:totalBytesRead totalBytesExpectedToRead:totalBytesExpectedToRead];
        }];
        
        [operation start];
    }
}


-(void)cancelOperation: (INDWebServiceModel*) webserviceOperationObject
{
    webserviceOperationObject.delegate = nil;
    
    if ([webserviceOperationObject.operation isExecuting])
        [webserviceOperationObject.operation cancel];
}

//Alert Message Methods

-(void)message:(NSString*)msg
{
    
    UIAlertView*msgAlertView= [[UIAlertView alloc]initWithTitle:@"Message" message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    [msgAlertView show];
    
    [self performSelector:@selector(cancelAlert:) withObject:msgAlertView afterDelay:2.0];
    
    
}

-(void)cancelAlert:(UIAlertView*)alert
{
    
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    
}
-(void)pauseOperation: (INDWebServiceModel*) webserviceOperationObject
{
    if ([webserviceOperationObject.operation isExecuting]) {
        
        [webserviceOperationObject.operation pause];
        
    }
}

-(void)resumeOperation: (INDWebServiceModel*) webserviceOperationObject
{
    [webserviceOperationObject.operation resume];
}
-(BOOL)isWebServiceOperationExecuting: (INDWebServiceModel*)webServiceModel
{
    return [webServiceModel.operation isExecuting];
}


@end
