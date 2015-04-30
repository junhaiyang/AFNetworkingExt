//
//  AFCustomRequestOperationManager.h
//  AFNetworking-Base
//
//  Created by yangjunhai on 14-3-27.
//  Copyright (c) 2014年 soooner. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@class AFCustomRequestOperation;

// kAFNetworking_HTTP_METHOD

static NSString *const kAFNetworking_HTTP_GET = @"GET";
static NSString *const kAFNetworking_HTTP_POST = @"POST";
static NSString *const kAFNetworking_HTTP_DELETE = @"DELETE";

static NSString *const kAFNetworking_HTTP_PATCH = @"PATCH";
static NSString *const kAFNetworking_HTTP_HEAD = @"HEAD";
static NSString *const kAFNetworking_HTTP_PUT = @"PUT";
static NSString *const kAFNetworking_HTTP_TRACE = @"TRACE";
static NSString *const kAFNetworking_HTTP_OPTIONS = @"OPTIONS";
static NSString *const kAFNetworking_HTTP_LOCK = @"LOCK";
static NSString *const kAFNetworking_HTTP_MKCOL = @"MKCOL";
static NSString *const kAFNetworking_HTTP_COPY = @"COPY";
static NSString *const kAFNetworking_HTTP_MOVE = @"MOVE";


@protocol AFNetworkingRequestDelegate <NSObject>

@property (nonatomic,strong) AFCustomRequestOperation *operation;
 

@end

@interface AFCustomRequestOperationManager : AFHTTPRequestOperationManager

@property (nonatomic,assign) BOOL asyncwork;
 

- (AFHTTPRequestOperation *)request:(NSString *)URLString
                             method:(NSString *)method
                         parameters:(id)parameters
                           delegate:(id<AFNetworkingRequestDelegate>)delegate
                            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)request:(NSString *)URLString
                             method:(NSString *)method
                               body:(NSData *)body
                            delegate:(id<AFNetworkingRequestDelegate>)delegate
                            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)request:(NSString *)URLString
                             method:(NSString *)method
                         parameters:(id)parameters
          constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                            delegate:(id<AFNetworkingRequestDelegate>)delegate
                            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

-(AFHTTPRequestOperation *)executeRequest:(NSMutableURLRequest *)request
                                 delegate:(id<AFNetworkingRequestDelegate>)delegate
                                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


@end
