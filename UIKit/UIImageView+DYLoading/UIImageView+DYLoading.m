//
//  UIImageView+DYLoading.m 
//

#import "UIImageView+DYLoading.h"
#import <objc/runtime.h>
#import "AFNetworkingHttpQueueManager.h"
#import "UIImageBatchLoadingManager.h"

void dispatch_imageview_load_image_main_sync_undeadlock_fun(dispatch_block_t block){
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}


@implementation UIImageView (DYLoading)


- (void)refrashLoadedImage:(NSNotification *)note {
    
    UIImageLoadedEntry *loadedEnyry = (UIImageLoadedEntry *) [note object];
    
    if([loadedEnyry isKindOfClass:[UIImageLoadedEntry class]]){
    
        if([self.loadingResourcePath isEqualToString:loadedEnyry.imagePath]){
            
            __weak UIImageView *weakSelf =self;
            __block UIImage *blockImage =loadedEnyry.image;
            
            dispatch_imageview_load_image_main_sync_undeadlock_fun(^{
                weakSelf.loadingAnimation = YES;
                [weakSelf showLoadingImage:blockImage];
            });
        
            
        }
    
    } 
}

+(void)cancelImageLoadingQueue:(NSInteger)hashCode{
    [AFNetworkHttpRequestManager cancelQueue:hashCode];
    
}
-(void)dealloc{
#if DEBUG
      NSLog(@"-------------------dealloc--------------");
#endif
    
    [self.layer removeAllAnimations];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.loadingResourcePath) {
        
        
        [[UIImageBatchLoadingManager  shareInstance] stopLoad:self.loadingResourcePath token:self.loadingToken];
        
    }
    [self recycleLoadingPath];
    [self recycleLoadingPatma];
    
    objc_removeAssociatedObjects(self);
    
}
-(void)recycleLoading{
    //    LOG_DEBUG(@"-------------------recycleLoading--------------");
    //TODO 设置内部取消状态
    [self.layer removeAllAnimations];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.loadingResourcePath) {
        
        
        [[UIImageBatchLoadingManager  shareInstance] stopLoad:self.loadingResourcePath token:self.loadingToken];
        
    }
    [self recycleLoadingPath];
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


-(void)loadingAsyncLocalImage{
    
    NSString *_imageType=self.loadingImagePathType;
    NSString *_imageKey=self.loadingImagePathKey;
    
    if(!_imageType)
        _imageType =UIIMAGEVIEW_ADDLOADINGPATH_TYPE;
    if(!_imageKey)
        _imageKey =UIIMAGEVIEW_ADDLOADINGPATH_KEY;
    
    self.loadingCacheKey = [NSString stringWithFormat:@"%@--%@",_imageType,_imageKey];
 
    
    [self.layer removeAllAnimations];
    self.loadingAnimation  = NO;
    
    [self showLoadingImage:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refrashLoadedImage:) name:kDYUIImageViewLoadedImageNotification object:nil];
    
    [UIImageBatchLoadingManager shareInstance];
    
    self.loadingToken =[UIImageBatchLoadingManager  loadingToken];
    
    [[UIImageBatchLoadingManager  shareInstance] startLoad:self.loadingResourcePath token:self.loadingToken url:self.loadingImageUrl cacheKey:self.loadingCacheKey queueId:self.loadingQueueId isLocal:YES];
}
-(void)loadingSyncLocalImage{
    UIImage *image;
    
    
    NSString *_imageType=self.loadingImagePathType;
    NSString *_imageKey=self.loadingImagePathKey;
    
    if(!_imageType)
        _imageType =UIIMAGEVIEW_ADDLOADINGPATH_TYPE;
    if(!_imageKey)
        _imageKey =UIIMAGEVIEW_ADDLOADINGPATH_KEY;
    
    self.loadingCacheKey = [NSString stringWithFormat:@"%@--%@",_imageType,_imageKey];
    
    image = [[self class] loadImage:self.loadingCacheKey secondKey:self.loadingResourcePath];
    
    if(!image){
        image=[[UIImage alloc] initWithContentsOfFile:self.loadingResourcePath];
    }
    if(image){
        [self showLoadingImage:image];
    }
}
-(void)fireTarget{
    SEL sel = NSSelectorFromString([self loadingAction]);
    id target = [self loadingTarget];

    if(target){
        if([target respondsToSelector:sel]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector:sel withObject:self];
#pragma clang diagnostic pop
        }
    }
}

