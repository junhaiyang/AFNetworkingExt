//
//  UIImageView+AddLoadingParam.m 
//

#import "UIImageView+AddLoadingParam.h"
#import <objc/runtime.h>

@implementation UIControl(AddLoadingParam)
static const char *addLoadingParamKey         ="__UIControl_AddLoadingParam_Key__";


-(void)setKey:(long)key{
    objc_setAssociatedObject(self, addLoadingParamKey,[NSString stringWithFormat:@"%ld",key], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(long)key{
    NSString *loadingImageKeyValue= objc_getAssociatedObject(self, addLoadingParamKey);
    return (long)[loadingImageKeyValue longLongValue];
}

@end
 

@implementation UIImageView (AddLoadingParam)


@dynamic defaultLoadingImage;
@dynamic useLoadingDefaultImage;

@dynamic imageRenderType;
 
@dynamic loadingAnimation;
 
@dynamic loadingTargetKey;


#pragma mark - normal target
static const char *defaultLoadingImageKey      ="__defaultLoadingImage__";
static const char *imageShowSizeTypeKey        ="__imageShowSizeType__";
static const char *useLoadingDefaultImageKey   ="__useLoadingDefaultImageKey__";
static const char *loadingAnimationKey         ="__loadingAnimationKey__";
static const char *loadingObserverNotificationKey         ="__loadingObserverNotificationKey__";


-(void)setDefaultLoadingImage:(UIImage *)defaultLoadingImage{
    objc_setAssociatedObject(self, defaultLoadingImageKey, defaultLoadingImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UIImage *)defaultLoadingImage{
    return objc_getAssociatedObject(self, defaultLoadingImageKey);
}

-(void)setImageRenderType:(ImageRenderType)imageRenderType{
    objc_setAssociatedObject(self, imageShowSizeTypeKey, [NSNumber numberWithInt:imageRenderType], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(ImageRenderType)imageRenderType{
    
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

-(void)setLoadingObserverNotification:(BOOL)loadingObserverNotification{
    objc_setAssociatedObject(self, loadingObserverNotificationKey, [NSNumber numberWithBool:loadingObserverNotification], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(BOOL)loadingObserverNotification{
    NSNumber *loadingAnimationValue= objc_getAssociatedObject(self, loadingObserverNotificationKey);
    return [loadingAnimationValue boolValue];
}

#pragma mark - control target

static const char *UIImageView_Click_Control             ="__UIImageView_Click_Control__";
static const char *UIImageView_Click_ControlKey          ="__UIImageView_Click_ControlKey__";
static const char *UIImageView_Click_Target              ="__UIImageView_Click_Target__";
static const char *UIImageView_Click_SEL                 ="__UIImageView_Click_SEL__";

-(void)setLoadingTargetKey:(NSString *)loadingTargetKey{
    objc_setAssociatedObject(self, UIImageView_Click_ControlKey, loadingTargetKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)loadingTargetKey{
    return objc_getAssociatedObject(self, UIImageView_Click_ControlKey);
}
-(void)setLoadingControlKeyStr:(NSString *)loadingControlKeyStr{
    objc_setAssociatedObject(self, UIImageView_Click_ControlKey, loadingControlKeyStr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)loadingControlKeyStr{
    return objc_getAssociatedObject(self, UIImageView_Click_ControlKey);
}

-(void)setLoadingControlKey:(long)loadingControlKey{
    objc_setAssociatedObject(self, UIImageView_Click_ControlKey,[NSString stringWithFormat:@"%ld",loadingControlKey], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(long)loadingControlKey{
    NSString *loadingImageKeyValue= objc_getAssociatedObject(self, UIImageView_Click_ControlKey);
    return (long)[loadingImageKeyValue longLongValue];
}
-(void)setKey:(long)key{
    objc_setAssociatedObject(self, UIImageView_Click_ControlKey,[NSString stringWithFormat:@"%ld",key], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(long)key{
    NSString *loadingImageKeyValue= objc_getAssociatedObject(self, UIImageView_Click_ControlKey);
    return (long)[loadingImageKeyValue longLongValue];
}
- (void)addClickTarget:(id)target action:(SEL)action{
    [self addTarget:target action:action];
}

- (void)removeClickTarget:(id)target action:(SEL)action{
    [self removeTarget:target action:action];
}
 
- (void)addTarget:(id)target action:(SEL)action{
    UIControl *_control=[self imageActionControl];
    
    NSString *selStr =NSStringFromSelector(action);
    
    [self setImageActionControlAction:selStr];
    [self setImageActionControlTarget:target];
    
    if(!_control){
        self.userInteractionEnabled =YES;
        _control=[[UIControl alloc] initWithFrame:self.bounds];
        _control.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:_control];
        [_control sendSubviewToBack:self];
        [self setImageActionControl:_control];
        [_control addTarget:self action:@selector(extActionImageDown:) forControlEvents:UIControlEventTouchDown];
        [_control addTarget:self action:@selector(extActionImageUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchCancel|UIControlEventTouchUpOutside|UIControlEventTouchDragOutside];
        [_control addTarget:self action:@selector(extActionImageAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
}

- (void)removeTarget:(id)target action:(SEL)action{
    UIControl *_control=[self imageActionControl];
    [_control removeTarget:self action:@selector(extActionImageDown:) forControlEvents:UIControlEventTouchDown];
    [_control removeTarget:self action:@selector(extActionImageUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchCancel|UIControlEventTouchUpOutside|UIControlEventTouchDragOutside];
    [_control removeTarget:self action:@selector(extActionImageAction:) forControlEvents:UIControlEventTouchUpInside];
    [self setImageActionControl:nil];
    
}

-(void)setImageActionControl:(UIControl *)control{
    objc_setAssociatedObject(self, UIImageView_Click_Control, control, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIControl *)imageActionControl{
    return objc_getAssociatedObject(self, UIImageView_Click_Control);
}

-(void)setImageActionControlTarget:(id)target{
    objc_setAssociatedObject(self, UIImageView_Click_Target, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id)imageActionControlTarget{
    return objc_getAssociatedObject(self, UIImageView_Click_Target);
}

-(void)setImageActionControlAction:(NSString *)action{
    objc_setAssociatedObject(self, UIImageView_Click_SEL, action, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString *)imageActionControlAction{
    return objc_getAssociatedObject(self, UIImageView_Click_SEL);
}



-(void)extActionImageUp:(UIControl *)control{
    control.backgroundColor =[UIColor clearColor];
}
-(void)extActionImageDown:(UIControl *)control{
    control.backgroundColor =[[UIColor blackColor] colorWithAlphaComponent:0.4f];
}
-(void)extActionImageAction:(UIControl *)control{
    
    SEL sel = NSSelectorFromString([self imageActionControlAction]);
    id target = [self imageActionControlTarget];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [target performSelector:sel withObject:self];
#pragma clang diagnostic pop
    
}

-(void)recycleLoadingPatma{
    if([self imageActionControl]){
        [[self imageActionControl] removeFromSuperview];
        [self setImageActionControl:nil];
    }
}

-(void)dealloc{
    [self recycleLoadingPatma];
    
    objc_removeAssociatedObjects(self);
    
}



@end
