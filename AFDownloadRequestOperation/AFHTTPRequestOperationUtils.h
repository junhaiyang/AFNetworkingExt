//
//  AFHTTPRequestOperationUtils.h
//  AFNetworking-Base
//
//  Created by yangjunhai on 14-3-27.
//  Copyright (c) 2014年 soooner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFHTTPRequestOperationUtils : NSObject

+ (NSString *)getCachePath;

+ (NSString *)getCacheDir;

+ (void)clearCachePath:(NSString *)path;

@end
