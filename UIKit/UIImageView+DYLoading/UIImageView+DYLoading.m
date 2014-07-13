//
//  UIImageView+CacheLoading.m 
//
//

#import "UIImageView+DYLoading.h"
#import "MYSCategoryProperties.h"
#import "AFImageDownloadRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#import <objc/message.h>


void dispatch_main_sync_undeadlock_imageloading(dispatch_block_t block){
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}


#pragma mark - UIImageProgressView


@implementation UIImageProgressView


- (UIImageProgressAppearance *)progressAppearance
{
    @synchronized(self)
    {
        if (_progressAppearance)
            return _progressAppearance;
        
        return [UIImageProgressAppearance sharedProgressAppearance];
    }
}


#pragma mark - init & dealloc


- (id)init
{
	return [self initWithFrame:CGRectMake(0.f, 0.f, 37.f, 37.f)];
}


- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
    {
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		_progress = 0.f;
		[self registerForKVO];
	}
	return self;
}


- (void)dealloc
{
	[self unregisterFromKVO];
}


#pragma mark - Drawing


- (void)drawRect:(CGRect)rect
{
	CGRect allRect = self.bounds;
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIImageProgressAppearance *appearance = self.progressAppearance;
    
	if (appearance.type == UIImageViewProgressTypeAnnular)
    {
		CGFloat lineWidth = 5.f;
		UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
		processBackgroundPath.lineWidth = lineWidth;
		processBackgroundPath.lineCapStyle = kCGLineCapRound;
		CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
		CGFloat radius = (self.bounds.size.width - lineWidth)/2;
		CGFloat startAngle = - ((float)M_PI / 2);
		CGFloat endAngle = (2 * (float)M_PI) + startAngle;
		[processBackgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
		[appearance.backgroundTintColor set];
		[processBackgroundPath stroke];
        
		UIBezierPath *processPath = [UIBezierPath bezierPath];
		processPath.lineCapStyle = kCGLineCapRound;
		processPath.lineWidth = lineWidth;
		endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
		[processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
		[appearance.progressTintColor set];
		[processPath stroke];
        
        if (appearance.showPercentage)
            [self drawTextInContext:context];
    }
    else if (appearance.type == UIImageViewProgressTypeCircle)
    {
        CGColorRef colorBackAlpha = CGColorCreateCopyWithAlpha(appearance.backgroundTintColor. CGColor, 0.05f);
        CGColorRef colorProgressAlpha = CGColorCreateCopyWithAlpha(appearance.progressTintColor. CGColor, 0.2f);
        
        CGRect allRect = rect;
        CGRect circleRect = CGRectMake(allRect.origin.x + 2, allRect.origin.y + 2, allRect.size.width - 4, allRect.size.height - 4);
        float x = allRect.origin.x + (allRect.size.width / 2);
        float y = allRect.origin.y + (allRect.size.height / 2);
        float angle = (_progress) * 360.0f;
        
        CGContextSaveGState(context);
        CGContextSetStrokeColorWithColor(context, colorProgressAlpha);
        CGContextSetFillColorWithColor(context, colorBackAlpha);
        CGContextSetLineWidth(context, 2.0);
        CGContextFillEllipseInRect(context, circleRect);
        CGContextStrokeEllipseInRect(context, circleRect);
        
        CGContextSetRGBFillColor(context, 1.0, 0.0, 1.0, 1.0);
        CGContextMoveToPoint(context, x, y);
        CGContextAddArc(context, x, y, (allRect.size.width + 4) / 2, -M_PI / 2, (angle * M_PI) / 180.0f - M_PI / 2, 0);
        CGContextClip(context);
        
        CGContextSetStrokeColorWithColor(context, appearance.progressTintColor.CGColor);
        CGContextSetFillColorWithColor(context, appearance.backgroundTintColor.CGColor);
        CGContextSetLineWidth(context, 2.0);
        CGContextFillEllipseInRect(context, circleRect);
        CGContextStrokeEllipseInRect(context, circleRect);
        CGContextRestoreGState(context);
        
        if (appearance.showPercentage)
            [self drawTextInContext:context];
	}
    else
    {
        CGRect circleRect = CGRectInset(allRect, 2.0f, 2.0f);
        
        CGColorRef colorBackAlpha = CGColorCreateCopyWithAlpha(appearance.backgroundTintColor. CGColor, 0.1f);
        
		[appearance.progressTintColor setStroke];
        CGContextSetFillColorWithColor(context, colorBackAlpha);
        
		CGContextSetLineWidth(context, 2.0f);
		CGContextFillEllipseInRect(context, circleRect);
		CGContextStrokeEllipseInRect(context, circleRect);
        
		CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
		CGFloat radius = (allRect.size.width - 4) / 2 - 3;
		CGFloat startAngle = - ((float)M_PI / 2);
		CGFloat endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
		[appearance.progressTintColor setFill];
		CGContextMoveToPoint(context, center.x, center.y);
		CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
		CGContextClosePath(context);
		CGContextFillPath(context);
    }
}


- (void)drawTextInContext:(CGContextRef)context
{
    UIImageProgressAppearance *appearance = self.progressAppearance;
    
    CGRect allRect = self.bounds;
    
    UIFont *font = appearance.percentageTextFont;
    NSString *text = [NSString stringWithFormat:@"%i%%", (int)(_progress * 100.0f)];
    
    CGSize textSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(30000, 13)];
    
    float x = floorf(allRect.size.width / 2) + 3 + appearance.percentageTextOffset.x;
    float y = floorf(allRect.size.height / 2) - 6 + appearance.percentageTextOffset.y;
    
    CGContextSetFillColorWithColor(context, appearance.percentageTextColor.CGColor);
    [text drawAtPoint:CGPointMake(x - textSize.width / 2.0, y) withFont:font];
}


#pragma mark - KVO


- (void)registerForKVO
{
	for (NSString *keyPath in [self observableKeypaths])
    {
		[self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
	}
}


- (void)unregisterFromKVO
{
	for (NSString *keyPath in [self observableKeypaths])
    {
		[self removeObserver:self forKeyPath:keyPath];
	}
}


- (NSArray *)observableKeypaths
{
	return [NSArray arrayWithObjects:@"progressAppearance", @"progress", nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self setNeedsDisplay];
}


#pragma mark -


@end


@implementation UIImageProgressAppearance


static UIImageProgressAppearance *sharedProgressAppearanceInstance = nil;


+ (UIImageProgressAppearance *)sharedProgressAppearance
{
    @synchronized(self)
    {
        if (sharedProgressAppearanceInstance)
            return sharedProgressAppearanceInstance;
        
        return sharedProgressAppearanceInstance = [UIImageProgressAppearance new];
    }
}


#pragma mark - init


- (id)init
{
    self = [super init];
    if (self)
    {
        self.schemeColor = [UIColor whiteColor];
        _percentageTextFont = [UIFont systemFontOfSize:10];
        _percentageTextOffset = CGPointZero;
        _type = 0;
        _showPercentage = YES;
    }
    return self;
}


#pragma mark - Setters


- (void)setSchemeColor:(UIColor *)schemeColor
{
    _schemeColor = schemeColor;
    
    _progressTintColor = [UIColor colorWithCGColor:CGColorCreateCopyWithAlpha(schemeColor.CGColor, 1)];
    _backgroundTintColor = [UIColor colorWithCGColor:CGColorCreateCopyWithAlpha(schemeColor.CGColor, 0.1)];
    _percentageTextColor = [UIColor colorWithCGColor:CGColorCreateCopyWithAlpha(schemeColor.CGColor, 1)];
}


#pragma mark -


@end

#pragma mark - UIImageLoadData

@interface UIImageLoadData : NSObject

@property (nonatomic,assign) NSInteger requestID;
@property(nonatomic,strong) NSMutableSet *imageSet;

@end

@implementation UIImageLoadData

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageSet =[[NSMutableSet alloc] init];
    }
    return self;
}

