//
//  HttpProtocolManager.h 
//

#import <Foundation/Foundation.h>  
#import "AFNetworkingHttpContants.h"
@class AFCustomRequestOperationManager;


@interface AFNetworkHttpRequestManager : NSObject{
    NSMutableDictionary *queueDictionary; }
@property (nonatomic,readonly) NSMutableDictionary *queueDictionary;

+(AFNetworkHttpRequestManager *)shareManager;

+(AFCustomRequestOperationManager *)getAFHTTPRequestOperationManager:(ResponseProtocolType)responseType;

+(AFCustomRequestOperationManager *)loadManagerStr:(NSString *)managerKey responseType:(ResponseProtocolType)responseType asyncwork:(BOOL)asyncwork;

+(void)cancelQueue:(NSInteger)queueId;
+(void)cancelQueueStr:(NSString *)queueId;

+(void)cancelQueue:(NSInteger)queueId requestId:(NSInteger)requestId;
+(void)cancelQueueStr:(NSString *)queueId requestId:(NSInteger)requestId;

@end
