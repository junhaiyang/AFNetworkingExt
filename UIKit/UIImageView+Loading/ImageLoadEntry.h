//
//  ImageLoadEntry.h
//
//
//
//
//

#import <Foundation/Foundation.h>

@interface DownloadEntry : NSObject

@property (nonatomic,assign) NSInteger queueID;
@property (nonatomic,strong) NSString *URL;
@property (nonatomic,strong) NSString *resourcePath;
@property (nonatomic,strong) NSString *cacheKey;

@end

@interface ImageLoadData : NSObject

@property (nonatomic,assign) NSInteger requestID;
@property(nonatomic,strong) NSMutableSet *imageSet;

@end

@interface ImageLoadEntry : NSObject
@property (nonatomic,strong) NSString *url;    //标识
@property (nonatomic,weak) id  target;         //回调目标
@property (nonatomic,assign) SEL  success;        //成功回调
@property (nonatomic,assign) SEL  error;          //失败回调
@property (nonatomic,assign) SEL  cancel;         //取消回调
@property (nonatomic,strong) UIImageView *imageView;  //绘制界面的view

@end

@interface ImageLoadManager : NSObject

+ (ImageLoadEntry *)findEntry:(NSString *)key imageView:(UIImageView *)imageView;


+ (void)addRequestID:(NSInteger)requestID key:(NSString *)key;

+ (void)addEntry:(ImageLoadEntry *)entry;
+ (void)removeEntry:(NSString *)key entry:(ImageLoadEntry *)entry;

+ (NSMutableSet *)findAllEntry:(NSString *)key;
+ (void)removeAllEntry:(NSString *)key;

+ (BOOL)isDownloading:(NSString *)key;
+ (void)addDownload:(NSString *)key;
+ (void)removeDownload:(NSString *)key;

@end
