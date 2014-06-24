//
//  AFCustomRequestOperation.m
//  AFNetworking-Base
//
//  Created by yangjunhai on 14-3-27.
//  Copyright (c) 2014年 soooner. All rights reserved.
//

#import "AFCustomRequestOperation.h"

@interface AFURLConnectionOperation ()
@property (readwrite, nonatomic, strong) NSURLRequest *request;
@property (readwrite, nonatomic, strong) NSURLResponse *response;
@end



@implementation AFCustomRequestOperation

- (void)connection:(NSURLConnection __unused *)connection
didReceiveResponse:(NSURLResponse *)response
{
    self.response = response;
    self.statusCode = ((NSHTTPURLResponse *)response).statusCode;
    
    [self.outputStream open];
}

@end
