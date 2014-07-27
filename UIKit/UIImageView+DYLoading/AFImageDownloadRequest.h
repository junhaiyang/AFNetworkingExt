//
//  DownloadRequest.h 
//

#import "AFNetworkingBaseRequest.h"

@interface AFImageDownloadRequest : AFNetworkingBaseRequest{
 NSString *url;
}

@property(nonatomic, strong) NSString *filePath; 
@property(nonatomic, strong) NSString *url; 

-(id)initWithURL:(NSString *)_url;
@end
