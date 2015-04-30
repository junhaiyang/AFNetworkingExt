 //
//  AFNetworkingBaseRequest.m 
//

#import "AFNetworkingBaseRequest.h"
#import "AFCustomRequestOperationManager.h"


@interface AFNetworkingBaseRequest(){
    
}

@property (nonatomic,strong) AFNetworkingCompletionBlock networkingCompletionBlock;
@property (nonatomic,strong) AFNetworkingFinishedBlock networkingFinishedBlock;
@property (nonatomic,strong) AFNetworkingDownloadBlock networkingDownloadBlock;
@property (nonatomic,strong) AFNetworkingUploadBlock networkingUploadBlock;



@property (nonatomic,assign) BOOL asyncwork;
@property (nonatomic,assign) BOOL queueExecute;

@property (nonatomic,assign,readwrite) NSInteger requestId;
@property (nonatomic,strong,readwrite) NSString *managerKey; 

@end

@implementation AFNetworkingBaseRequest

@synthesize operation;

-(void)dealloc{
    self.networkingUploadBlock =nil;
    self.networkingDownloadBlock =nil;
    self.networkingUploadBlock =nil;
    operation =nil;
}

static int indexNumber =0;
- (instancetype)init
{
    self = [super init];
    if (self) { 
        self.responseType = ResponseProtocolTypeJSON;
        self.asyncwork  = NO;
        self.queueExecute = YES;
        indexNumber++;
        self.requestId=indexNumber;
    }
    return self;
}


-(void)completionBlock:(AFNetworkingCompletionBlock)completionBlock{
    self.networkingCompletionBlock =completionBlock;
}
-(void)finishedBlock:(AFNetworkingFinishedBlock)finishedBlock{
    self.networkingFinishedBlock =finishedBlock;
}
-(void)downloadBlock:(AFNetworkingDownloadBlock)downloadBlock{
    self.networkingDownloadBlock =downloadBlock;
}
-(void)uploadBlock:(AFNetworkingUploadBlock)uploadBlock{
    self.networkingUploadBlock =uploadBlock;
}
-(void)executeSync{
    self.managerKey =[NSString stringWithFormat:@"queue-%d-sync",(int)self.responseType];
    self.queueExecute = NO;
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


-(void)executeAsyncWithoutQueue{
    self.queueExecute = NO;
    [self prepareRequest];
}


#pragma mark
#pragma mark - build 

-(void)buildPostRequest:(NSString *)urlString body:(NSData *)body {
    self.requestType =RequestProtocolTypeNormal;
    
    [self buildRequest:urlString method:kAFNetworking_HTTP_POST body:body];
    
}


-(void)buildPostRequest:(NSString *)urlString form:(NSDictionary *)form{
    
    [self buildRequest:urlString method:kAFNetworking_HTTP_POST parameters:form];
    
}

-(void)buildPostFileRequest:(NSString *)urlString files:(NSDictionary *)files{
    
    self.requestType =RequestProtocolTypeNormal;
    
    [self buildRequest:urlString method:kAFNetworking_HTTP_POST parameters:nil files:files];
    
}

-(void)buildPostFileRequest:(NSString *)urlString files:(NSDictionary *)files form:(NSDictionary *)form{
    
    self.requestType =RequestProtocolTypeNormal;
    
    [self buildRequest:urlString method:kAFNetworking_HTTP_POST parameters:form files:files];
    
}

-(void)buildGetRequest:(NSString *)urlString form:(NSDictionary *)form{
    
    
    [self buildRequest:urlString method:kAFNetworking_HTTP_GET parameters:form];
    
}

-(void)buildGetRequest:(NSString *)urlString{
    
    [self buildRequest:urlString method:kAFNetworking_HTTP_GET parameters:nil];
    
}

-(void)buildDeleteRequest:(NSString *)urlString{
    
    [self buildRequest:urlString method:kAFNetworking_HTTP_DELETE parameters:nil];
    
}

-(AFCustomRequestOperationManager *)getManager{
    AFCustomRequestOperationManager *manager;
    if(self.queueExecute){
         manager = [AFNetworkHttpRequestManager loadManagerStr:self.managerKey responseType:self.responseType asyncwork:self.asyncwork];
        
    }else{
        
        if (self.responseType == ResponseProtocolTypeFile){
            manager =  [AFDownloadRequestOperationManager manager];
        }else{ 
            manager =  [AFCustomRequestOperationManager manager];
        }
        
    }
    
    return manager;
}


-(void)buildRequest:(NSString *)urlString method:(NSString *)method parameters:(NSDictionary *)parameters{
    
    AFCustomRequestOperationManager *manager = [self getManager];
    
    manager.responseSerializer = [self getAFHTTPResponseSerializer];
    manager.requestSerializer = [self getAFHTTPRequestSerializer];
    
    __block AFNetworkingBaseRequest *weakSelf = self;
    
    operation =  (AFCustomRequestOperation *)[manager request:urlString method:method parameters:parameters delegate:self  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [weakSelf processResult:responseObject];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#if DEBUG
        NSLog(@"failure:%@",error);
#endif
        if(weakSelf.networkingFinishedBlock){
            weakSelf.networkingFinishedBlock(weakSelf,StatusCodeHttpError,weakSelf.operation.statusCode);
        }else if(weakSelf.networkingCompletionBlock){
            weakSelf.networkingCompletionBlock(weakSelf,StatusCodeHttpError);
        }
    }];
    
    [self processBlock];
}

