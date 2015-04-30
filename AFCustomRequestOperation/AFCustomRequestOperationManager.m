//
//  AFCustomRequestOperationManager.m
//  AFNetworking-Base
//
//  Created by yangjunhai on 14-3-27.
//  Copyright (c) 2014年 soooner. All rights reserved.
//

#import "AFCustomRequestOperationManager.h"
#import "AFCustomRequestOperation.h"

static dispatch_queue_t request_operation_completion_queue() {
    static dispatch_queue_t af_url_request_operation_completion_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_url_request_operation_completion_queue = dispatch_queue_create("com.soooner.networking.operation.queue", DISPATCH_QUEUE_CONCURRENT );
    });
    
    return af_url_request_operation_completion_queue;
}

@implementation AFCustomRequestOperationManager

@synthesize asyncwork;

#pragma mark -

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        
        NSMutableString *formString=[[NSMutableString alloc] init];
        
        for (NSString *field in parameters) {
            
            NSObject *values=[parameters objectForKey:field];
            
            if([values isKindOfClass:[NSArray class]]||[values isKindOfClass:[NSSet class]]){
                
                for (NSString *value in (NSArray *)values) {
                    
                    if (formString.length>1)
                        [formString appendString:@"&"];
                    
                    NSString *fieldValue =  [NSString stringWithFormat:@"%@=%@", [field description],[AFCustomRequestOperationManager encodeURL:[value description]]];
                    
                    [formString appendString:fieldValue];
                }
                
            }else{
                
                if (formString.length>1)
                    [formString appendString:@"&"];
                
                NSString *fieldValue =  [NSString stringWithFormat:@"%@=%@", [field description],[AFCustomRequestOperationManager encodeURL:[values description]]];
                
                [formString appendString:fieldValue];
            }
            
        }
        
        return formString;
    }];
    
    return self;
}

+ (NSString*)encodeURL:(NSString *)string
{
	NSString *newString =  CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
	if (newString) {
		return newString;
	}
	return @"";
}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
                                                   delegate:(id<AFNetworkingRequestDelegate>)delegate
                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFCustomRequestOperation *operation = [[AFCustomRequestOperation alloc] initWithRequest:request];
    delegate.operation = operation;
    operation.responseSerializer = self.responseSerializer;
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;
    
    if(!self.asyncwork)
        operation.completionQueue = request_operation_completion_queue();
    
    [operation setCompletionBlockWithSuccess:success failure:failure];
    
    return operation;
}
 
- (AFHTTPRequestOperation *)request:(NSString *)URLString
                            method:(NSString *)method
                         parameters:(id)parameters
                           delegate:(id<AFNetworkingRequestDelegate>)delegate
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    
    return  [self executeRequest:request delegate:delegate  success:success failure:failure];
}

- (AFHTTPRequestOperation *)request:(NSString *)URLString
                            method:(NSString *)method
                               body:(NSData *)body
                           delegate:(id<AFNetworkingRequestDelegate>)delegate
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:nil error:nil];
    
    NSString *msgLength = [NSString stringWithFormat:@"%d", (int)[body length]];
    
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:body];
    
    return  [self executeRequest:request delegate:delegate  success:success failure:failure];
}

- (AFHTTPRequestOperation *)request:(NSString *)URLString
                             method:(NSString *)method
                      parameters:(id)parameters
          constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                           delegate:(id<AFNetworkingRequestDelegate>)delegate
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:block error:nil];
    
    return  [self executeRequest:request delegate:delegate  success:success failure:failure];
}

-(AFHTTPRequestOperation *)executeRequest:(NSMutableURLRequest *)request
                                 delegate:(id<AFNetworkingRequestDelegate>)delegate
                                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    __block dispatch_semaphore_t sem =NULL;
    
    if(!self.asyncwork){
        sem = dispatch_semaphore_create(0);
    }
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request delegate:delegate  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(success){
            success(operation,responseObject);
        }
        
        if(sem){
            dispatch_semaphore_signal(sem);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(failure){
            failure(operation,error);
        }
        
        if(sem){
            dispatch_semaphore_signal(sem);
        }
    }];
    
    [self.operationQueue addOperation:operation];
    
    if(sem){
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }
    
    return operation;
}

-(void)executeRequestOperation:(AFHTTPRequestOperation *)operation
                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
    operation.responseSerializer = self.responseSerializer;
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;
    
    if(!self.asyncwork)
        operation.completionQueue = request_operation_completion_queue();
    
    [operation setCompletionBlockWithSuccess:success failure:failure];

}


@end
