//
//  AFDownloadRequestOperationManager.m 
//

#import "AFDownloadRequestOperationManager.h"
#import "AFDownloadRequestOperation.h"

static dispatch_queue_t download_request_operation_completion_queue() {
    static dispatch_queue_t af_url_request_operation_completion_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_url_request_operation_completion_queue = dispatch_queue_create("com.soooner.networking.operation.queue", DISPATCH_QUEUE_CONCURRENT );
    });
    
    return af_url_request_operation_completion_queue;
}
 
@implementation AFDownloadRequestOperationManager

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request shouldResume:NO];
    operation.responseSerializer = self.responseSerializer;
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;
    
    
    if(!self.asyncwork)
        operation.completionQueue = download_request_operation_completion_queue();
    
    [operation setCompletionBlockWithSuccess:success failure:failure];
    
    return operation;
}

@end
