//
//  DownloadRequest.h
//  Deeper
//
//  Created by junhai yang on 12-3-12.
//  Copyright (c) 2012年 mRocker Ltd. All rights reserved.
//

#import "AFNetworkingBaseRequest.h"

@interface AFImageDownloadRequest : AFNetworkingBaseRequest{
 NSString *url;
}
@property (nonatomic,assign)NSInteger requestId;

@property(nonatomic, strong) NSString *filePath; 
@property(nonatomic, strong) NSString *url; 

-(id)initWithURL:(NSString *)_url;
@end
