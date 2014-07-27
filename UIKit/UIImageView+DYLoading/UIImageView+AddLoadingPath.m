//
//  UIImageView+AddLoadingPath.m 
//

#import "UIImageView+AddLoadingPath.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>
 

@implementation UIImageView (AddLoadingPath)


@dynamic loadingCacheKey;

@dynamic loadingResourcePath;
@dynamic loadingImageUrl;

@dynamic loadingImageKey;
@dynamic loadingImagePathType;

@dynamic loadingQueueId;


#pragma mark - normal target 
static const char *loadingQueueIdKey           ="__loadingQueueId__";
static const char *loadingCacheKeyKey          ="__loadingCacheKey__";
static const char *loadingResourcePathKey      ="__loadingResourcePath__";
static const char *loadingImageUrlKey          ="__loadingImageUrl__"; 
static const char *loadingImageKeyKey          ="__loadingImageKeyKey__";
static const char *loadingImagePathTypeKey     ="__loadingImagePathType__";
static const char *loadingTokenKey             ="__loadingToken__";
static const char *loadingTargetKey             ="__loadingTarget__";
static const char *loadingActionKey             ="__loadingAction__";


-(void)setLoadingQueueId:(NSInteger)loadingQueueId{
    objc_setAssociatedObject(self, loadingQueueIdKey, [NSNumber numberWithInt:loadingQueueId], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSInteger)loadingQueueId{
    NSNumber *loadingQueueIdValue= objc_getAssociatedObject(self, loadingQueueIdKey);
    return [loadingQueueIdValue intValue];
}


-(void)setLoadingCacheKey:(NSString *)loadingCacheKey{
    objc_setAssociatedObject(self, loadingCacheKeyKey, loadingCacheKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)loadingCacheKey{
    return objc_getAssociatedObject(self, loadingCacheKeyKey);
}

-(void)setLoadingResourcePath:(NSString *)loadingResourcePath{
    objc_setAssociatedObject(self, loadingResourcePathKey, loadingResourcePath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)loadingResourcePath{
    return objc_getAssociatedObject(self, loadingResourcePathKey);
}

-(void)setLoadingImageUrl:(NSString *)loadingImageUrl{
    objc_setAssociatedObject(self, loadingImageUrlKey, loadingImageUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)loadingImageUrl{
    return objc_getAssociatedObject(self, loadingImageUrlKey);
}

-(void)setLoadingImageKey:(long)loadingImageKey{
    objc_setAssociatedObject(self, loadingImageKeyKey,[NSString stringWithFormat:@"%ld",loadingImageKey], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(long)loadingImageKey{
    NSString *loadingImageKeyValue= objc_getAssociatedObject(self, loadingImageKeyKey);
    return (long)[loadingImageKeyValue longLongValue];
}
-(void)setLoadingImageKeyStr:(NSString *)loadingImageKeyStr{
    objc_setAssociatedObject(self, loadingImageKeyKey, loadingImageKeyStr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)loadingImageKeyStr{
    return objc_getAssociatedObject(self, loadingImageKeyKey);
}
-(void)setLoadingImagePathKey:(NSString *)loadingImagePathKey{
    objc_setAssociatedObject(self, loadingImageKeyKey, loadingImagePathKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)loadingImagePathKey{
    return objc_getAssociatedObject(self, loadingImageKeyKey);
}
-(void)setLoadingImagePathType:(NSString *)loadingImagePathType{
    objc_setAssociatedObject(self, loadingImagePathTypeKey, loadingImagePathType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)loadingImagePathType{
    return objc_getAssociatedObject(self, loadingImagePathTypeKey);
}

-(void)setLoadingToken:(NSString *)loadingToken{
    objc_setAssociatedObject(self, loadingTokenKey, loadingToken, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString *)loadingToken{
    return objc_getAssociatedObject(self, loadingTokenKey);
}

-(void)setLoadingTarget:(id)target{
    objc_setAssociatedObject(self, loadingTargetKey, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id)loadingTarget{
    return objc_getAssociatedObject(self, loadingTargetKey);
}

-(void)setLoadingAction:(NSString *)action{
    objc_setAssociatedObject(self, loadingActionKey, action, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString *)loadingAction{
    return objc_getAssociatedObject(self, loadingActionKey);
}



#pragma mark - image cache method

static CGSize cacheSize;
+ (BOOL)supportCache:(UIImage *)image{
    if(CGSizeEqualToSize(cacheSize,CGSizeZero)){
        NSLog(@"-------");
        cacheSize =CGSizeMake(640.0f, 640.0f);
    }
    
    return image.size.width<=cacheSize.width&&image.size.height<=cacheSize.height;
}

+ (void)setSupportImageCacheSize:(CGSize)size{
    cacheSize =size;
}

static NSObject *lock;
+ (NSCache *)defaultCache
{
    static NSCache *sharedInstance = nil;
    
    static dispatch_once_t cacheToken;
    
    dispatch_once(&cacheToken, ^{
        sharedInstance = [[NSCache alloc] init];
        lock =[[NSObject alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [sharedInstance removeAllObjects];
        }];
    });
    return sharedInstance;
}
+ (UIImage *)loadImage:(NSString *)rootKey secondKey:(NSString *)secondKey
{
    UIImage *image = nil;
    @synchronized(lock){
        NSDictionary *dictionary=[[[self class] defaultCache] objectForKey:rootKey];
        if(dictionary){
            image = [dictionary objectForKey:secondKey];
        }
    }
    return image;
}
+ (void)loadImage:(NSString *)rootKey secondKey:(NSString *)secondKey image:(UIImage *)image
{
    @synchronized(lock){
        NSMutableDictionary *dictionary=[[[self class] defaultCache] objectForKey:rootKey];
        if(!dictionary){
            dictionary =[[NSMutableDictionary alloc] init];
            [dictionary setObject:image forKey:secondKey];
            [[[self class] defaultCache] setObject:dictionary forKey:rootKey];
        }else{
            [dictionary setObject:image forKey:secondKey];
        }
    }
}


#pragma mark - image path method
+ (NSString *)getFilename:(NSURL *)url {
    
    if(url==nil)
        return @"";
    
    const char *cStr = [[url absoluteString] UTF8String];
    
    unsigned char result[16];
    
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *)getThumbPath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    [fileManager createDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:@"thumb"] withIntermediateDirectories:YES attributes:nil error:nil];
    
    return [documentsDirectory stringByAppendingPathComponent:@"thumb"];
}

- (NSString *)parseLoadingThumbUrl:(NSURL *)url{
    
    NSString *content=[[self class] getThumbPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *typeDirPath=[content stringByAppendingPathComponent:self.loadingImagePathType];
    if(![fileManager fileExistsAtPath:typeDirPath isDirectory:nil]){
        [fileManager createDirectoryAtPath:typeDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *imageDirPath=[typeDirPath stringByAppendingPathComponent:self.loadingImagePathKey];
    if(![fileManager fileExistsAtPath:imageDirPath isDirectory:nil]){
        [fileManager createDirectoryAtPath:imageDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *className=[[self class] getFilename:url];
    
    NSString *dirPath=[imageDirPath stringByAppendingPathComponent:className];
    
    return  [self parseLoadingImagePath:dirPath];
}

-(NSString *)parseLoadingImagePath:(NSString *)imagePath{
    
    NSMutableString *filePath=[[NSMutableString alloc] init];
    
    [filePath appendString:imagePath];
    
    [filePath appendString:@"."];
    [filePath appendString:@".png"];
    
    return filePath;
}
+(void)clearAllImageAllCacheFile{
    NSString *content=[[self class] getThumbPath];
    [[self class] clearPath:content];
}
 

+(void)clearImageCache:(NSString *)imagePathType imageKey:(NSString *)imageKey{
    NSString *content=[[self class] getThumbPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *typeDirPath=[content stringByAppendingPathComponent:imagePathType];
    if(![fileManager fileExistsAtPath:typeDirPath isDirectory:nil]){
        [fileManager createDirectoryAtPath:typeDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *imageDirPath=[typeDirPath stringByAppendingPathComponent:imageKey];
    if(![fileManager fileExistsAtPath:imageDirPath isDirectory:nil]){
        [fileManager createDirectoryAtPath:imageDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [UIImageView clearDir:imageDirPath];
    
    
    NSString *cacheKey = [NSString stringWithFormat:@"%@--%@",imagePathType,imageKey];
    
    [[[self class] defaultCache] removeObjectForKey:cacheKey];
}
+ (void)clearPath:(NSString *)perfix {
    
    [UIImageView clearDir:perfix];
}

+ (void)clearDir:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL _isDir;
    if ([fileManager fileExistsAtPath:path isDirectory:&_isDir]) {
        if (!_isDir) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            return;
        }
    }
    
    
    NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:nil];
    
    for (int i = 0; i < [files count]; i++) {
        NSString *filePath = [path stringByAppendingPathComponent:[files objectAtIndex:i]];
        BOOL isDir;
        if ([fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {
            if (isDir)
                [UIImageView clearDir:filePath];
            else
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil]; 
}

+(NSString *)parseImagePath:(NSString *)imagePathType imageKey:(NSString *)imageKey url:(NSURL *)url{
    NSString *content=[[self class] getThumbPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *typeDirPath=[content stringByAppendingPathComponent:imagePathType];
    if(![fileManager fileExistsAtPath:typeDirPath isDirectory:nil]){
        [fileManager createDirectoryAtPath:typeDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *imageDirPath=[typeDirPath stringByAppendingPathComponent:imageKey];
    if(![fileManager fileExistsAtPath:imageDirPath isDirectory:nil]){
        [fileManager createDirectoryAtPath:imageDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *className=[[self class] getFilename:url];
    
    NSString *dirPath=[imageDirPath stringByAppendingPathComponent:className];
    
    NSMutableString *filePath=[[NSMutableString alloc] init];
    
    [filePath appendString:dirPath];
    
    
    [filePath appendString:@"."];
    [filePath appendString:@".png"];
    
    return filePath;
}

-(void)recycleLoadingPath{
    self.loadingQueueId =0;
    self.loadingCacheKey =nil;
    self.loadingResourcePath =nil;
    self.loadingImageUrl =nil;
     
    self.loadingImagePathType=nil;
    self.loadingToken =nil;
    
    self.loadingTarget =nil;
    self.loadingAction =nil;
     
}

-(void)dealloc{
    [self recycleLoadingPath];
    objc_removeAssociatedObjects(self);
    
}



@end
