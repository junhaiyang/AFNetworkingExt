//
//  AFHTTPRequestOperationUtils.h 
//

#import <Foundation/Foundation.h>

@interface AFHTTPRequestOperationUtils : NSObject

+ (NSString *)getCachePath;

+ (NSString *)getCacheDir;

+ (void)clearCachePath:(NSString *)path;

@end