-(void)dealloc{
    [self.imageSet removeAllObjects];
    self.imageSet = nil;
}

@end

#pragma mark - UIImageLoadManager

@interface UIImageLoadManager : NSObject


@property (nonatomic,strong) dispatch_queue_t imageLoadingQueue;

@property (nonatomic,strong) dispatch_queue_t imageProcessQueue;



@property (nonatomic,strong) NSMutableDictionary *poolDictionary;
 


@end

@implementation UIImageLoadManager

static NSLock *lock;
#pragma mark - initial
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageLoadingQueue = dispatch_queue_create("UIImageLoadManager_imageLoadingQueue", DISPATCH_QUEUE_SERIAL);
        self.imageProcessQueue = dispatch_queue_create("UIImageLoadManager_imageProcessQueue", DISPATCH_QUEUE_SERIAL);
        
        self.poolDictionary =[[NSMutableDictionary  alloc] init];
        
        lock =[[NSLock  alloc] init];
    }
    return self;
}

+ (NSCache *)sharedImageCache {
    static NSCache *defaultImageCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        defaultImageCache = [[NSCache alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [defaultImageCache removeAllObjects];
        }];
    });
    
    return  defaultImageCache;
    
}

+ (UIImage *)loadImage:(NSString *)rootKey secondKey:(NSString *)secondKey
{
    UIImage *image = nil;
    @synchronized(lock){
        NSDictionary *dictionary=[[UIImageLoadManager sharedImageCache] objectForKey:rootKey];
        if(dictionary){
            image = [dictionary objectForKey:secondKey];
        }
    }
    return image;
}
+ (void)loadImage:(NSString *)rootKey secondKey:(NSString *)secondKey image:(UIImage *)image
{
    @synchronized(lock){
        NSMutableDictionary *dictionary=[[UIImageLoadManager sharedImageCache] objectForKey:rootKey];
        if(!dictionary){
            dictionary =[[NSMutableDictionary alloc] init];
            [dictionary setObject:image forKey:secondKey];
            [[UIImageLoadManager sharedImageCache] setObject:dictionary forKey:rootKey];
        }else{
            [dictionary setObject:image forKey:secondKey];
        }
    }
}

