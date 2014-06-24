//
//  TestRequest.m
//  AFNetworking-Base
//
//  Created by yangjunhai on 14-3-27.
//  Copyright (c) 2014年 soooner. All rights reserved.
//

#import "TestRequest.h"

#define  PROTOCOL_URL  @"http://www.baidu.com"
#define POST_FILE_URL @"/212122"

@implementation TestRequest




- (instancetype)init
{
    self = [super init];
    if (self) {
//        self.responseType =ResponseProtocolTypeFile;
        self.responseType =ResponseProtocolTypeJSON;
        self.responseType =ResponseProtocolTypeNormal;
        
    }
    return self;
}

-(void)prepareRequest{
    
    NSString *url = [PROTOCOL_URL stringByAppendingString:POST_FILE_URL];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:@"121212123123" forKey:@"account"];
    [dictionary setObject:@"111111" forKey:@"passwd"];
    [self buildGetRequest:url form:dictionary];
    
}

-(void)processString:(NSString *)str{
    NSLog(@"processString:%@", str);
    
}

-(void)processDictionary:(id)dictionary{
    NSLog(@"processDictionary:%@", dictionary);
}

-(void)processFile:(NSString *)filePath{
    
    NSLog(@"processFile:%@", filePath);
}

@end
