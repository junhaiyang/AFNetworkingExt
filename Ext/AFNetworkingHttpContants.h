//
//  HttpContants.h
//  MediaPlayer
//
//
//  Copyright (c) 2013年 111. All rights reserved.
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




typedef NS_ENUM(NSInteger, OperationType) {
    OperationTypeNormal = 0,   //基本处理方案，处理完成回调、超时回调
    OperationTypeUpload,     //上传处理方案，处理完成回调、超时回调、上传进度回调
    OperationTypeDownload,   //下载处理方案，处理完成回调、超时回调、下载进度回调
    OperationTypeAll         //全部处理方案，处理完成回调、超时回调、上传进度回调、下载进度回调
};

typedef NS_ENUM(NSInteger, RequestProtocolType) {
    RequestProtocolTypeNormal = 0,       //请求协议类型，发无任何格式的字符串流方式
    RequestProtocolTypeFORM,             //请求协议类型，发FORM流方式 
    // todo other
};

typedef NS_ENUM(NSInteger, ResponseProtocolType) {
    ResponseProtocolTypeNormal = 0,       //响应协议类型，发无任何格式的字符串流方式
    ResponseProtocolTypeJSON,              //响应协议类型，发JSON格式符串流方式
    ResponseProtocolTypeFile,              //响应协议类型，发文件流方式
    ResponseProtocolTypeXML,               //响应协议类型，发XML格式符串流方式
    // todo other
};

typedef NS_ENUM(NSInteger, RequestZipType) {
    RequestZipTypeNone = 0,           //请求压缩格式，无压缩
    RequestZipTypeGZIP,               //请求压缩格式，gzip压缩
    // todo other
};

typedef NS_ENUM(NSInteger, ResponseZipType) {
    ResponseZipTypeNone = 0,          //响应压缩格式，无压缩
    ResponseZipTypeGZIP,              //响应压缩格式，gzip压缩
    // todo other
};


#endif