+(UIImageLoadManager *)shareInstance{
    static UIImageLoadManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UIImageLoadManager alloc] init];
    });
    return sharedInstance;
}


#pragma mark - static Medthd


+(void)addLoadingImageView:(UIImageView *)imageView key:(NSString *)key{
    @synchronized(lock){
        UIImageLoadData *data=[[UIImageLoadManager shareInstance].poolDictionary objectForKey:key];
        
        if(data==nil){
        
            data =[[UIImageLoadData  alloc] init];
            [[UIImageLoadManager shareInstance].poolDictionary setObject:data forKey:key];
        }
        [data.imageSet addObject:imageView];
        
    }
}



+ (void)addLoadingRequestId:(NSInteger)requestId key:(NSString *)key{
    @synchronized(lock){
        UIImageLoadData *data=[[UIImageLoadManager shareInstance].poolDictionary objectForKey:key];
        
        if(data!=nil){
            data.requestID =requestId;
        }
        
    }
}

+(void)removeLoadingImageView:(UIImageView *)imageView key:(NSString *)key{
    @synchronized(lock){
        UIImageLoadData *data=[[UIImageLoadManager shareInstance].poolDictionary objectForKey:key];
        
        if(data!=nil){
            NSInteger queueID =imageView.loadingQueueId;
            
            [data.imageSet removeObject:imageView];
            
            if(data.imageSet.count==0){
                [AFNetworkHttpRequestManager cancelQueue:queueID requestId:data.requestID];
                
                [[UIImageLoadManager shareInstance].poolDictionary removeObjectForKey:key];
            }
        }
        
    }
}

+ (NSMutableSet *)findAllEntry:(NSString *)key{
    NSMutableSet *imageSet;
    @synchronized(lock){
        UIImageLoadData *data=[[UIImageLoadManager shareInstance].poolDictionary objectForKey:key];
        imageSet = [[NSMutableSet alloc] initWithSet:data.imageSet];
    }
    
    return imageSet;
}


