//
//  UIImageBatchLoadingManager.m 
//

#import "UIImageBatchLoadingManager.h"
#import "AFImageDownloadRequest.h"
#import "AFNetworkingHttpQueueManager.h"
#import "UIImageView+AddLoadingPath.h"


NSString *const kDYUIImageViewLoadedImageNotification       = @"kDYUIImageViewLoadedImageNotification";

void dispatch_manager_load_image_main_sync_undeadlock_fun(dispatch_block_t block){
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@implementation UIImageLoadedEntry

@synthesize imagePath,image;

@end

@interface UIImageBatchLoadEntry : NSObject
@property (nonatomic,strong) NSString *loadKey;    //请求标识，url
@property (nonatomic,strong) NSMutableSet *imagesTokens;   //待处理图片标识
@property (nonatomic,strong) NSMutableSet *waitTokens;   //待处理图片标识
@property (nonatomic,assign) NSInteger queueId;
@property (nonatomic,assign) NSInteger requestId;

@end

@implementation UIImageBatchLoadEntry

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imagesTokens =[[NSMutableSet alloc] init];
        self.waitTokens=[[NSMutableSet alloc] init];
    }
    return self;
}

@end

@interface UIImageBatchLoadingManager(){

    dispatch_queue_t  image_process_queue;
}
@property (nonatomic,strong) NSMutableDictionary *poolDictionary;

@end

@implementation UIImageBatchLoadingManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.poolDictionary=[[NSMutableDictionary alloc] init];
        image_process_queue =dispatch_queue_create("UIImageBatchLoadingManager_IMAGE_PROCESS_QUEUE", NULL);
    }
    return self;
}
static long long number =0;
+(NSString *)loadingToken{
    NSString *token = nil;
    @synchronized(lock){
        token =[NSString stringWithFormat:@"%lld",number];
        number++;
    }
    return token;
}

static NSObject *lock;
+(UIImageBatchLoadingManager *)shareInstance{
    static UIImageBatchLoadingManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UIImageBatchLoadingManager alloc] init];
        lock = [[NSObject alloc] init];
    });
    return sharedInstance;
}

+(void)addWaitPath:(NSString *)path token:(NSString *)token{
    @synchronized(lock){
        UIImageBatchLoadingManager *imageLoadManager=[UIImageBatchLoadingManager shareInstance];
        UIImageBatchLoadEntry *entry=[imageLoadManager.poolDictionary objectForKey:path];
        if(entry==nil){
            entry = [[UIImageBatchLoadEntry alloc] init];
            [imageLoadManager.poolDictionary setObject:entry forKey:path];
        }
        [entry.waitTokens addObject:token];
    }
    
}

+ (BOOL)isWaiting:(NSString *)path{
    BOOL result = NO;
    @synchronized(lock){
        UIImageBatchLoadingManager *imageLoadManager=[UIImageBatchLoadingManager shareInstance];
        UIImageBatchLoadEntry *entry=[imageLoadManager.poolDictionary objectForKey:path];
        if(entry){
            result = entry.waitTokens.count>0;
        }
    }
    return result;
}

+(void)removeWait:(NSString *)path token:(NSString *)token{
    @synchronized(lock){
        UIImageBatchLoadingManager *imageLoadManager=[UIImageBatchLoadingManager shareInstance];
        UIImageBatchLoadEntry *entry=[imageLoadManager.poolDictionary objectForKey:path];
        if(entry!=nil){
            [entry.waitTokens removeObject:token];
        }
    }
    
}

+(void)addLoadPath:(NSString *)path token:(NSString *)token{
    @synchronized(lock){
        UIImageBatchLoadingManager *imageLoadManager=[UIImageBatchLoadingManager shareInstance];
        UIImageBatchLoadEntry *entry=[imageLoadManager.poolDictionary objectForKey:path];
        if(entry==nil){
            entry = [[UIImageBatchLoadEntry alloc] init];
            [imageLoadManager.poolDictionary setObject:entry forKey:path];
        }
        [entry.imagesTokens addObject:token];
    }

}

