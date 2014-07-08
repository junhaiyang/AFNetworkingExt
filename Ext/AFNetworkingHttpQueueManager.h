//
//  HttpProtocolManager.h
//  LiveBroadcast
//
//  Created by junhai on 13-1-24.
//  Copyright (c) 2013年 mRocker. All rights reserved.
//

#import <Foundation/Foundation.h>  
#import "AFNetworkingHttpContants.h"
@class AFCustomRequestOperationManager;


@interface AFNetworkHttpRequestManager : NSObject{
    NSMutableDictionary *queueDictionary; }
@property (nonatomic,readonly) NSMutableDictionary *queueDictionary;

+(AFNetworkHttpRequestManager *)shareManager;

+(AFCustomRequestOperationManager *)loadManagerStr:(NSString *)managerKey responseType:(ResponseProtocolType)responseType asyncwork:(BOOL)asyncwork;

+(void)cancelQueue:(NSInteger)queueId;
+(void)cancelQueueStr:(NSString *)queueId;

+(void)cancelQueue:(NSInteger)queueId requestId:(NSInteger)requestId;
+(void)cancelQueueStr:(NSString *)queueId requestId:(NSInteger)requestId;

@end
