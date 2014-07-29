//
//  UIImageView+AddLoadingParam.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


// This type has been replaced by UIImageView(AddLoadingPath)->  setImageCacheSize:

typedef enum ImageRenderType {
	ImageRenderThumbnail = 0,   //缩略图
	ImageRenderOriginal = 1,     //原图
} ImageRenderType NS_DEPRECATED_IOS(2_0, 5_0, "Delete");

@interface UIControl(AddLoadingParam)

// This method has been replaced by UIImageView(AddLoadingParam)->loadingTargetKey
@property (nonatomic,assign) long      key       NS_DEPRECATED_IOS(2_0, 5_0, "Use .loadingTargetKey");

@end



@interface UIImageView(AddLoadingParam)

#pragma mark - normal target
@property (nonatomic,strong) UIImage *defaultLoadingImage;  //默认图片
@property (nonatomic,assign) BOOL  useLoadingDefaultImage;  //是否使用了默认图片

// This method has been replaced by UIImageView(AddLoadingPath)->  +setImageCacheSize:
@property (nonatomic,assign) ImageRenderType  imageRenderType NS_DEPRECATED_IOS(2_0, 5_0, "Delete");

@property (nonatomic,assign) BOOL  loadingAnimation;
@property (nonatomic,assign) BOOL  loadingObserverNotification;

#pragma mark - control target
// This method has been replaced by loadingTargetKey
@property (nonatomic,strong) NSString *loadingControlKeyStr    NS_DEPRECATED_IOS(2_0, 5_0, "Use .loadingTargetKey");
// This method has been replaced by loadingTargetKey
@property (nonatomic,assign) long      loadingControlKey       NS_DEPRECATED_IOS(2_0, 5_0, "Use .loadingTargetKey");
// This method has been replaced by loadingTargetKey
@property (nonatomic,assign) long      key                     NS_DEPRECATED_IOS(2_0, 5_0, "Use .loadingTargetKey");

@property (nonatomic,strong) NSString *loadingTargetKey        NS_AVAILABLE_IOS(5_0);

// This method has been replaced by addTarget:action:
- (void)addClickTarget:(id)target action:(SEL)action           NS_DEPRECATED_IOS(2_0, 5_0, "Use -addTarget:action:");


// This method has been replaced by removeTarget:action:
- (void)removeClickTarget:(id)target action:(SEL)action        NS_DEPRECATED_IOS(2_0, 5_0, "Use -removeTarget:action:");


// action:@selector(methed:)
// -(void)methed:(UIImageView)imageView{  //TODO    }
- (void)addTarget:(id)target action:(SEL)action                NS_AVAILABLE_IOS(5_0);
- (void)removeTarget:(id)target action:(SEL)action             NS_AVAILABLE_IOS(5_0);

-(void)recycleLoadingPatma; 


@end