-(void)loadingCompletionSelector:(SEL)aSelector withTarget:(id)target{
    
    self.loadingTarget =target;
    NSString *selStr =NSStringFromSelector(aSelector);
    self.loadingAction  =selStr;
}

-(void)loadingAsyncImage:(NSString *)imageUrl{
    [self loadImage:imageUrl fourceSync:NO];
}
-(void)loadingAsyncImage:(NSString *)imageUrl doneSelector:(SEL)aSelector withTarget:(id)target{
    
    self.loadingTarget =target;
    NSString *selStr =NSStringFromSelector(aSelector);
    self.loadingAction  =selStr;
    
    [self loadImage:imageUrl fourceSync:NO];
}

-(void)loadingSyncImage:(NSString *)imageUrl{
    [self loadImage:imageUrl  fourceSync:YES];
}
-(void)loadingSyncImage:(NSString *)imageUrl doneSelector:(SEL)aSelector withTarget:(id)target{
    
    self.loadingTarget =target;
    NSString *selStr =NSStringFromSelector(aSelector);
    self.loadingAction  =selStr;
    
    [self loadImage:imageUrl fourceSync:YES];
}

- (void)loadImage:(NSString *)imageUrl fourceSync:(BOOL)fourceSync{
    
    if (imageUrl == nil) {
        self.loadingAnimation = NO;
        [self showLoadingImage:nil];
        return;
    }
    
    
    [UIImageBatchLoadingManager shareInstance];
    
    self.loadingToken =[UIImageBatchLoadingManager  loadingToken];
    
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
            
            if(self.loadingQueueId ==0)
                self.loadingQueueId = UIIMAGEVIEW_ADDLOADINGPATH_QUEUE;
            
            self.loadingImageUrl =imageUrl;
            
            NSString *_imageType=self.loadingImagePathType;
            NSString *_imageKey=self.loadingImagePathKey;
            
            if(!_imageType)
                _imageType =UIIMAGEVIEW_ADDLOADINGPATH_TYPE;
            if(!_imageKey)
                _imageKey =UIIMAGEVIEW_ADDLOADINGPATH_KEY;
            
            self.loadingCacheKey = [NSString stringWithFormat:@"%@--%@",_imageType,_imageKey];
            
            self.loadingResourcePath=[self parseLoadingThumbUrl:[NSURL URLWithString:imageUrl]];
            
            UIImage *image = [[self class] loadImage:self.loadingCacheKey secondKey:self.loadingResourcePath];
            if(image){
                [self showLoadingImage:image];
                
                [self fireTarget];
                return;
            }
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL existed = [fileManager fileExistsAtPath:self.loadingResourcePath];
             
            if(existed){
                if(fourceSync){
                    UIImage *image=[[UIImage alloc] initWithContentsOfFile:self.loadingResourcePath];
                    if(image){
                        if([UIImageView supportCache:image]){
                            [[self class] loadImage:self.loadingCacheKey secondKey:self.loadingResourcePath image:image];
                        }
                        
                        [self showLoadingImage:image];
                        
                        [self fireTarget];
                        
                        return;
                    }
                }
            
            }
            
            if(self.defaultLoadingImage)
                [self showLoadingImage:nil];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refrashLoadedImage:) name:kDYUIImageViewLoadedImageNotification object:nil];
            
            [[UIImageBatchLoadingManager  shareInstance] startLoad:self.loadingResourcePath token:self.loadingToken url:self.loadingImageUrl cacheKey:self.loadingCacheKey queueId:self.loadingQueueId isLocal:NO];
            
        }
        @catch (NSException *exception) {
#if DEBUG
            NSLog(@"%@",[[exception callStackSymbols] componentsJoinedByString:@"\n"]);
#endif
        }
    }
    
}


@end
