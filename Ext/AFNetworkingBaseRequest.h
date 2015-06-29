//
//  AFNetworkingBaseRequest.h 
//

#import <Foundation/Foundation.h>

#import "AFNetworkingHttpContants.h"
 
#import "AFNetworking.h"

#import "UIKit+AFNetworking.h"

#import "AFNetworkActivityLogger.h"

#import "Ono.h"

#import "ONOXMLDocument.h"

#import "AFOnoResponseSerializer.h"

#import "NSData+Godzippa.h"

#import "AFgzipRequestSerializer.h"

#import "AFNetworkingBaseRequest.h"

#import "AFTextResponseSerializer.h"

#import "AFDownloadRequestOperation.h"

#import "AFDownloadRequestOperationManager.h"

#import "AFNetworkingHttpQueueManager.h"

#import "AFCustomRequestOperation.h"

@class AFNetworkingBaseRequest;
@class AFHTTPRequestOperation;

typedef void(^AFNetworkingCompletionBlock)(AFNetworkingBaseRequest *request, NSInteger statusCode)  NS_DEPRECATED_IOS(2_0, 5_0, "AFNetworkingFinishedBlock instead!");

typedef void(^AFNetworkingFinishedBlock)(AFNetworkingBaseRequest *request, StatusCode errorCode, NSInteger httpStatusCode)  NS_AVAILABLE_IOS(5_0);  //请求协议类型

typedef void(^AFNetworkingDownloadBlock)(long long totalBytesRead, long long totalBytesExpectedToRead);
typedef void(^AFNetworkingUploadBlock)(long long  totalBytesWritten, long long totalBytesExpectedToWrite);
 

@interface AFNetworkingBaseRequest : NSObject<AFNetworkingRequestDelegate>{
 
}
@property (nonatomic,assign,readonly) NSInteger requestId;
@property (nonatomic,strong,readonly) NSString *managerKey;

@property (nonatomic,assign) ResponseProtocolType responseType;  //响应协议类型
@property (nonatomic,assign) RequestProtocolType  requestType  NS_AVAILABLE_IOS(5_0);  //请求协议类型
 
/**
 *
 * @DEPRECATED
 * 使用 finishedBlock:
 *
 **/
-(void)completionBlock:(AFNetworkingCompletionBlock)completionBlock  NS_DEPRECATED_IOS(2_0, 5_0, "Use finishedBlock:   instead!");
-(void)finishedBlock:(AFNetworkingFinishedBlock)finishedBlock  NS_AVAILABLE_IOS(5_0);

-(void)downloadBlock:(AFNetworkingDownloadBlock)downloadBlock;
-(void)uploadBlock:(AFNetworkingUploadBlock)uploadBlock;




/**
 *
 * 同步请求，无队列模式
 *
 **/
-(void)executeSync;

/**
 *
 * 没有队列的异步请求，多个请求会并行执行
 *
 **/
-(void)executeAsyncWithoutQueue NS_AVAILABLE_IOS(5_0);

/**
 *
 * 基于队列的异步请求，多个相同 queueId 请求会顺序执行
 *
 **/
-(void)executeAsync:(NSInteger)queueId;
-(void)executeAsyncWithQueueKey:(NSString *)key;


/**
 *
 * 几个标准的请求接口
 *
 **/
-(void)buildPostRequest:(NSString *)urlString body:(NSData *)body;        //直接提交body数据

-(void)buildPostRequest:(NSString *)urlString form:(NSDictionary *)form;       //提交表单数据：NSString,NSData,NSURL(Local File)
-(void)buildPostFileRequest:(NSString *)urlString files:(NSDictionary *)files;     //多个文件上传(multipart)

-(void)buildPostFileRequest:(NSString *)urlString files:(NSDictionary *)files form:(NSDictionary *)form;  //混合数据上传

-(void)buildGetRequest:(NSString *)urlString form:(NSDictionary *)form;
-(void)buildGetRequest:(NSString *)urlString;                                      //GET请求
-(void)buildDeleteRequest:(NSString *)urlString;                                   //DELETE请求

/**
 *
 * 发送数据
 *
 **/
-(void)buildRequest:(NSString *)urlString method:(NSString *)method parameters:(NSDictionary *)parameters NS_AVAILABLE_IOS(5_0);
/**
 *
 * 发送二进制流
 *
 **/
-(void)buildRequest:(NSString *)urlString method:(NSString *)method body:(NSData *)body NS_AVAILABLE_IOS(5_0);
/**
 *
 * 发送数据或文件提交
 *
 **/
-(void)buildRequest:(NSString *)urlString method:(NSString *)method parameters:(NSDictionary *)parameters files:(NSDictionary *)files NS_AVAILABLE_IOS(5_0);
 
-(void)cancel;
-(BOOL)isCanceled;
-(BOOL)isHttpSuccess;

#pragma mark

#pragma mark  can overrided

-(AFHTTPResponseSerializer *)getAFHTTPResponseSerializer;

#pragma mark  need overrided

- (void)prepareRequest;

- (void)processFile:(NSString *)filePath;
- (void)processDictionary:(id)dictionary; //NSArray or NSDictionary
- (void)processString:(NSString *)str; 

@end
