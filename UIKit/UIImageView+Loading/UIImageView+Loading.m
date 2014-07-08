//
//  UIImageView+Loading.m
//  Gallery
//
//  Created by junhai on 12-12-31.
//
//

#import "UIImageView+Loading.h"

#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "ImageLoadEntry.h"
#import "AFImageDownloadRequest.h"

void dispatch_main_sync_undeadlock_fun(dispatch_block_t block){
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@implementation UIImage (UIImageScaleClip)
 
- (UIImage *)rescaleImageToSize:(CGSize)size {
	CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
	UIGraphicsBeginImageContext(rect.size);
	[self drawInRect:rect];  // scales image to rect
	UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return resImage;
}

-(UIImage *)scaleImageToSize:(CGSize)size{
    
    CGFloat sourceWidth  = self.size.width;
    CGFloat sourceHeight = self.size.height;
    
    CGFloat viewWidth  = size.width;
    CGFloat viewHeight = size.height;
    
    CGFloat outWidth  = viewWidth;
    CGFloat outHeight = viewHeight;
    
    CGFloat widthFactor = sourceWidth / viewWidth;
    CGFloat heightFactor = sourceHeight / viewHeight;
    
    CGFloat scaleFactor = widthFactor>heightFactor?widthFactor:heightFactor;
    outWidth =  sourceWidth / scaleFactor;
    outHeight =  sourceHeight / scaleFactor;
    
    CGRect rect = CGRectMake(0.0, 0.0, outWidth, outHeight);
    
	UIGraphicsBeginImageContext(rect.size);
    
	[self drawInRect:rect];
    
	UIImage *_image = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
 
    return _image;
}

- (UIImage *)clipImageToSize:(CGSize)size scale:(BOOL)scale{
    CGFloat sourceWidth  = self.size.width;
    CGFloat sourceHeight = self.size.height;
    
    CGFloat viewWidth  = size.width;
    CGFloat viewHeight = size.height;
    
    CGFloat outWidth  = viewWidth;
    CGFloat outHeight = viewHeight;
    
    CGFloat widthFactor = sourceWidth / viewWidth;
    CGFloat heightFactor = sourceHeight / viewHeight;
    
    CGFloat scaleFactor = widthFactor<heightFactor?widthFactor:heightFactor;
    
    outWidth  =  viewWidth * scaleFactor;
    outHeight =  viewHeight * scaleFactor;
    
    CGRect rect = CGRectMake((sourceWidth -outWidth )/2, (sourceHeight -outHeight )/2, outWidth,outHeight);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();//获取当前quartz 2d绘图环境
    
    CGContextTranslateCTM(currentContext, 0-rect.origin.x,sourceHeight-rect.origin.y);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    CGContextClipToRect( currentContext, rect);//设置当前绘图环境到矩形框
    
    CGRect _rect = CGRectMake(0.0, 0.0f, sourceWidth,sourceHeight);
    
    CGContextDrawImage(currentContext, _rect, self.CGImage);//绘图
    
    UIImage *_clipImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImage *_image;
    
    if(scale){
        CGRect srect = CGRectMake(0.0, 0.0, viewWidth, viewHeight);
        UIGraphicsBeginImageContext(srect.size);
        [_clipImage drawInRect:srect];
        _image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }else{
        _image=_clipImage;
    }
    
     return [_image fixOrientation:self.imageOrientation];
}

-(UIImage *)fixOrientation:(UIImageOrientation)_imageOrientation{
    
    // No-op if the orientation is already correct
    if (_imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (_imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (_imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (_imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

-(UIImage *)cornerImageToRadius:(int)radius margin:(int)margin marginColor:(UIColor *)clolor{
    
    CGFloat viewWidth  = self.size.width;
    CGFloat viewHeight = self.size.height;
    
    CGRect rect = CGRectMake(0, 0, viewWidth,viewHeight);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect rectToDraw = CGRectInset(rect, 0, 0);
    
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:rectToDraw byRoundingCorners:(UIRectCorner)UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    
    /* Background */
    CGContextSaveGState(ctx);
    {
        CGContextAddPath(ctx, borderPath.CGPath);
        
        CGContextSetFillColorWithColor(ctx, clolor.CGColor);
        
        CGContextDrawPath(ctx, kCGPathFill);
    }
    CGContextRestoreGState(ctx);
    {
        
        CGRect _rect=CGRectMake(rect.origin.x+margin, rect.origin.y+margin, rect.size.width-2*margin, rect.size.height-2*margin);
        CGRect rectToDraw = CGRectInset(_rect, margin, margin);
        
        UIBezierPath *iconPath = [UIBezierPath bezierPathWithRoundedRect:rectToDraw byRoundingCorners:(UIRectCorner)UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
        
        /* Image and Clip */
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, iconPath.CGPath);
            CGContextClip(ctx);
            
            CGContextTranslateCTM(ctx, 0.0, self.size.height);
            CGContextScaleCTM(ctx, 1.0, -1.0);
            
            CGContextDrawImage(ctx, _rect, self.CGImage);
            
        }
        
    }
    
    UIImage *_clipImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    
    return _clipImage;
}
 
 
@end

@implementation UIControl(Extras)
static const char *____idKey                  ="______idKey__";
static const char *____idKeyStr                  ="______idKeyStr__";

-(void)setKey:(long)key{
    objc_setAssociatedObject(self, ____idKey, [NSNumber numberWithLong:key], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(long)key{
    NSNumber *keyValue= objc_getAssociatedObject(self, ____idKey);
    return [keyValue longValue];
}


-(void)setKeyStr:(NSString *)keyStr{
    objc_setAssociatedObject(self, ____idKeyStr, keyStr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)keyStr{
    return objc_getAssociatedObject(self, ____idKeyStr);
}

@end

  
@implementation UIImageView (Loading)




#pragma mark - static thread
+ (NSThread *)imageProcessThread
{
    static NSThread *processThread = nil;
    static dispatch_once_t processToken;
    
    dispatch_once(&processToken, ^{
        processThread = [[NSThread alloc] initWithTarget:self selector:@selector(runThreads) object:nil];
        [processThread start];
    });
    
    return processThread;
}

+ (void)runThreads
{
	// Should keep the runloop from exiting
	CFRunLoopSourceContext context = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
	CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    
    BOOL runAlways = YES; // Introduced to cheat Static Analyzer
	while (runAlways) {
        @autoreleasepool {
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, true);
        }
	}
    
	// Should never be called, but anyway
	CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
	CFRelease(source);
}

+ (NSThread *)imageLoadingThread{
    static NSThread *loadingThread = nil;
    static dispatch_once_t loadingToken;
    
    dispatch_once(&loadingToken, ^{
        loadingThread = [[NSThread alloc] initWithTarget:self selector:@selector(runThreads) object:nil];
        [loadingThread start];
    });
    
    return loadingThread;
}

static NSObject *lock;
+ (NSCache *)defaultCache
{
    static NSCache *sharedInstance = nil;
    
    static dispatch_once_t cacheToken;
    
    dispatch_once(&cacheToken, ^{
		sharedInstance = [[NSCache alloc] init];
        lock =[[NSObject alloc] init];
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

#pragma mark - setter/getter method

static const char *defaultLoadingImageKey      ="__defaultLoadingImage__";
static const char *loadingQueueIdKey           ="__loadingQueueId__";
static const char *imageShowSizeTypeKey        ="__imageShowSizeType__";
static const char *loadingCacheKeyKey          ="__loadingCacheKey__";
static const char *loadingResourcePathKey      ="__loadingResourcePath__";
static const char *loadingImageUrlKey          ="__loadingImageUrl__";
static const char *loadingImageKeyStrKey       ="__loadingImageKeyStr__";
static const char *loadingImageKeyKey          ="__loadingImageKeyKey__";
static const char *loadingImagePathTypeKey     ="__loadingImagePathType__";
static const char *useLoadingDefaultImageKey   ="__useLoadingDefaultImageKey__";
static const char *loadingAnimationKey         ="__loadingAnimationKey__";
static const char *controlKey                  ="__controlKey__";
static const char *loadingControlKeyStrKey     ="__loadingControlKeyStrKey__";
static const char *loadingControlKeyKey        ="__loadingControlKeyKey__";




-(void)setDefaultLoadingImage:(UIImage *)defaultLoadingImage{
    objc_setAssociatedObject(self, defaultLoadingImageKey, defaultLoadingImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UIImage *)defaultLoadingImage{
    return objc_getAssociatedObject(self, defaultLoadingImageKey);
}

-(void)setLoadingQueueId:(NSInteger)loadingQueueId{
    objc_setAssociatedObject(self, loadingQueueIdKey, [NSNumber numberWithInt:loadingQueueId], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSInteger)loadingQueueId{
    NSNumber *loadingQueueIdValue= objc_getAssociatedObject(self, loadingQueueIdKey);
    return [loadingQueueIdValue intValue];
}


-(void)setImageRenderType:(ImageRenderType)imageRenderType{
    objc_setAssociatedObject(self, imageShowSizeTypeKey, [NSNumber numberWithInt:imageRenderType], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSInteger)imageRenderType{
    
    NSNumber *imageShowSizeTypeValue=objc_getAssociatedObject(self, imageShowSizeTypeKey);
    switch ([imageShowSizeTypeValue intValue]) {
        case  1:
            return ImageRenderOriginal;
            break;
        default:
            return ImageRenderThumbnail;
            break;
            
    }
    return ImageRenderThumbnail;
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

-(void)setLoadingImageKeyStr:(NSString *)loadingImageKeyStr{
    objc_setAssociatedObject(self, loadingImageKeyStrKey, loadingImageKeyStr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)loadingImageKeyStr{
    return objc_getAssociatedObject(self, loadingImageKeyStrKey);
}

-(void)setLoadingImageKey:(long)loadingImageKey{
    self.loadingImageKeyStr =[NSString stringWithFormat:@"%ld",loadingImageKey];
    objc_setAssociatedObject(self, loadingImageKeyKey, [NSNumber numberWithLong:loadingImageKey], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(long)loadingImageKey{
    NSNumber *loadingImageKeyValue= objc_getAssociatedObject(self, loadingImageKeyKey);
    return [loadingImageKeyValue intValue];
}

-(void)setLoadingImagePathType:(NSString *)loadingImagePathType{
    objc_setAssociatedObject(self, loadingImagePathTypeKey, loadingImagePathType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)loadingImagePathType{
    return objc_getAssociatedObject(self, loadingImagePathTypeKey);
}


-(void)setUseLoadingDefaultImage:(BOOL)useLoadingDefaultImage{
    objc_setAssociatedObject(self, useLoadingDefaultImageKey, [NSNumber numberWithBool:useLoadingDefaultImage], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(BOOL)useLoadingDefaultImage{
    NSNumber *useLoadingDefaultImageValue= objc_getAssociatedObject(self, useLoadingDefaultImageKey);
    return [useLoadingDefaultImageValue boolValue];
}

-(void)setLoadingAnimation:(BOOL)loadingAnimation{
    objc_setAssociatedObject(self, loadingAnimationKey, [NSNumber numberWithBool:loadingAnimation], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(BOOL)loadingAnimation{
    NSNumber *loadingAnimationValue= objc_getAssociatedObject(self, loadingAnimationKey);
    return [loadingAnimationValue boolValue];
    
}
-(void)setControl:(UIControl *)control{
    objc_setAssociatedObject(self, controlKey, control, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIControl *)control{
    return objc_getAssociatedObject(self, controlKey);
}




-(void)setLoadingControlKeyStr:(NSString *)loadingControlKeyStr{
    objc_setAssociatedObject(self, loadingControlKeyStrKey, loadingControlKeyStr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if(self.control){
        self.control.keyStr=loadingControlKeyStr;
    }
}
-(NSString *)loadingControlKeyStr{
    return objc_getAssociatedObject(self, loadingControlKeyStrKey);
}

-(void)setLoadingControlKey:(long)loadingControlKey{
    objc_setAssociatedObject(self, loadingControlKeyKey, [NSNumber numberWithLong:loadingControlKey], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if(self.control){
        self.control.key=loadingControlKey;
    }
}
-(long)loadingControlKey{
    NSNumber *loadingImageKeyValue= objc_getAssociatedObject(self, loadingControlKeyKey);
    return [loadingImageKeyValue longValue];
}

#pragma mark - image path method
+ (NSString *)getFilename:(NSURL *)url {
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
    
    NSString *imageDirPath=[typeDirPath stringByAppendingPathComponent:self.loadingImageKeyStr];
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


#pragma mark - private loading method

-(void)dealloc{
    //    LOG_DEBUG(@"-------------------dealloc--------------");
    //remove self from manager
    if(self.control){
        [self.control removeFromSuperview];
    }
    
    objc_removeAssociatedObjects(self);
    if (self.loadingImageUrl) {
        ImageLoadEntry *entry=[ImageLoadManager findEntry:self.loadingImageUrl imageView:self];
        entry.imageView = NULL;
        entry.target = NULL;
        entry.success = NULL;
        entry.url = NULL;
        [ImageLoadManager removeEntry:self.loadingImageUrl entry:entry];
    }
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
    
    NSString *dirPath=[imageDirPath stringByAppendingPathComponent:className];
    
    NSMutableString *filePath=[[NSMutableString alloc] init];
    
    [filePath appendString:dirPath];
    
    
    [filePath appendString:@"."];
    [filePath appendString:@".png"];
    
    return filePath;
}

- (void)addClickTarget:(id)target action:(SEL)action{
    UIControl *_control=self.control;
    if(!_control){ 
        self.userInteractionEnabled =YES;
        _control=[[UIControl alloc] initWithFrame:self.bounds];
        _control.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _control.key=self.loadingControlKey;
        _control.keyStr=self.loadingControlKeyStr;
        [self addSubview:_control];
        [_control sendSubviewToBack:self];
        self.control =_control;
        [_control addTarget:self action:@selector(imageDown:) forControlEvents:UIControlEventTouchDown];
        [_control addTarget:self action:@selector(imageUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchCancel|UIControlEventTouchUpOutside|UIControlEventTouchDragOutside];
    }else{
        [_control removeTarget:target action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
    }
    [_control addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)removeClickTarget:(id)target action:(SEL)action{
    UIControl *_control=self.control;
    [_control removeTarget:self action:@selector(imageDown:) forControlEvents:UIControlEventTouchDown];
    [_control removeTarget:self action:@selector(imageUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchCancel|UIControlEventTouchUpOutside|UIControlEventTouchDragOutside];
    [_control removeTarget:target action:@selector(action) forControlEvents:UIControlEventTouchUpInside];

}
 
-(void)imageUp:(UIControl *)control{
    control.backgroundColor =[UIColor clearColor];
}
-(void)imageDown:(UIControl *)control{
    control.backgroundColor =[[UIColor blackColor] colorWithAlphaComponent:0.4f];
}

+(void)cancelImageLoadingQueue:(NSInteger)hashCode{
    [AFNetworkHttpRequestManager cancelQueue:hashCode];
    
}
-(void)recycleLoading{
    //    LOG_DEBUG(@"-------------------recycleLoading--------------");
    //TODO 设置内部取消状态
    [self.layer removeAllAnimations];
    
    if (self.loadingResourcePath) {
        ImageLoadEntry *entry=[ImageLoadManager findEntry:self.loadingResourcePath imageView:self];
        if(entry)
            [ImageLoadManager removeEntry:self.loadingResourcePath entry:entry];
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

-(void)processLocalImage:(ImageLoadEntry *)entry{
    @autoreleasepool {
        @try {
            if(self.imageRenderType==ImageRenderThumbnail){
                UIImage *image = [[self class] loadImage:self.loadingCacheKey secondKey:self.loadingResourcePath];
                if(image){
                    dispatch_main_sync_undeadlock_fun(^{
                        [self showLoadingImage:image];
                    });
                    
                    if(entry.target){
                        if([entry.target respondsToSelector:entry.success]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                            [entry.target performSelector:entry.success];
#pragma clang diagnostic pop
                        }
                    }
                    return;
                }
            }
            
            
            //            NSTimeInterval create= CFAbsoluteTimeGetCurrent();
            UIImage *image=[UIImage imageWithContentsOfFile:self.loadingResourcePath];
            __block UIImage *showImage=[self processImage:image];
            
            {
                if(showImage&&self.imageRenderType==ImageRenderThumbnail){
                    [[self class] loadImage:self.loadingCacheKey secondKey:self.loadingResourcePath image:showImage]; 
                }
                
            }
            
            //            NSLog(@"----------  process Time:%f   --------",CFAbsoluteTimeGetCurrent()-create);
            dispatch_main_sync_undeadlock_fun(^{
                [self showLoadingImage:showImage];
                //                NSLog(@"----------  show Time:%f   --------",CFAbsoluteTimeGetCurrent()-create);
            });
        }
        @catch (NSException *exception) {
#if DEBUG
            NSLog(@"%@",[[exception callStackSymbols] componentsJoinedByString:@"\n"]);
#endif
        }
    }
}


-(void)loadingAsyncLocalImage{
    if(self.imageRenderType==ImageRenderThumbnail){
        NSString *_imageType=self.loadingImagePathType;
        NSString *_imageKeyStr=self.loadingImageKeyStr;
        
        if(_imageType&&_imageKeyStr){
            self.loadingCacheKey = [NSString stringWithFormat:@"%@--%@",_imageType,_imageKeyStr];
        }else{
            if(!_imageType)
                _imageType =@"NULL";
            
            if(!_imageKeyStr)
                _imageKeyStr =@"NULL";
            
            NSException *e = [[NSException alloc] initWithName:nil reason:nil userInfo:nil];
            @throw e;
            
        }
    }
    
    [self.layer removeAllAnimations];
    self.loadingAnimation  = NO;
    
    [self showLoadingImage:nil];
    
    
    ImageLoadEntry *entry=[[ImageLoadEntry alloc] init];
    entry.url=self.loadingResourcePath;
    entry.success=NULL;
    entry.imageView=self;
    entry.target=NULL;
    [self performSelector:@selector(processLocalImage:) onThread:[[self class] imageProcessThread] withObject:entry waitUntilDone:NO];
}
-(void)loadingSyncLocalImage{
    UIImage *image;
    
    if(self.imageRenderType==ImageRenderThumbnail){
        NSString *_imageType=self.loadingImagePathType;
        NSString *_imageKeyStr=self.loadingImageKeyStr;
        
        if(_imageType&&_imageKeyStr){
            self.loadingCacheKey = [NSString stringWithFormat:@"%@--%@",_imageType,_imageKeyStr];
        }else{
            if(!_imageType)
                _imageType =@"NULL";
            
            if(!_imageKeyStr)
                _imageKeyStr =@"NULL";
            
            NSException *e = [[NSException alloc] initWithName:nil reason:nil userInfo:nil];
            @throw e;
            
        }
        image = [[self class] loadImage:self.loadingCacheKey secondKey:self.loadingResourcePath];
    }
    
    
    if(!image){
        image=[UIImage imageWithContentsOfFile:self.loadingResourcePath];
        if(image&&self.imageRenderType==ImageRenderThumbnail){
            [[self class] loadImage:self.loadingCacheKey secondKey:self.loadingResourcePath image:image];
        }
    }
    if(image){
        [self showLoadingImage:image];
    }
}


-(void)loadingAsyncImage:(NSString *)imageUrl{
    [self loadImage:imageUrl doneSelector:NULL withTarget:NULL fourceSync:NO];
}
-(void)loadingAsyncImage:(NSString *)imageUrl doneSelector:(SEL)aSelector withTarget:(id)target{
    [self loadImage:imageUrl doneSelector:aSelector withTarget:target fourceSync:NO];
}

-(void)loadingSyncImage:(NSString *)imageUrl{
    [self loadImage:imageUrl doneSelector:NULL withTarget:NULL fourceSync:YES];
}
-(void)loadingSyncImage:(NSString *)imageUrl doneSelector:(SEL)aSelector withTarget:(id)target{
    [self loadImage:imageUrl doneSelector:aSelector withTarget:target fourceSync:YES];
}

- (void)loadImage:(NSString *)imageUrl doneSelector:(SEL)aSelector withTarget:(id)target fourceSync:(BOOL)fourceSync{
    
    if (imageUrl == nil) {
        self.loadingAnimation = NO;
        [self showLoadingImage:nil];
        return;
    }
    
    
    @autoreleasepool {
        @try {
            self.loadingAnimation = NO;
            [self.layer removeAllAnimations];
            //            LOG_DEBUG(@"url:%@",imageUrl);
            
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
            NSString *_imageKeyStr=self.loadingImageKeyStr;
            
            if(_imageType&&_imageKeyStr){
                self.loadingCacheKey = [NSString stringWithFormat:@"%@--%@",_imageType,_imageKeyStr];
                
                self.loadingResourcePath=[self parseLoadingThumbUrl:[NSURL URLWithString:imageUrl]];
            }else{
                if(!_imageType)
                    _imageType =@"NULL";
                
                if(!_imageKeyStr)
                    _imageKeyStr =@"NULL";
                
                NSException *e = [[NSException alloc] initWithName:nil reason:nil userInfo:nil];
                @throw e;
                
            }
            UIImage *image;
            
            if(self.imageRenderType==ImageRenderThumbnail){
                
                image = [[self class] loadImage:self.loadingCacheKey secondKey:self.loadingResourcePath];
                if(image){
                    [self showLoadingImage:image];
                    
                    if(target){
                        if([target respondsToSelector:aSelector]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                            [target performSelector:aSelector];
#pragma clang diagnostic pop
                        }
                    }
                    return;
                }
            }
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL existed = [fileManager fileExistsAtPath:self.loadingResourcePath];
            image=[UIImage imageWithContentsOfFile:self.loadingResourcePath];
            if (existed&&image) {
                if(fourceSync){ 
                    if(image&&self.imageRenderType==ImageRenderThumbnail){
                        [[self class] loadImage:self.loadingCacheKey secondKey:self.loadingResourcePath image:image]; 
                    }
                    
                    [self showLoadingImage:image];
                    if(target){
                        if([target respondsToSelector:aSelector]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                            [target performSelector:aSelector];
#pragma clang diagnostic pop
                        }
                    }
                }else{
                    if(self.defaultLoadingImage)
                        [self showLoadingImage:nil];
                    
                    ImageLoadEntry *entry=[[ImageLoadEntry alloc] init];
                    entry.url=self.loadingResourcePath;
                    entry.success=aSelector;
                    entry.imageView=self;
                    entry.target=target;
                    [self performSelector:@selector(processLocalImage:) onThread:[[self class] imageProcessThread] withObject:entry waitUntilDone:NO];
                }
            }else{
                if(self.defaultLoadingImage)
                    [self showLoadingImage:nil];
                
                
                {
                    ImageLoadEntry *entry=[[ImageLoadEntry alloc] init];
                    entry.url=self.loadingResourcePath;
                    entry.success=aSelector;
                    entry.imageView=self;
                    entry.target=target;
                    [ImageLoadManager addEntry:entry];
                }
                
                if([ImageLoadManager isDownloading:self.loadingResourcePath])
                    return;
                
                [ImageLoadManager addDownload:self.loadingResourcePath];
                
                {
                    DownloadEntry *entry=[[DownloadEntry alloc] init];
                    entry.queueID=self.loadingQueueId;
                    entry.resourcePath=self.loadingResourcePath;
                    entry.cacheKey=self.loadingCacheKey;
                    entry.URL=self.loadingImageUrl;
                    [self performSelector:@selector(loadingImage:) onThread:[[self class] imageLoadingThread] withObject:entry waitUntilDone:NO];
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
-(UIImage *)processImage:(UIImage *)image{
    CGRect rect = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
	UIGraphicsBeginImageContext(rect.size);
	[image drawInRect:rect];  // scales image to rect
	UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return resImage;
}

#pragma mark - other thread


-(void)processLoadingImage:(DownloadEntry *)entry{
    @autoreleasepool {
        @try {
            
            NSMutableSet *entrys= [ImageLoadManager findAllEntry:entry.resourcePath];
            
            UIImage *showImage;
            if(self.imageRenderType==ImageRenderThumbnail){
                showImage = [[self class] loadImage:entry.cacheKey secondKey:entry.resourcePath];
            }
            UIImage *image = nil;
            if(!showImage){
                image=[UIImage imageWithContentsOfFile:entry.resourcePath];
            }
            
            for (ImageLoadEntry *imageEntry in entrys) {
                
                if(!showImage){
                    showImage=[imageEntry.imageView processImage:image];
                    if(showImage&&self.imageRenderType==ImageRenderThumbnail){
                        [[self class] loadImage:entry.cacheKey secondKey:entry.resourcePath image:showImage];
                    }
                }
                
                dispatch_main_sync_undeadlock_fun(^{
                    imageEntry.imageView.loadingAnimation = YES;
                    [imageEntry.imageView showLoadingImage:showImage];
                });
                
                if(imageEntry.target){
                    if([imageEntry.target respondsToSelector:imageEntry.success]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        [imageEntry.target performSelector:imageEntry.success];
#pragma clang diagnostic pop
                    }
                }
                
                imageEntry.imageView = NULL;
                imageEntry.target = NULL;
                imageEntry.success = NULL;
                imageEntry.url = NULL;
            }
        }
        @catch (NSException *exception) {
#if DEBUG
            NSLog(@"%@",[[exception callStackSymbols] componentsJoinedByString:@"\n"]);
#endif
        }@finally {
            [ImageLoadManager removeAllEntry:entry.resourcePath];
        }
    }
}

-(void)loadingImage:(DownloadEntry *)entry{
    @autoreleasepool {
        @try {
            AFImageDownloadRequest *downloadRequest=[[AFImageDownloadRequest alloc] initWithURL:entry.URL];
            downloadRequest.filePath=entry.resourcePath;
            
#if DEBUG
            NSLog(@"url requestId:%d imageUrl:%@",downloadRequest.requestId,entry.URL);
           
#endif
            
            [ImageLoadManager addRequestID:downloadRequest.requestId key:entry.resourcePath];
            
            //            LOG_DEBUG(@"-----self:%@ ",self);
            
            [downloadRequest completionBlock:^(AFNetworkingBaseRequest *request, NSInteger statusCode) {
                
                @try {
                    if(statusCode==200){
                        //                        LOG_DEBUG(@"resourcePath:%@",entry.resourcePath);
                        [self performSelector:@selector(processLoadingImage:) onThread:[UIImageView imageProcessThread] withObject:entry waitUntilDone:NO];
                    }
                    else if(statusCode == 404){
#if DEBUG
                        NSLog(@"404:%@",entry.resourcePath);
#endif
                    }
                }@catch (NSException *exception) {
#if DEBUG
                    NSLog(@"%@",[[exception callStackSymbols] componentsJoinedByString:@"\n"]);
#endif
                }@finally {
                    [ImageLoadManager removeDownload:entry.resourcePath];
                }
            }];
            
            [downloadRequest executeAsync:entry.queueID];
            
        }@catch (NSException *exception) {
#if DEBUG
            NSLog(@"%@",[[exception callStackSymbols] componentsJoinedByString:@"\n"]);
#endif
            [ImageLoadManager removeDownload:entry.resourcePath];
        }
    }
}
 




@end

