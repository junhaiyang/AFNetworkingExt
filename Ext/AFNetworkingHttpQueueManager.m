//
//  HttpProtocolManager.m 
//

#import "AFNetworkingHttpQueueManager.h"
#import "AFCustomRequestOperationManager.h"
#import "AFDownloadRequestOperationManager.h"
#import "AFCustomRequestOperation.h"



@interface AFNetworkHttpRequestManager(){
    
} 
@end

@implementation AFNetworkHttpRequestManager
@synthesize queueDictionary;


static NSObject *lock;

- (id)init
{
    self = [super init];
    if (self) {
      queueDictionary=[[NSMutableDictionary alloc] init];   
    }
    return self;
}


+(AFNetworkHttpRequestManager *)shareManager{
    
    static AFNetworkHttpRequestManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AFNetworkHttpRequestManager alloc] init];
        lock=[[NSObject alloc] init];
    });
    
    return sharedInstance;
}

+(AFHTTPRequestOperationManager *)loadManagerStr:(NSString *)managerKey responseType:(ResponseProtocolType)responseType asyncwork:(BOOL)asyncwork{
    
    @synchronized(lock){
        NSMutableDictionary *queueDictionary=[AFNetworkHttpRequestManager shareManager].queueDictionary;
        if(managerKey==nil)
            return  nil;
        
        AFCustomRequestOperationManager *manager=[queueDictionary objectForKey:managerKey];
        if(!manager){
           manager=[AFNetworkHttpRequestManager getAFHTTPRequestOperationManager:responseType];
            manager.asyncwork =asyncwork;
            [queueDictionary setObject:manager forKey:managerKey];
        }
        
        return manager;
    }
}


+(AFCustomRequestOperationManager *)getAFHTTPRequestOperationManager:(ResponseProtocolType)responseType{
    if (responseType == ResponseProtocolTypeFile){
        return [AFDownloadRequestOperationManager manager];
    }
    
    return [AFCustomRequestOperationManager manager];
}

+(void)cancelQueueStr:(NSString *)queueId{
    @synchronized(lock){
        NSMutableDictionary *queueDictionary=[AFNetworkHttpRequestManager shareManager].queueDictionary;
        NSString *key=[NSString stringWithFormat:@"%@-",queueId];
        for (NSString *_key in queueDictionary) {
            if([_key hasPrefix:key]){
                
                AFCustomRequestOperationManager *manager=[queueDictionary objectForKey:_key];
                [manager.operationQueue cancelAllOperations];
            }
        }
    }
}

+(void)cancelQueue:(NSInteger)queueId{
    
    NSString *key=[NSString stringWithFormat:@"%ld",(long)queueId];
    [AFNetworkHttpRequestManager cancelQueueStr:key];
    
}


+(void)cancelQueue:(NSInteger)queueId requestId:(NSInteger)requestId{
    NSString *key=[NSString stringWithFormat:@"%d",(int)queueId];
    [AFNetworkHttpRequestManager cancelQueueStr:key requestId:requestId];
}

+(void)cancelQueueStr:(NSString *)queueId requestId:(NSInteger)requestId{
    @synchronized(lock){
        NSMutableDictionary *queueDictionary=[AFNetworkHttpRequestManager shareManager].queueDictionary;
        NSString *key=[NSString stringWithFormat:@"%@-",queueId];
        for (NSString *_key in queueDictionary) {
            if([_key hasPrefix:key]){
                NSLog(@"cancelQueue :%@ requestId :%d",_key,(int)requestId);
                
                AFCustomRequestOperationManager *manager=[queueDictionary objectForKey:_key];
                
                NSArray *operations=[manager.operationQueue operations];
                for (NSOperation *operation in operations) {
                    if([operation isKindOfClass:[AFCustomRequestOperation class]]){
                        if (((AFCustomRequestOperation *)operation).requestId==requestId) {
                            NSLog(@"cancel :%@ requestId :%d",operation,(int)requestId);
                            [operation cancel];
                        }
                    }
                    
                }
            }
        }
    }
}
 

@end
