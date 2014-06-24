//
//  TestRequest.h
//  AFNetworking-Base
//
//  Created by yangjunhai on 14-3-27.
//  Copyright (c) 2014年 soooner. All rights reserved.
//

#import "AFNetworkingBaseRequest.h"

//[[AFNetworkActivityLogger sharedLogger] startLogging];
//[[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
//
//TestRequest  *request = [[TestRequest alloc] init];
//
//[request uploadBlock:^(NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
//
//}];
//
//[request downloadBlock:^(NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
//
//}];
//
//[request completionBlock:^(AFNetworkingBaseRequest *request, NSInteger statusCode) {
//    NSLog(@"-----------completionBlock");
//}];
//
//[request executeAsync:self.hash];

@interface TestRequest : AFNetworkingBaseRequest

@end
