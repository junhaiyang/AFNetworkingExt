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
                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFCustomRequestOperation *operation = [[AFCustomRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = self.responseSerializer;
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;
    
    if(!self.asyncwork)
        operation.completionQueue = request_operation_completion_queue();
    
    [operation setCompletionBlockWithSuccess:success failure:failure];
    
    return operation;
}


#pragma mark -

- (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(id)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    
    __block dispatch_semaphore_t sem =NULL;
    
    if(!self.asyncwork){
        sem = dispatch_semaphore_create(0);
    }
    
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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

- (AFHTTPRequestOperation *)HEAD:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(AFHTTPRequestOperation *operation))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"HEAD" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    
    __block dispatch_semaphore_t sem =NULL;
    
    if(!self.asyncwork){
        sem = dispatch_semaphore_create(0);
    }
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *requestOperation, __unused id responseObject) {
        if (success) {
            success(requestOperation);
            
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

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    
    __block dispatch_semaphore_t sem =NULL;
    
    if(!self.asyncwork){
        sem = dispatch_semaphore_create(0);
    }
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
       constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:block error:nil];
    
    __block dispatch_semaphore_t sem =NULL;
    
    if(!self.asyncwork){
        sem = dispatch_semaphore_create(0);
    }
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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

- (AFHTTPRequestOperation *)PUT:(NSString *)URLString
                     parameters:(id)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"PUT" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    
    __block dispatch_semaphore_t sem =NULL;
    
    if(!self.asyncwork){
        sem = dispatch_semaphore_create(0);
    }
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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

- (AFHTTPRequestOperation *)PATCH:(NSString *)URLString
                       parameters:(id)parameters
                          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"PATCH" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    
    __block dispatch_semaphore_t sem =NULL;
    
    if(!self.asyncwork){
        sem = dispatch_semaphore_create(0);
    }
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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

- (AFHTTPRequestOperation *)DELETE:(NSString *)URLString
                        parameters:(id)parameters
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"DELETE" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    
    __block dispatch_semaphore_t sem =NULL;
    
    if(!self.asyncwork){
       sem = dispatch_semaphore_create(0);
    }
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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

@end