-(void)buildRequest:(NSString *)urlString method:(NSString *)method body:(NSData *)body{
    
    AFCustomRequestOperationManager *manager = [self getManager];
    
    manager.responseSerializer = [self getAFHTTPResponseSerializer];
    manager.requestSerializer = [self getAFHTTPRequestSerializer];
    
    __block AFNetworkingBaseRequest *weakSelf = self;
    
    operation =  (AFCustomRequestOperation *)[manager request:urlString method:method body:body delegate:self  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [weakSelf processResult:responseObject];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#if DEBUG
        NSLog(@"failure:%@",error);
#endif
        if(weakSelf.networkingFinishedBlock){
            weakSelf.networkingFinishedBlock(weakSelf,StatusCodeHttpError,weakSelf.operation.statusCode);
        }else if(weakSelf.networkingCompletionBlock){
            weakSelf.networkingCompletionBlock(weakSelf,StatusCodeHttpError);
        }
    }];
    
    [self processBlock];
}

-(void)buildRequest:(NSString *)urlString method:(NSString *)method parameters:(NSDictionary *)parameters files:(NSDictionary *)files {
    
    AFCustomRequestOperationManager *manager = [self getManager];
    
    manager.responseSerializer = [self getAFHTTPResponseSerializer];
    manager.requestSerializer = [self getAFHTTPRequestSerializer];
    
    __block AFNetworkingBaseRequest *weakSelf = self;
    
    operation =  (AFCustomRequestOperation *)[manager request:urlString method:method parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (NSString *key  in files) {
            NSString *filePath =[files objectForKey:key];
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:key error:NULL];
        }
    } delegate:self  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [weakSelf processResult:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#if DEBUG
        NSLog(@"failure:%@",error);
#endif
        if(weakSelf.networkingFinishedBlock){
            weakSelf.networkingFinishedBlock(weakSelf,StatusCodeHttpError,weakSelf.operation.statusCode);
        }else if(weakSelf.networkingCompletionBlock){
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
        if(self.networkingFinishedBlock){
            self.networkingFinishedBlock(self,StatusCodeSuccess,self.operation.statusCode);
        }else if(self.networkingCompletionBlock){
            self.networkingCompletionBlock(self,StatusCodeSuccess);
        }
    }
    @catch (NSException *exception) {
#if DEBUG
        NSLog(@"处理结果失败:%@",exception);
#endif
        if(self.networkingFinishedBlock){
            self.networkingFinishedBlock(self,StatusCodeProcessError,self.operation.statusCode);
        }else if(self.networkingCompletionBlock){
            self.networkingCompletionBlock(self,StatusCodeProcessError);
        }
    } 
}

-(void)processBlock{
    operation.requestId = self.requestId;
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
    AFHTTPResponseSerializer *responseSerializer;
    if(self.responseType==ResponseProtocolTypeNormal){
        responseSerializer= [AFTextResponseSerializer serializer];
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/xml", @"text/asa" ,@"text/asp",@"text/scriptlet",@"text/vnd.wap.wml",@"text/plain",@"text/webviewhtml",@"text/x-ms-odc",@"text/css",@"text/vnd.rn-realtext3d",@"text/vnd.rn-realtext",@"text/iuls",@"text/x-vcard",nil];
    }else if (self.responseType == ResponseProtocolTypeXML){
        responseSerializer= [AFOnoResponseSerializer XMLResponseSerializer];
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/xml", @"application/xml",@"application/x-gzip",@"text/webviewhtml", nil];
    }else{ 
        responseSerializer= [AFJSONResponseSerializer serializer];
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/xml", @"application/xml",@"application/x-gzip", nil];
    }
    
    
    
    return responseSerializer;
}

-(AFHTTPRequestSerializer *)getAFHTTPRequestSerializer{
    AFHTTPRequestSerializer *requestSerializer;
     if(self.requestType==RequestProtocolTypeJSON){
        requestSerializer= [AFJSONRequestSerializer serializer];
         //去掉所有限制
//         requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:nil, nil];
    } else {
        requestSerializer= [AFHTTPRequestSerializer serializer];
    }
    
    if([AFNetworkingHttpContants containsAuthorizationHeaderField]){
        [requestSerializer setAuthorizationHeaderFieldWithUsername:[AFNetworkingHttpContants authorizationHeaderFieldWithUsername] password:[AFNetworkingHttpContants authorizationHeaderFieldWithPassword]]; 
    }
    
    return requestSerializer;
}


-(void)cancel{
    [operation cancel];
}

-(BOOL)isCanceled{
    return  [operation isCancelled];
}
-(BOOL)isHttpSuccess{ 
   return operation.statusCode == StatusCodeSuccess;
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
 

@end