+ (BOOL)isDownloading:(NSString *)key{
    BOOL  result = NO;
    @synchronized(lock){
        result=([[UIImageLoadManager shareInstance].poolDictionary objectForKey:key]!=nil);
    }
    
    return result;
}
+ (void)addDownload:(NSString *)key{
    @synchronized(lock){
        UIImageLoadData *data=[[UIImageLoadManager shareInstance].poolDictionary objectForKey:key];
        
        if(data==nil){
            
            data =[[UIImageLoadData  alloc] init];
            [[UIImageLoadManager shareInstance].poolDictionary setObject:data forKey:key];
        }
        
    }
    
}
+ (void)removeDownload:(NSString *)key queueId:(NSInteger)queueId{
    @synchronized(lock){
        UIImageLoadData *data=[[UIImageLoadManager shareInstance].poolDictionary objectForKey:key];
        
        if(data==nil){
            
            [data.imageSet removeAllObjects];
            
            [AFNetworkHttpRequestManager cancelQueue:queueId requestId:data.requestID];
            
            [[UIImageLoadManager shareInstance].poolDictionary removeObjectForKey:key];
            
        }
        
    }
}

#pragma mark - image method

+(UIImage *)processImage:(UIImage *)image{
    CGRect rect = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
	UIGraphicsBeginImageContext(rect.size);
	[image drawInRect:rect];  // scales image to rect
	UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return resImage;
}


+(void)processDownloadImage:(NSString *)URL filePath:(NSString *)filePath queueId:(NSInteger)queueId{
    
    __block NSString  *_filePath =filePath;
    
    dispatch_async([UIImageLoadManager shareInstance].imageProcessQueue, ^{
        @autoreleasepool {
            @try {
                
                NSMutableSet *entrys= [UIImageLoadManager findAllEntry:_filePath];
                
                UIImage *image =[UIImage imageWithContentsOfFile:_filePath];
               __block UIImage *showImage = [UIImageLoadManager processImage:image];
                
                
                for (UIImageView *imageView in entrys) {
                    
                    if(showImage&&imageView.imageRenderType==UIImageViewRenderThumbnail){
                        
                        [UIImageLoadManager loadImage:imageView.loadingCacheKey secondKey:_filePath image:showImage];
                    }
                    __weak UIImageView *blockImageView =imageView;
                    dispatch_main_sync_undeadlock_imageloading(^{
                        blockImageView.loadingAnimation = YES;
                        [blockImageView showLoadingImage:showImage];
                    });
                    
                    [blockImageView imageSelSelecer];
                }
                
                
            }
            @catch (NSException *exception) {
#if DEBUG
                NSLog(@"%@",[[exception callStackSymbols] componentsJoinedByString:@"\n"]);
#endif
            }@finally {
                [UIImageLoadManager removeDownload:_filePath queueId:queueId];
            }
        }
    });

}
#pragma mark - download method

+(void)startLoadingImage:(UIImageView *)imageView urlRequest:(NSString *)URL filePath:(NSString *)filePath{
     
    __block NSInteger queueId =imageView.loadingQueueId;
    __block NSString  *_URL =URL;
    __block NSString  *_filePath =filePath;
    
    if([UIImageLoadManager isDownloading:_filePath]){
        
        [UIImageLoadManager addLoadingImageView:imageView key:filePath];
        
        return;
    }
    [UIImageLoadManager addLoadingImageView:imageView key:_filePath];
    
    dispatch_async([UIImageLoadManager shareInstance].imageLoadingQueue, ^{
        
        
        AFImageDownloadRequest *downloadRequest=[[AFImageDownloadRequest alloc] initWithURL:_URL];
        downloadRequest.filePath=_filePath;
        
#if DEBUG
        NSLog(@"url requestId:%d imageUrl:%@",downloadRequest.requestId,_URL);
        
#endif
        
        [UIImageLoadManager addLoadingRequestId:downloadRequest.requestId key:_filePath];
        
        [downloadRequest downloadBlock:^(long long totalBytesRead, long long totalBytesExpectedToRead) {
            
            CGFloat progress = (totalBytesRead*1.0f)/ (totalBytesExpectedToRead*1.0f);
            
            NSMutableSet *images = [UIImageLoadManager findAllEntry:_filePath];
            
            for (UIImageView *imageView in images) {
                [imageView setProgress:progress];
            }
            
            NSLog(@"------%f",progress);
        }];
        
        [downloadRequest completionBlock:^(AFNetworkingBaseRequest *request, NSInteger statusCode) {
            
            @try {
                if(statusCode==200){
                    
                    
                    [UIImageLoadManager processDownloadImage:_URL filePath:_filePath queueId:queueId];
                    
                }
                else if(statusCode == 404){
#if DEBUG
                    NSLog(@"404:%@",_filePath);
#endif
                }
            }@catch (NSException *exception) {
                [UIImageLoadManager removeDownload:_filePath queueId:queueId];
#if DEBUG
                NSLog(@"%@",[[exception callStackSymbols] componentsJoinedByString:@"\n"]);
#endif
            }
        }];
        
        [downloadRequest executeAsync:queueId];
        
        
    });
    
}


