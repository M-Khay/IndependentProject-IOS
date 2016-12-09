
//

#import "INDLiveChatModel.h"

@implementation INDLiveChatModel
@synthesize delegate;

+ (INDLiveChatModel*)shared {
    
    static INDLiveChatModel *sharedclass = nil;
    
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

-(void)newChatHasArrivedOfLoginId:(NSString*)loginId
{
    //call the protocol for new chat
    
    [delegate newMessageRecievedOfLoginId:loginId];
}


@end
