

创建

	#import "AFNetworkingBaseRequest.h"
	@interface TestRequest : AFNetworkingBaseRequest

	@end
	
	
	@implementation TestRequest
	
	- (instancetype)init
	{
    	self = [super init];
    	if (self) {
        	self.responseType =ResponseProtocolTypeFile; //文件下载
        	self.responseType =ResponseProtocolTypeJSON; //返回JSON
        	self.responseType =ResponseProtocolTypeNormal; //返回普通文本
        
    	}
   	 	return self;
	}

	-(void)prepareRequest{
    
    	NSString *url = [PROTOCOL_URL stringByAppendingString:POST_FILE_URL];
    	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    	[dictionary setObject:@"121212123123" forKey:@"account"];
    	[dictionary setObject:@"111111" forKey:@"passwd"];
    	[self buildGetRequest:url form:dictionary];
    
	}
   
    //对应 self.responseType =ResponseProtocolTypeNormal;
	-(void)processString:(NSString *)str{
    	NSLog(@"processString:%@", str);
    
	}

	//对应 self.responseType =ResponseProtocolTypeJSON;
	-(void)processDictionary:(id)dictionary{
   	 	NSLog(@"processDictionary:%@", dictionary);
	}

	//对应 self.responseType =ResponseProtocolTypeFile;
	-(void)processFile:(NSString *)filePath{
    
    	NSLog(@"processFile:%@", filePath);
	}

	@end
	
	
使用 


	TestRequest  *request = [[TestRequest alloc] init]; 
	[request uploadBlock:^(NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {

	}];

	[request downloadBlock:^(NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {

	}];

	[request completionBlock:^(AFNetworkingBaseRequest *request, NSInteger statusCode) {
    NSLog(@"-----------completionBlock");
	}];

	[request executeAsync:queueId];
	
监控日志

	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
		[[AFNetworkActivityLogger sharedLogger] startLogging];
		[[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
		
		//网络状态
   		[AFNetworkActivityIndicatorManager sharedManager];
		
		...
	}
	
