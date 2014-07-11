//
//  UIImageView+Loading.h
//  Gallery
//
//  Created by junhai on 12-12-31.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImageScaleClip)
 
- (UIImage *)rescaleImageToSize:(CGSize)size;                   //图片大小重定义

- (UIImage *)clipImageToSize:(CGSize)size scale:(BOOL)scale;    //图片裁剪并且缩放

- (UIImage *)cornerImageToRadius:(int)radius margin:(int)margin marginColor:(UIColor *)clolor; //图片圆角、边框

- (UIImage *)scaleImageToSize:(CGSize)size;                     //图片等比例缩放 

@end


@interface UIControl(Extras)

-(void)setKey:(long long)key;                          //图片标号，用于本地保存使用

-(long long)key;

-(void)setKeyStr:(NSString *)keyStr;                          //图片标号，用于本地保存使用

-(NSString *)keyStr;


@end


typedef enum ImageRenderType {
	ImageRenderThumbnail = 0,   //缩略图
	ImageRenderOriginal = 1,     //原图
} ImageRenderType;

@interface UIImageView (Loading)

+ (NSThread *)imageProcessThread;

+ (NSThread *)imageLoadingThread;

+(void)cancelImageLoadingQueue:(NSInteger)hashCode;              //取消图片下载 

-(void)setDefaultLoadingImage:(UIImage *)defaultLoadingImage;             //默认图片

-(UIImage *)defaultLoadingImage;

-(void)setLoadingQueueId:(NSInteger)loadingQueueId;                       //图片下载时队列编号

-(NSInteger)loadingQueueId;

-(void)setImageRenderType:(ImageRenderType)imageRenderType;         //图片是否为原图

-(NSInteger)imageRenderType;

-(void)setLoadingCacheKey:(NSString *)loadingCacheKey;            //下载地址对应在本地的图片

-(NSString *)loadingCacheKey;

-(void)setLoadingResourcePath:(NSString *)loadingResourcePath;            //下载地址对应在本地的图片

-(NSString *)loadingResourcePath;

-(void)setLoadingImageUrl:(NSString *)loadingImageUrl;          //图片分类，用于本地保存使用

-(NSString *)loadingImageUrl;

-(void)setLoadingImageKeyStr:(NSString *)loadingImageKeyStr;              //图片标号，用于本地保存使用

-(NSString *)loadingImageKeyStr;

-(void)setLoadingImageKey:(long long)loadingImageKey;                          //图片标号，用于本地保存使用

-(long long)loadingImageKey;

-(void)setLoadingImagePathType:(NSString *)loadingImagePathType;          //图片分类，用于本地保存使用

-(NSString *)loadingImagePathType;

-(void)setUseLoadingDefaultImage:(BOOL)useLoadingDefaultImage;            //是否使用了默认图片

-(BOOL)useLoadingDefaultImage;

-(void)setLoadingAnimation:(BOOL)loadingAnimation;                            //异步处理

-(BOOL)loadingAnimation;

-(void)setControl:(UIControl *)control;

-(UIControl *)control;

-(void)setLoadingControlKeyStr:(NSString *)loadingControlKeyStr;              //图片标号，用于本地保存使用

-(NSString *)loadingControlKeyStr;

-(void)setLoadingControlKey:(long long)loadingControlKey;                          //图片标号，用于本地保存使用

-(long long)loadingControlKey;

#pragma mark - public loading method
 
- (NSString *)parseLoadingThumbUrl:(NSURL *)url; 

+(void)clearImageCache:(NSString *)imagePathType imageKey:(NSString *)imageKey;

+(NSString *)parseImagePath:(NSString *)imagePathType imageKey:(NSString *)imageKey url:(NSURL *)url;

- (void)addClickTarget:(id)target action:(SEL)action;

- (void)removeClickTarget:(id)target action:(SEL)action;

-(void)showLoadingImage:(UIImage *)image;                          //设置显示图片，image为空时会显示默认图片

-(void)recycleLoading;                                      //回收未开始的下载

-(void)loadingAsyncLocalImage;

-(void)loadingSyncLocalImage;

-(void)loadingAsyncImage:(NSString *)imageUrl;                 //异步下载图片，如果本地有图片的话是同步方式加载本地图片

-(void)loadingAsyncImage:(NSString *)imageUrl doneSelector:(SEL)aSelector withTarget:(id)target;

-(void)loadingSyncImage:(NSString *)_imageUrl;

-(void)loadingSyncImage:(NSString *)_imageUrl doneSelector:(SEL)aSelector withTarget:(id)target;

@end





