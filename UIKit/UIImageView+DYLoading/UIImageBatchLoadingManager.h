//
//  UIImageBatchLoadingManager.h 
//

#import <Foundation/Foundation.h>

extern NSString *const kDYUIImageViewLoadedImageNotification;

@interface UIImageLoadedEntry : NSObject

@property (nonatomic,strong) NSString *imagePath;
@property (nonatomic,strong) UIImage *image;

@end

@interface UIImageBatchLoadingManager : NSObject

+(UIImageBatchLoadingManager *)shareInstance;

+(NSString *)loadingToken;

-(void)startLoad:(NSString *)resourcePath token:(NSString *)token url:(NSString *)url cacheKey:(NSString *)cacheKey queueId:(NSInteger)queueId isLocal:(BOOL)local;

-(void)stopLoad:(NSString *)resourcePath token:(NSString *)token;

@end
