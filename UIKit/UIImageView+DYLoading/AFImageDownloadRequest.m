//
//

#import "AFImageDownloadRequest.h"


@implementation AFImageDownloadRequest
@synthesize  url,filePath; 
 
-(id)initWithURL:(NSString *)_url{
    if(self=[super init]){
        self.url=_url; 
        self.responseType=ResponseProtocolTypeFile;
        
    }
    return self;
} 

- (void)prepareRequest {
    

    
     [self buildGetRequest:url];
}

-(AFHTTPResponseSerializer *)getAFHTTPResponseSerializer{ 
    
    return [AFImageResponseSerializer serializer];
}

-(void)processFile:(NSObject *)_filePath{
    if(![self isHttpSuccess]){
        
        
        if([_filePath isKindOfClass:[NSString class]]){
            
            NSFileManager *manager=[NSFileManager defaultManager];
            if([manager fileExistsAtPath:(NSString *)_filePath]){
                NSError *error;
                [manager removeItemAtPath:(NSString *)_filePath error:&error];
                if(error){
                    NSLog(@"%@",error);
                }
            }
        }
        return;
    }
    
    
    if([_filePath isKindOfClass:[NSString class]]){
        NSFileManager *manager=[NSFileManager defaultManager];
        if([manager fileExistsAtPath:(NSString *)_filePath]){
            NSError *error;
            [manager moveItemAtPath:(NSString *)_filePath toPath:self.filePath error:&error];
            if(error){
                NSLog(@"%@",error);
            }
        }
    }else if ([_filePath isKindOfClass:[UIImage class]]){
        NSData *dataObj = UIImagePNGRepresentation((UIImage *)_filePath);
        [dataObj writeToFile:self.filePath atomically:NO];
    }
    
    
    
    
}

@end