+ (BOOL)isDownloading:(NSString *)path{
    BOOL result = NO;
    @synchronized(lock){
        UIImageBatchLoadingManager *imageLoadManager=[UIImageBatchLoadingManager shareInstance];
        UIImageBatchLoadEntry *entry=[imageLoadManager.poolDictionary objectForKey:path];
        if(entry){
            result =  entry.imagesTokens.count>0;
        }
    }
    return result;
}

+(void)addLoadPath:(NSString *)path  token:(NSString *)token queue:(NSInteger)queueId requestId:(NSInteger)requestId{
    @synchronized(lock){
        UIImageBatchLoadingManager *imageLoadManager=[UIImageBatchLoadingManager shareInstance];
        UIImageBatchLoadEntry *entry=[imageLoadManager.poolDictionary objectForKey:path];
        if(entry==nil){
            entry = [[UIImageBatchLoadEntry alloc] init];
            [imageLoadManager.poolDictionary setObject:entry forKey:path];
        }
        entry.requestId =requestId;
        entry.queueId   =queueId;
        [entry.imagesTokens addObject:token];
    }
    
}

+(void)removeLoadPath:(NSString *)path token:(NSString *)token{
    @synchronized(lock){
        UIImageBatchLoadingManager *imageLoadManager=[UIImageBatchLoadingManager shareInstance];
        UIImageBatchLoadEntry *entry=[imageLoadManager.poolDictionary objectForKey:path];
        if(entry!=nil){
            [entry.imagesTokens removeObject:token];
            
            if(entry.imagesTokens.count==0&&entry.queueId>0&&entry.requestId>0){
                [AFNetworkHttpRequestManager cancelQueue:entry.queueId requestId:entry.requestId];
            }
            [imageLoadManager.poolDictionary removeObjectForKey:path];
        }
    }
    
}

+ (void)removeAllLoad:(NSString *)path{
    @synchronized(lock){
        UIImageBatchLoadingManager *imageLoadManager=[UIImageBatchLoadingManager shareInstance];
        [imageLoadManager.poolDictionary removeObjectForKey:path];
    }
}