-(void)processLocalImage:(UIImageView *)imageView{
    
    
    __block UIImageView *blockImageView =imageView;
    dispatch_async([UIImageLoadManager shareInstance].imageProcessQueue, ^{
        @autoreleasepool {
            @try {
                if(blockImageView.imageRenderType==UIImageViewRenderThumbnail){
                     UIImage *image = [UIImageLoadManager loadImage:blockImageView.loadingCacheKey secondKey:blockImageView.loadingResourcePath];
                    if(image){
                        dispatch_main_sync_undeadlock_imageloading(^{
                            [blockImageView showLoadingImage:image];
                        });
                        
                        [blockImageView imageSelSelecer];
                        
                        return;
                    }
                }
                
                UIImage *image=[UIImage imageWithContentsOfFile:blockImageView.loadingResourcePath];
                __block UIImage *showImage = [UIImageLoadManager processImage:image];
                
                
                dispatch_main_sync_undeadlock_imageloading(^{
                    [blockImageView showLoadingImage:showImage];
                    
                });
                
                [blockImageView imageSelSelecer];
            }
            @catch (NSException *exception) {
#if DEBUG
                NSLog(@"%@",[[exception callStackSymbols] componentsJoinedByString:@"\n"]);
#endif
            }
        }
    });
                   
}

@end

#pragma mark - UIImageView (DYLoading)

@implementation UIImageView (DYLoading)

@dynamic progressView;
@dynamic progressAppearance;

@dynamic target;
@dynamic sel;



@dynamic defaultLoadingImage;
@dynamic useLoadingDefaultImage;

@dynamic loadingImageUrl;


@dynamic loadingResourcePath;
@dynamic loadingImagePathType;
@dynamic loadingImageKey;
@dynamic loadingCacheKey;

@dynamic loadingAnimation;
@dynamic loadingprogressAnimation;

@dynamic loadingQueueId;

@dynamic imageRenderType;


+ (void)load
{
    [MYSCategoryProperties setup:self];
}
-(void)dealloc{
    
    [self freeProgressView];
}



#pragma mark - layoutSubviews


- (void)layoutSubviews
{
    self.progressView.frame = CGRectMake(floorf(self.frame.size.width/2 - self.progressView.frame.size.width/2), floorf(self.frame.size.height/2 - self.progressView.frame.size.height/2), self.progressView.frame.size.width, self.progressView.frame.size.height);
}


