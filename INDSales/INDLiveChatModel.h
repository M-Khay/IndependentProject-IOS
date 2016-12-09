//
//

#import <Foundation/Foundation.h>

@protocol liveChatProtocol <NSObject>

@optional

-(void)newMessageRecievedOfLoginId:(NSString*)loginId;

@end

@interface INDLiveChatModel : NSObject
@property(weak)id<liveChatProtocol> delegate;
+ (INDLiveChatModel*)shared;
-(void)newChatHasArrivedOfLoginId:(NSString*)loginId;

@end
