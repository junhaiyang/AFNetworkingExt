//
//  AFCustomRequestOperation.h
//  AFNetworking-Base
//
//  Created by yangjunhai on 14-3-27.
//  Copyright (c) 2014年 soooner. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

@interface AFCustomRequestOperation : AFHTTPRequestOperation

@property (nonatomic,assign) NSInteger requestId;
@property (nonatomic,assign) NSInteger statusCode;

@end
