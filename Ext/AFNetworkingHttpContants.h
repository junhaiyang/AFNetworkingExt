//
//  HttpContants.h 
//

#ifndef MediaPlayer_HttpContants_h
#define MediaPlayer_HttpContants_h

typedef NS_ENUM(NSInteger, StatusCode) {
    StatusCodeUnknown = 0,      //状态未知
    StatusCodeNoWork  = -50,   //取消
    StatusCodeCancel  = -100,   //取消
    StatusCodeSuccess = 200,    //成功
    StatusCodeHttpError   = -200,    //http未知错误
    StatusCodeDataError   = -300,    //数据解析错误
    StatusCodeProcessError   = -400,    //处理错误
    StatusCodeUnknownError   = -500    //未知错误
};


typedef NS_ENUM(NSInteger, ResponseProtocolType) {
    ResponseProtocolTypeNormal = 0,       //响应协议类型，发无任何格式的字符串流方式
    ResponseProtocolTypeJSON,              //响应协议类型，发JSON格式符串流方式
    ResponseProtocolTypeFile,              //响应协议类型，发文件流方式
    ResponseProtocolTypeXML,               //响应协议类型，发XML格式符串流方式
    // todo other
};
typedef NS_ENUM(NSInteger, RequestProtocolType) {
    RequestProtocolTypeNormal = 0,       //请求协议类型，标准提交
    RequestProtocolTypeJSON,              //请求协议类型，发JSON格式提交
    // todo other
} NS_AVAILABLE_IOS(5_0);



#import <Foundation/Foundation.h>

@interface AFNetworkingHttpContants : NSObject


/**
 *
 * Authorization 认证机制
 *
 **/

+ (void)setAuthorizationHeaderFieldWithUsername:(NSString *)username
                                       password:(NSString *)password  NS_AVAILABLE_IOS(5_0);

+ (void)clearAuthorizationHeader  NS_AVAILABLE_IOS(5_0);

+ (NSString *)authorizationHeaderFieldWithUsername  NS_AVAILABLE_IOS(5_0);
+ (NSString *)authorizationHeaderFieldWithPassword  NS_AVAILABLE_IOS(5_0);

+ (BOOL)containsAuthorizationHeaderField  NS_AVAILABLE_IOS(5_0);

@end
 

#endif
