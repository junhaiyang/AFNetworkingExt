//
//  ImageLoadEntry.m
//
//
//
//
//

#import "ImageLoadEntry.h"
#import "UIImageView+Loading.h"
#import "AFNetworkingHttpQueueManager.h"

@implementation DownloadEntry


@end
@implementation ImageLoadData


- (id)init
{
    self = [super init];
    if (self) {
        self.imageSet =[[NSMutableSet alloc] init];
    }
    return self;
}

@end

@implementation ImageLoadEntry

@end


@interface ImageLoadManager()

@property (nonatomic,strong) NSMutableDictionary *poolDictionary;
@property (nonatomic,strong) NSMutableSet *downloadSet;
@property (nonatomic,strong) NSObject *lock;

+(ImageLoadManager *)shareInstance;

@end

@implementation ImageLoadManager
@synthesize poolDictionary;
static NSObject *lock;
- (id)init
{
    self = [super init];
    if (self) {
        self.poolDictionary=[[NSMutableDictionary alloc] init];
        self.downloadSet =[[NSMutableSet alloc] init];
         lock =[[NSObject alloc] init];
    }
    return self;
}

+(ImageLoadManager *)shareInstance{
    static ImageLoadManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ImageLoadManager alloc] init];
    });
    return sharedInstance;
}

+ (ImageLoadEntry *)findEntry:(NSString *)key imageView:(UIView *)imageView{
    @synchronized(lock){
        ImageLoadManager *imageLoadManager=[ImageLoadManager shareInstance];
        ImageLoadData *data=[imageLoadManager.poolDictionary objectForKey:key];
        for (ImageLoadEntry *entry in data.imageSet) {
            if([entry.imageView isEqual:imageView]){
                return entry;
            }
        }
    }
    return  nil;
}

+ (void)addEntry:(ImageLoadEntry *)entry{
    @synchronized(lock){
    ImageLoadManager *imageLoadManager=[ImageLoadManager shareInstance];
     ImageLoadData *data=[imageLoadManager.poolDictionary objectForKey:entry.url];
    if(data==nil){
        data = [[ImageLoadData alloc] init];
        [imageLoadManager.poolDictionary setObject:data forKey:entry.url];
    }
    [data.imageSet addObject:entry];
    }
}

+ (void)addRequestID:(NSInteger)requestID key:(NSString *)key{
    @synchronized(lock){
        ImageLoadManager *imageLoadManager=[ImageLoadManager shareInstance];
        ImageLoadData *data= [imageLoadManager.poolDictionary objectForKey:key];
        data.requestID=requestID;
    }
}

+ (void)removeEntry:(NSString *)key entry:(ImageLoadEntry *)entry{
    @synchronized(lock){
        
        ImageLoadManager *imageLoadManager=[ImageLoadManager shareInstance];
        ImageLoadData *data= [imageLoadManager.poolDictionary objectForKey:key];
        NSInteger queueID =entry.imageView.loadingQueueId;
        NSInteger requestID =data.requestID;
        [data.imageSet removeObject:entry]; 
        
        if(data.imageSet.count==0){
            [AFNetworkHttpRequestManager cancelQueue:queueID requestId:requestID];
        }
    }
}

+ (NSMutableSet *)findAllEntry:(NSString *)key{
    NSMutableSet *imageSet;
    @synchronized(lock){
        ImageLoadManager *imageLoadManager=[ImageLoadManager shareInstance];
        ImageLoadData *data= [imageLoadManager.poolDictionary objectForKey:key];
        imageSet= data.imageSet;
    }
    return imageSet;
}

+ (void)removeAllEntry:(NSString *)key{
    ImageLoadManager *imageLoadManager=[ImageLoadManager shareInstance];
    [imageLoadManager.poolDictionary removeObjectForKey:key];
}

+ (BOOL)isDownloading:(NSString *)key{
    ImageLoadManager *imageLoadManager=[ImageLoadManager shareInstance];
    return [imageLoadManager.downloadSet containsObject:key];
}
+ (void)addDownload:(NSString *)key{
    ImageLoadManager *imageLoadManager=[ImageLoadManager shareInstance];
    [imageLoadManager.downloadSet addObject:key];
}
+ (void)removeDownload:(NSString *)key{
    ImageLoadManager *imageLoadManager=[ImageLoadManager shareInstance];
    [imageLoadManager.downloadSet removeObject:key];
}


@end
