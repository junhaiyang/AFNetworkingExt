//
//  UIImageView+AddLoadingPath.h 
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define UIIMAGEVIEW_ADDLOADINGPATH_KEY @"img"
#define UIIMAGEVIEW_ADDLOADINGPATH_TYPE @"default"

#define UIIMAGEVIEW_ADDLOADINGPATH_QUEUE 987654321

@interface UIImageView (AddLoadingPath)

#pragma mark - image path

@property (nonatomic,strong) NSString *loadingCacheKey;

@property (nonatomic,strong) NSString *loadingResourcePath;
@property (nonatomic,strong) NSString *loadingImageUrl;

// This method has been replaced by loadingImagePathKey
@property (nonatomic,strong) NSString *loadingImageKeyStr    NS_DEPRECATED_IOS(2_0, 5_0);

// This method has been replaced by loadingImagePathKey
@property (nonatomic,assign) long      loadingImageKey       NS_DEPRECATED_IOS(2_0, 5_0);

@property (nonatomic,strong) NSString *loadingImagePathKey   NS_AVAILABLE_IOS(5_0);         //图片分组编号，非必须
@property (nonatomic,strong) NSString *loadingImagePathType;    //图片分组，非必须

@property (nonatomic,strong) NSString *loadingToken;    

@property (nonatomic,assign) NSInteger  loadingQueueId;

@property (nonatomic,strong) id  loadingTarget              NS_AVAILABLE_IOS(5_0);
@property (nonatomic,strong) NSString *loadingAction        NS_AVAILABLE_IOS(5_0);
 

-(void)recycleLoadingPath;


#pragma mark - image cache method 

// This method use in
// - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
+ (void)setImageCacheSize:(CGSize)size              NS_AVAILABLE_IOS(5_0);

+ (NSCache *)defaultCache;

+ (UIImage *)loadImage:(NSString *)rootKey secondKey:(NSString *)secondKey;

+ (void)loadImage:(NSString *)rootKey secondKey:(NSString *)secondKey image:(UIImage *)image;

+ (BOOL)supportCache:(UIImage *)image;


#pragma mark - image path method

-(NSString *)parseLoadingThumbUrl:(NSURL *)url;
 
+(void)clearAllImageAllCacheFile;

+(void)clearImageCache:(NSString *)imagePathType imageKey:(NSString *)imageKey;

+(NSString *)parseImagePath:(NSString *)imagePathType imageKey:(NSString *)imageKey url:(NSURL *)url;


@end