-(void)startLoad:(NSString *)resourcePath token:(NSString *)token url:(NSString *)url cacheKey:(NSString *)cacheKey queueId:(NSInteger)queueId isLocal:(BOOL)local{
    
    __block NSString *blockResourcePath = resourcePath;
    __block NSString *blockToken = token;
    __block NSString *blockURL = url;
    __block NSString *blockCacheKey = cacheKey;
    __block NSInteger blockQueueId = queueId;
    __block BOOL      blockLocal = local;
    
    __block UIImageBatchLoadingManager *weakSelf = self;
    
    [UIImageBatchLoadingManager addWaitPath:blockResourcePath token:blockToken];
    
    dispatch_async(image_process_queue, ^{
        @autoreleasepool {
            @try {
                
                if(![UIImageBatchLoadingManager isWaiting:blockResourcePath]){
                    return;
                }
                
                
                [UIImageBatchLoadingManager removeWait:blockResourcePath token:blockToken];
                
                if(blockLocal){
                    // TODO: 处理本地图片，
                    [weakSelf processLocalImage:blockResourcePath cacheKey:blockCacheKey];
                    
                }else{
                    
                    
                    //TODO 检查队列
                    if([UIImageBatchLoadingManager isDownloading:blockResourcePath]){
                        [UIImageBatchLoadingManager addLoadPath:blockResourcePath token:blockToken];
                        return;
                    }
                    
                    //删除错误图片
                    
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    BOOL existed = [fileManager fileExistsAtPath:blockResourcePath];
                    if(existed){
                        UIImage *image=[[UIImage alloc]  initWithContentsOfFile:blockResourcePath];
                        if(image){
                            // TODO: 处理本地图片，
                            [weakSelf processLocalImage:blockResourcePath cacheKey:blockCacheKey];
                        
                            return;
                        }else{
                            [fileManager removeItemAtPath:blockResourcePath error:NULL];
                        }
                    }
                     
                    
                    AFImageDownloadRequest *downloadRequest=[[AFImageDownloadRequest alloc] initWithURL:blockURL];
                    downloadRequest.filePath=blockResourcePath;
                    
#if DEBUG
                    NSLog(@"url requestId:%d imageUrl:%@",(int)downloadRequest.requestId,url);
                    
#endif
                    //添加到队列中
                    [UIImageBatchLoadingManager addLoadPath:blockResourcePath  token:blockToken queue:blockQueueId requestId:downloadRequest.requestId];
                    
                    //            LOG_DEBUG(@"-----self:%@ ",self);
                    
                    [downloadRequest completionBlock:^(AFNetworkingBaseRequest *request, NSInteger statusCode) {
                        
                        @try {
                            if(statusCode==200){
                                //                        LOG_DEBUG(@"resourcePath:%@",entry.resourcePath);
                                
                                // TODO: 处理本地图片，
                                [weakSelf processLocalImage:blockResourcePath cacheKey:blockCacheKey];
                                
                            }
                            else if(statusCode == 404){
#if DEBUG
                                NSLog(@"404:%@",blockResourcePath);
#endif
                            }
                        }@catch (NSException *exception) {
#if DEBUG
                            NSLog(@"%@",[[exception callStackSymbols] componentsJoinedByString:@"\n"]);
#endif
                        }@finally {
                            [UIImageBatchLoadingManager removeAllLoad:blockResourcePath];
                        }
                    }];
                    
                    [downloadRequest executeAsync:blockQueueId];
                }
                
            }@catch (NSException *exception) {
#if DEBUG
                NSLog(@"%@",[[exception callStackSymbols] componentsJoinedByString:@"\n"]);
#endif
            }
        }
    });
}
-(UIImage *)processImage:(UIImage *)image{
    CGRect rect = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];  // scales image to rect
    UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resImage;
}
-(void)processLocalImage:(NSString *)imagePath cacheKey:(NSString *)cacheKey{
    @autoreleasepool {
        @try {
            
            UIImage *image = [UIImageView loadImage:cacheKey secondKey:imagePath];
            
            if(image){
                //TODO notication
                //                dispatch_manager_load_image_main_sync_undeadlock_fun(^{
                UIImageLoadedEntry *loadedEntry =[[UIImageLoadedEntry alloc] init];
                loadedEntry.imagePath =[[NSString alloc] initWithString:imagePath];
                loadedEntry.image =image;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kDYUIImageViewLoadedImageNotification object:loadedEntry];
                //                });
                
                
            }else{
                image=[[UIImage alloc] initWithContentsOfFile:imagePath];
                
                if(image){
                    UIImage *showImage=[self processImage:image];
                    
                    if(image&&[UIImageView supportCache:image]){
                        [UIImageView loadImage:cacheKey secondKey:imagePath image:showImage];
                    }
                    //TODO notication
                    //                    dispatch_manager_load_image_main_sync_undeadlock_fun(^{
                    UIImageLoadedEntry *loadedEntry =[[UIImageLoadedEntry alloc] init];
                    loadedEntry.imagePath =[[NSString alloc] initWithString:imagePath];
                    loadedEntry.image =showImage;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDYUIImageViewLoadedImageNotification object:loadedEntry];
                    //                    });
                }
            }
        }
        @catch (NSException *exception) {
#if DEBUG
            NSLog(@"%@",[[exception callStackSymbols] componentsJoinedByString:@"\n"]);
#endif
        }
    }
    
}

-(void)stopLoad:(NSString *)resourcePath token:(NSString *)token{
    [UIImageBatchLoadingManager removeWait:resourcePath token:token];
    [UIImageBatchLoadingManager removeLoadPath:resourcePath token:token];
}

@end
