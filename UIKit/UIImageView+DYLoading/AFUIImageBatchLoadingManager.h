//
//  UIImageBatchLoadingManager.h 
//

#import <Foundation/Foundation.h>

extern NSString *const kAFDYUIImageViewLoadedImageNotification;

@interface AFUIImageLoadedEntry : NSObject

@property (nonatomic,strong) NSString *imagePath;
@property (nonatomic,strong) UIImage *image;

@end

@interface AFUIImageBatchLoadingManager : NSObject

+(AFUIImageBatchLoadingManager *)shareInstance;

+(NSString *)loadingToken;

-(void)startLoad:(NSString *)resourcePath token:(NSString *)token url:(NSString *)url cacheKey:(NSString *)cacheKey queueId:(NSInteger)queueId isLocal:(BOOL)local;

-(void)stopLoad:(NSString *)resourcePath token:(NSString *)token;

@end
