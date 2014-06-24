 //
//  AFNetworkingBaseRequest.m
//  AFNetworking-Base
//
//  Created by yangjunhai on 14-3-27.
//  Copyright (c) 2014年 soooner. All rights reserved.
//

#import "AFNetworkingBaseRequest.h"
#import "AFCustomRequestOperationManager.h"


@interface AFNetworkingBaseRequest(){
    
}

@property (nonatomic,strong) AFNetworkingCompletionBlock networkingCompletionBlock;
@property (nonatomic,strong) AFNetworkingDownloadBlock networkingDownloadBlock;
@property (nonatomic,strong) AFNetworkingUploadBlock networkingUploadBlock;

@property (nonatomic,assign) BOOL asyncwork;

@end

@implementation AFNetworkingBaseRequest

- (instancetype)init
{
    self = [super init];
    if (self) { 
        self.responseType = ResponseProtocolTypeJSON;
        self.asyncwork  = NO;
    }
    return self;
}


-(void)completionBlock:(AFNetworkingCompletionBlock)completionBlock{
    self.networkingCompletionBlock =completionBlock;
}
-(void)downloadBlock:(AFNetworkingDownloadBlock)downloadBlock{
    self.networkingDownloadBlock =downloadBlock;
}
-(void)uploadBlock:(AFNetworkingUploadBlock)uploadBlock{
    self.networkingUploadBlock =uploadBlock;
}
-(void)executeSync:(NSInteger)queueId{
    self.managerKey =[NSString stringWithFormat:@"%d-%d-sync",(int)queueId,(int)self.responseType];
    self.asyncwork  = NO;
    [self prepareRequest];
}
-(void)executeSyncWithQueueKey:(NSString *)key{
    self.managerKey =[NSString stringWithFormat:@"%@-%d-sync",key,(int)self.responseType];
    self.asyncwork  = NO;
    [self prepareRequest];
}

-(void)executeAsync:(NSInteger)queueId{
    self.managerKey =[NSString stringWithFormat:@"%d-%d-async",(int)queueId,(int)self.responseType];
    self.asyncwork  = YES;
    [self prepareRequest];
}
-(void)executeAsyncWithQueueKey:(NSString *)key{
    self.managerKey =[NSString stringWithFormat:@"%@-%d-async",key,(int)self.responseType];
    self.asyncwork  = YES;
    [self prepareRequest];
}




#pragma mark
#pragma mark - build 
-(void)buildPostRequest:(NSString *)urlString form:(NSDictionary *)form{
    
    AFCustomRequestOperationManager *manager = [AFNetworkHttpRequestManager loadManagerStr:self.managerKey responseType:self.responseType asyncwork:self.asyncwork];
    
    manager.responseSerializer = [self getAFHTTPResponseSerializer];
    
    __block AFNetworkingBaseRequest *weakSelf = self;
    
    operation = (AFCustomRequestOperation *)[manager POST:urlString parameters:form success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf processResult:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(weakSelf.networkingCompletionBlock){
                weakSelf.networkingCompletionBlock(weakSelf,StatusCodeHttpError);
        }
    }];
    
    
    [self processBlock];
}

-(void)buildPostFileRequest:(NSString *)urlString files:(NSDictionary *)files{
    
    AFCustomRequestOperationManager *manager = [AFNetworkHttpRequestManager loadManagerStr:self.managerKey responseType:self.responseType asyncwork:self.asyncwork];
    
    manager.responseSerializer = [self getAFHTTPResponseSerializer];
    
    __block AFNetworkingBaseRequest *weakSelf = self;
    
    operation = (AFCustomRequestOperation *)[manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        for (NSString *key  in files) {
            NSString *filePath =[files objectForKey:key];
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:key error:NULL];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf processResult:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(weakSelf.networkingCompletionBlock){
            weakSelf.networkingCompletionBlock(weakSelf,StatusCodeHttpError);
        }
    }];
    
    
    [self processBlock];
}

-(void)buildPostFileRequest:(NSString *)urlString files:(NSDictionary *)files form:(NSDictionary *)form{
    
    AFCustomRequestOperationManager *manager = [AFNetworkHttpRequestManager loadManagerStr:self.managerKey responseType:self.responseType asyncwork:self.asyncwork];
    
    manager.responseSerializer = [self getAFHTTPResponseSerializer];
    
    __block AFNetworkingBaseRequest *weakSelf = self;
    
    operation = (AFCustomRequestOperation *)[manager POST:urlString parameters:form constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        for (NSString *key  in files) {
            NSString *filePath =[files objectForKey:key];
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:key error:NULL];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf processResult:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(weakSelf.networkingCompletionBlock){
            weakSelf.networkingCompletionBlock(weakSelf,StatusCodeHttpError);
        }
    }];
    
    
    [self processBlock];
}

