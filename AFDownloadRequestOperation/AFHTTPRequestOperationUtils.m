//
//  AFHTTPRequestOperationUtils.m
//  AFNetworking-Base
//
//  Created by yangjunhai on 14-3-27.
//  Copyright (c) 2014年 soooner. All rights reserved.
//

#import "AFHTTPRequestOperationUtils.h"

@interface AFHTTPRequestOperationUtils()
{
    NSObject *transLock;
}
@property (nonatomic,assign) long  fileIndex;
@property (nonatomic,strong) NSString *timeIndex;
@end




@implementation AFHTTPRequestOperationUtils


+ (AFHTTPRequestOperationUtils *)sharedManager
{
    static AFHTTPRequestOperationUtils *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AFHTTPRequestOperationUtils alloc] init];
        // Do any other initialisation stuff here
    });
    
    return sharedInstance;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        transLock =[[NSObject alloc] init];
        self.fileIndex =0;
    }
    return self;
}


-(NSString *)loadSequence{
    NSString *sequence;
    @synchronized(transLock) {
        
        NSString *_timeIndex_ = [NSString stringWithFormat:@"%ld", (long)(CFAbsoluteTimeGetCurrent())];
        
        if(self.timeIndex==nil){
            self.timeIndex = _timeIndex_;
        }
        
        if(![_timeIndex_ isEqualToString:self.timeIndex]){
            self.fileIndex =0;
            self.timeIndex = _timeIndex_;
        }
        
        sequence = [NSString stringWithFormat:@"http_%@_%07ld",self.timeIndex,self.fileIndex];
        
        self.fileIndex+=1;
    } 
    return sequence;
}

#pragma mark - cache path



+ (NSString *)getCachePath{
    
    NSString *documentsDirectory = [[self class] getCacheDir];
    
    NSString *fileName = [[AFHTTPRequestOperationUtils sharedManager] loadSequence];
    
    return [documentsDirectory  stringByAppendingPathComponent:fileName];
}
+ (NSString *)getCacheDir{
    
    NSString *documentsDirectory = NSTemporaryDirectory();
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [fileManager createDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:@"httpCache"] withIntermediateDirectories:YES attributes:nil error:nil];
    
    return [documentsDirectory stringByAppendingPathComponent:@"httpCache"];
}


+ (void)clearCachePath:(NSString *)path{
    if(!path)
        return;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL _isDir;
    if([fileManager fileExistsAtPath:path isDirectory:&_isDir]){
        if(!_isDir) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            return;
        }
    }
    NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:NULL];
    
    for (int i=0; i<[files count]; i++) {
        NSString *filePath = [path stringByAppendingPathComponent:[files objectAtIndex:i]];
        BOOL isDir;
        if([fileManager fileExistsAtPath:filePath isDirectory:&isDir]){
            if(isDir)
                [AFHTTPRequestOperationUtils clearCachePath:filePath];
            else
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

@end
