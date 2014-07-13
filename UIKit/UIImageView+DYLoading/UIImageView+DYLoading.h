//
//  UIImageView+CacheLoading.h 
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIImageViewRenderType){
	UIImageViewRenderThumbnail = 0,   //缩略图
	UIImageViewRenderOriginal = 1,     //原图
} ;

typedef NS_ENUM(NSInteger, UIImageViewProgressType)
{
    UIImageViewProgressTypeAnnular,
    UIImageViewProgressTypeCircle = 1,
    UIImageViewProgressTypePie = 2
};

@class UIImageProgressAppearance;

@interface  UIImageProgressView : UIView


@property (assign, nonatomic) float progress;
@property (strong, nonatomic) UIImageProgressAppearance *progressAppearance;


@end


@interface  UIImageProgressAppearance : NSObject


@property (assign, nonatomic) UIImageViewProgressType type;

@property (assign, nonatomic) BOOL showPercentage;


@property (strong, nonatomic) UIColor *schemeColor;
@property (strong, nonatomic) UIColor *progressTintColor;
@property (strong, nonatomic) UIColor *backgroundTintColor;
@property (strong, nonatomic) UIColor *percentageTextColor;

@property (strong, nonatomic) UIFont *percentageTextFont;
@property (assign, nonatomic) CGPoint percentageTextOffset;


+ (UIImageProgressAppearance *)sharedProgressAppearance;


@end



@interface UIImageView (DYLoading)

@property (nonatomic,strong) UIImageProgressView *progressView;
@property (strong, nonatomic) UIImageProgressAppearance *progressAppearance;

#pragma mark - delegate

@property (nonatomic,weak) id  target;         //回调目标
@property (nonatomic,strong) NSString  *sel;        //成功回调


- (void)setProgress:(float)newProgress;

#pragma mark - property


@property (nonatomic,strong) UIImage *defaultLoadingImage;

@property (nonatomic,assign) BOOL  useLoadingDefaultImage;

@property (nonatomic,strong) NSString *loadingImageUrl; //本地原始地址


@property (nonatomic,strong) NSString *loadingResourcePath; //本地缓存文件地址

@property (nonatomic,strong) NSString *loadingImagePathType; //图片分类，用于本地保存使用

@property (nonatomic,strong) NSString *loadingImageKey; //图片标号，用于本地保存使用

@property (nonatomic,strong) NSString *loadingCacheKey; //图片标号，用于本地保存使用

@property (nonatomic,assign) BOOL loadingprogressAnimation; //图片动画状态


@property (nonatomic,assign) BOOL loadingAnimation; //图片动画状态

@property (nonatomic,assign) NSInteger loadingQueueId; //图片下在队列


@property (nonatomic,assign) UIImageViewRenderType imageRenderType; //图片是否为原图

#pragma mark - Instance Method

+(void)cancelImageLoadingQueue:(NSInteger)hashCode;              //取消图片下载

+(void)clearImageCache:(NSString *)imagePathType imageKey:(NSString *)imageKey;

+(NSString *)parseImagePath:(NSString *)imagePathType imageKey:(NSString *)imageKey url:(NSURL *)url;


#pragma mark - public loading method


-(void)showLoadingImage:(UIImage *)image;                          //设置显示图片，image为空时会显示默认图片

-(void)recycleLoading;                                      //回收未开始的下载

-(void)loadingAsyncLocalImage;

-(void)loadingSyncLocalImage;

-(void)loadingAsyncImage:(NSString *)imageUrl;                 //异步下载图片，如果本地有图片的话是同步方式加载本地图片

-(void)loadingAsyncImage:(NSString *)imageUrl doneSelector:(SEL)aSelector withTarget:(id)target;

-(void)loadingSyncImage:(NSString *)_imageUrl;

-(void)loadingSyncImage:(NSString *)_imageUrl doneSelector:(SEL)aSelector withTarget:(id)target;

-(void)imageSelSelecer; 


@end