- (void)loadProgressView
{
    [self freeProgressView];
    
    self.progressView = [[UIImageProgressView alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
    
    if (self.progressAppearance)
        self.progressView.progressAppearance = self.progressAppearance;
    
    
    [self addSubview:self.progressView];
}

#pragma mark - ASIProgressDelegate


- (void)setProgress:(float)newProgress
{
    if (self.progressView)
    {
        dispatch_main_sync_undeadlock_imageloading(^{
            self.progressView.progress = newProgress;
        });
    }
}


#pragma mark - Free




- (void)freeProgressView
{
    if (self.progressView)
    {
        dispatch_main_sync_undeadlock_imageloading(^{
            if (self.progressView.superview)
                [self.progressView removeFromSuperview];
        });
        
        self.progressView = nil;
    }
}


#pragma mark - image path method
+ (NSString *)getFilename:(NSURL *)url {
    
    if(!url)
        return nil;
    
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
    
    NSString *imageDirPath=[typeDirPath stringByAppendingPathComponent:self.loadingImageKey];
    if(![fileManager fileExistsAtPath:imageDirPath isDirectory:nil]){
        [fileManager createDirectoryAtPath:imageDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *className=[[self class] getFilename:url];
    if(className==nil)
        className =@"icon";
    
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


#pragma mark - public loading method

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
    
    [[UIImageLoadManager sharedImageCache] removeObjectForKey:cacheKey];
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
    //    LOG_DEBUG(@"Not file in directory:%@",path);
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
    if(className==nil)
        className =@"icon";
    
    NSString *dirPath=[imageDirPath stringByAppendingPathComponent:className];
    
    NSMutableString *filePath=[[NSMutableString alloc] init];
    
    [filePath appendString:dirPath];
    
    
    [filePath appendString:@"."];
    [filePath appendString:@".png"];
    
    return filePath;
}


#pragma mark - self method


+(void)cancelImageLoadingQueue:(NSInteger)hashCode{
    [AFNetworkHttpRequestManager cancelQueue:hashCode];
    
}
-(void)recycleLoading{
    //    LOG_DEBUG(@"-------------------recycleLoading--------------");
    //TODO 设置内部取消状态
    [self.layer removeAllAnimations];
    
    self.loadingprogressAnimation = NO;
    
    [self freeProgressView];
    
    if (self.loadingResourcePath) { 
            [UIImageLoadManager removeLoadingImageView:self key:self.loadingResourcePath];
    }
    
    self.loadingResourcePath = nil;
}


-(void)showLoadingImage:(UIImage *)image{
    if(image){
        self.useLoadingDefaultImage =NO;
        if(self.loadingAnimation){
            CATransition  *animation =[[CATransition alloc] init];
            [animation setType:kCATransitionFade];
            [animation setDuration:0.4f];
            [self.layer addAnimation:animation forKey:nil];
        }
        //TODO
        
        [self setImage:image];
    }else{
        self.useLoadingDefaultImage =YES;
        //TODO
        [self setImage:self.defaultLoadingImage];
    }
}

#pragma mark - public loading method


-(void)imageSelSelecer{
    
    [self freeProgressView];
    SEL aSelector = NSSelectorFromString(self.sel);
    
    if(self.target){
        if([self.target respondsToSelector:aSelector]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.target performSelector:aSelector withObject:self];
#pragma clang diagnostic pop
        }
    }
}


-(void)loadingAsyncLocalImage{
    
    [self.layer removeAllAnimations];
    self.loadingAnimation  = NO;
    
    [self showLoadingImage:nil];
    
    [[UIImageLoadManager shareInstance] processLocalImage:self ];
}
-(void)loadingSyncLocalImage{
    UIImage *image;
    
    NSString *_imageType=self.loadingImagePathType;
    NSString *_imageKeyStr=self.loadingImageKey;
    
    if(_imageType&&_imageKeyStr){ ;
    }else{
        
        self.loadingImagePathType =@"image";
        self.loadingImageKey =@"default";
        
    }
    
    self.loadingCacheKey = [NSString stringWithFormat:@"%@--%@",self.loadingImagePathType,self.loadingImageKey];
    
    if(self.imageRenderType==UIImageViewRenderThumbnail){
        image = [UIImageLoadManager loadImage:self.loadingCacheKey secondKey:self.loadingResourcePath];
    }
    
    
    if(!image){
        image=[UIImage imageWithContentsOfFile:self.loadingResourcePath];
        if(image&&self.imageRenderType==UIImageViewRenderThumbnail){
            
            [UIImageLoadManager loadImage:self.loadingCacheKey secondKey:self.loadingResourcePath image:image];
        }
    }
    if(image){
        [self showLoadingImage:image];
    }
}


-(void)loadingAsyncImage:(NSString *)imageUrl{
    [self loadImage:imageUrl  fourceSync:NO];
}
-(void)loadingAsyncImage:(NSString *)imageUrl doneSelector:(SEL)aSelector withTarget:(id)target{
    self.target =target;
    self.sel = NSStringFromSelector(aSelector);
    
    [self loadImage:imageUrl   fourceSync:NO];
}

-(void)loadingSyncImage:(NSString *)imageUrl{
    [self loadImage:imageUrl  fourceSync:YES];
}
-(void)loadingSyncImage:(NSString *)imageUrl doneSelector:(SEL)aSelector withTarget:(id)target{
    self.target =target;
    
   
    self.sel = NSStringFromSelector(aSelector);
    
    
    [self loadImage:imageUrl fourceSync:YES];
}

- (void)loadImage:(NSString *)imageUrl fourceSync:(BOOL)fourceSync{
    
    if (imageUrl == nil) {
        self.loadingAnimation = NO;
        [self showLoadingImage:nil];
        return;
    }

    
    @autoreleasepool {
        @try {
            self.loadingAnimation = NO;
            [self.layer removeAllAnimations]; 
            
            NSURL *url=[NSURL URLWithString:imageUrl];
            if(url==nil){
#if DEBUG
                NSLog(@"url Invalid:%@",imageUrl);
#endif
                
                return;
            }
            
            //TODO 设置内部处理中状态
            
            self.loadingImageUrl =imageUrl;
            
            NSString *_imageType=self.loadingImagePathType;
            NSString *_imageKeyStr=self.loadingImageKey;
            
            if(_imageType&&_imageKeyStr){
                self.loadingCacheKey = [NSString stringWithFormat:@"%@--%@",_imageType,_imageKeyStr];
                
                self.loadingResourcePath=[self parseLoadingThumbUrl:[NSURL URLWithString:imageUrl]];
            }else{
                
                self.loadingImagePathType =@"image";
                self.loadingImageKey =@"default";
                self.loadingCacheKey = [NSString stringWithFormat:@"%@--%@",self.loadingImagePathType,self.loadingImageKey];
                
                self.loadingResourcePath=[self parseLoadingThumbUrl:[NSURL URLWithString:imageUrl]];
                
            }
            UIImage *image;
            
            if(self.imageRenderType==UIImageViewRenderThumbnail){
                
                image = [UIImageLoadManager loadImage:self.loadingCacheKey secondKey:self.loadingResourcePath];
                if(image){
                    [self showLoadingImage:image];
                    
                    [self imageSelSelecer];
                    return;
                }
            }
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            [fileManager removeItemAtPath:self.loadingResourcePath error:NULL];
            
            
            
            BOOL existed = [fileManager fileExistsAtPath:self.loadingResourcePath];
            image=[UIImage imageWithContentsOfFile:self.loadingResourcePath];
            if (existed&&image) {
                if(fourceSync){
                    if(image&&self.imageRenderType==UIImageViewRenderThumbnail){
                        
                        [UIImageLoadManager loadImage:self.loadingCacheKey secondKey:self.loadingResourcePath image:image];
                    }
                    
                    [self showLoadingImage:image];

                    [self imageSelSelecer];
                }else{
                    if(self.defaultLoadingImage)
                        [self showLoadingImage:nil];
                     
                    [[UIImageLoadManager shareInstance] processLocalImage:self ];
                    
                }
            }else{
                if(self.defaultLoadingImage)
                    [self showLoadingImage:nil];
                
                if(existed){
                    [fileManager removeItemAtPath:self.loadingResourcePath error:NULL];
                }
                if(self.loadingprogressAnimation){
                
                    self.progressAppearance =  [UIImageProgressAppearance sharedProgressAppearance];
                    self.progressAppearance.type = UIImageViewProgressTypeCircle;
                
                    [self loadProgressView];
                }
                
                [UIImageLoadManager startLoadingImage:self urlRequest:self.loadingImageUrl filePath:self.loadingResourcePath];
                
            }
        }
        @catch (NSException *exception) {
#if DEBUG
            NSLog(@"%@",[[exception callStackSymbols] componentsJoinedByString:@"\n"]);
#endif
        }
    }
    
}


@end

