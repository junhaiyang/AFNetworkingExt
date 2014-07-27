//
//  UIImageView+DYLoading.h 
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIImageView+AddLoadingParam.h"
#import "UIImageView+AddLoadingPath.h"

/**
 * 图片异步加载，同一界面出现加载多个相同图片时会自动合并加载处理，并且允许随时取消其中一个的加载
 * 使用 本地文件+内存 二级缓存机制
 **/
@interface UIImageView (DYLoading)


+(void)cancelImageLoadingQueue:(NSInteger)queueId;              //取消图片下载 
 
-(void)showLoadingImage:(UIImage *)image;                          //设置显示图片，image为空时会显示默认图片

-(void)recycleLoading;                                             //取消图片异步加载

-(void)loadingAsyncLocalImage;                                     //异步处理本地图片

-(void)loadingSyncLocalImage;                                      //同步处理本地图片

-(void)loadingAsyncImage:(NSString *)imageUrl;                     //异步下载图片，如果本地有图片的话是同步方式加载本地图片

// This method has been replaced by loadingAsyncImage:
// and  @property    loadingTarget
//      @property    loadingAction
-(void)loadingAsyncImage:(NSString *)imageUrl doneSelector:(SEL)aSelector withTarget:(id)target NS_DEPRECATED_IOS(2_0, 8_0);

-(void)loadingSyncImage:(NSString *)imageUrl;

// This method has been replaced by loadingSyncImage:
// and  @property    loadingTarget
//      @property    loadingAction
-(void)loadingSyncImage:(NSString *)imageUrl doneSelector:(SEL)aSelector withTarget:(id)target NS_DEPRECATED_IOS(2_0, 8_0);


@end
