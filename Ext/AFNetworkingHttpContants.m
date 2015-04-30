//
//  AFNetworkingHttpContants.m
//
//

#import "AFNetworkingHttpContants.h"


@implementation AFNetworkingHttpContants : NSObject



static NSString *authorizationUserName = nil;
static NSString *authorizationPasswd = nil;
+ (void)setAuthorizationHeaderFieldWithUsername:(NSString *)username
                                       password:(NSString *)password{
    authorizationUserName = username;
    authorizationPasswd = password;

}


+ (void)clearAuthorizationHeader{
    authorizationUserName = nil;
    authorizationPasswd = nil;
}
+ (NSString *)authorizationHeaderFieldWithUsername{
    return authorizationUserName;
}
+ (NSString *)authorizationHeaderFieldWithPassword{
    return authorizationPasswd;
}

+ (BOOL)containsAuthorizationHeaderField{
    return authorizationUserName.length>0&&authorizationPasswd.length>0;
}

@end