-(void)buildGetRequest:(NSString *)urlString form:(NSDictionary *)form{
    
    AFCustomRequestOperationManager *manager = [AFNetworkHttpRequestManager loadManagerStr:self.managerKey responseType:self.responseType asyncwork:self.asyncwork];
    
    manager.responseSerializer = [self getAFHTTPResponseSerializer];
    
    __block AFNetworkingBaseRequest *weakSelf = self;
    
    operation = (AFCustomRequestOperation *)[manager GET:urlString parameters:form success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf processResult:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(weakSelf.networkingCompletionBlock){
            weakSelf.networkingCompletionBlock(weakSelf,StatusCodeHttpError);
        }
    }];
    
    
    [self processBlock];
}

-(void)buildGetRequest:(NSString *)urlString{
    
    AFCustomRequestOperationManager *manager = [AFNetworkHttpRequestManager loadManagerStr:self.managerKey responseType:self.responseType asyncwork:self.asyncwork];
    
    manager.responseSerializer = [self getAFHTTPResponseSerializer];
    
    __block AFNetworkingBaseRequest *weakSelf = self;

    operation = (AFCustomRequestOperation *)[manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf processResult:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(weakSelf.networkingCompletionBlock){
            weakSelf.networkingCompletionBlock(weakSelf,StatusCodeHttpError);
        }
    }];
    
    [self processBlock];
}

-(void)buildDeleteRequest:(NSString *)urlString{
    
    AFCustomRequestOperationManager *manager = [AFNetworkHttpRequestManager loadManagerStr:self.managerKey responseType:self.responseType asyncwork:self.asyncwork];
    
    manager.responseSerializer = [self getAFHTTPResponseSerializer];
    
    __block AFNetworkingBaseRequest *weakSelf = self;
    
    operation = (AFCustomRequestOperation *)[manager DELETE:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf processResult:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(weakSelf.networkingCompletionBlock){
            weakSelf.networkingCompletionBlock(weakSelf,StatusCodeHttpError);
        }
    }];
    
    [self processBlock];
    
}


#pragma mark - process  Result
-(void)processResult:(id)responseObject{
    @try {
         
        if(self.responseType==ResponseProtocolTypeFile){
            [self processFile:(NSString *)responseObject];
        }else if(self.responseType==ResponseProtocolTypeNormal){
            [self processString:(NSString *)responseObject];
        }else{
            [self processDictionary:responseObject];
        }
        if(self.networkingCompletionBlock){
            self.networkingCompletionBlock(self,StatusCodeSuccess);
        }
    }
    @catch (NSException *exception) {
        if(self.networkingCompletionBlock){
            self.networkingCompletionBlock(self,StatusCodeProcessError);
        }
    } 
}

-(void)processBlock{
    if(self.networkingDownloadBlock){
        __block AFNetworkingBaseRequest *weakSelf = self;
        
        if([operation isKindOfClass:[AFDownloadRequestOperation class]]){
            [((AFDownloadRequestOperation *)operation) setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
                
                weakSelf.networkingDownloadBlock((NSUInteger)totalBytesRead,(NSUInteger)totalBytesExpected);
                
                
            }];
        }else{
            
            [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                weakSelf.networkingDownloadBlock(totalBytesRead,totalBytesExpectedToRead);
            }];
        }
    }
    
    if(self.networkingUploadBlock){
        __block AFNetworkingBaseRequest *weakSelf = self;
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            weakSelf.networkingUploadBlock(totalBytesWritten,totalBytesExpectedToWrite);
        }];
    }
}


-(AFHTTPResponseSerializer *)getAFHTTPResponseSerializer{
    
    if(self.responseType==ResponseProtocolTypeNormal){
        return [AFTextResponseSerializer serializer];
    }else if (self.responseType == ResponseProtocolTypeXML){
        return [AFOnoResponseSerializer XMLResponseSerializer];
    }
    
    return [AFJSONResponseSerializer serializer];
}

-(void)cancel{
    [operation cancel];
}

-(BOOL)isCanceled{
    return  [operation isCancelled];
}
-(BOOL)isHttpSuccess{
    return YES;
//   return operation.statusCode == StatusCodeSuccess;
}

#pragma mark
#pragma mark  need overrided
- (void)prepareRequest {
    NSException *e = [[NSException alloc] initWithName:@"prepareRequest 方法必须要重新实现" reason:nil userInfo:nil];
    @throw e;
}

- (void)processFile:(NSString *)filePath{
    NSException *e = [[NSException alloc] initWithName:@"processFile: 方法必须要重新实现" reason:nil userInfo:nil];
    @throw e;
}
- (void)processDictionary:(id)dictionary{
    NSException *e = [[NSException alloc] initWithName:@"processDictionary: 方法必须要重新实现" reason:nil userInfo:nil];
    @throw e;
}
- (void)processString:(NSString *)str{
    NSException *e = [[NSException alloc] initWithName:@"processString: 方法必须要重新实现" reason:nil userInfo:nil];
    @throw e;
}

-(void)buildCommonRequestHeader:(NSMutableURLRequest *)request{
    
}

@end