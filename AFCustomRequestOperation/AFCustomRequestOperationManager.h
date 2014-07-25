//
//  AFCustomRequestOperationManager.h
//  AFNetworking-Base
//
//  Created by yangjunhai on 14-3-27.
//  Copyright (c) 2014年 soooner. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface AFCustomRequestOperationManager : AFHTTPRequestOperationManager

@property (nonatomic,assign) BOOL asyncwork;

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                            body:(NSData *)body
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
