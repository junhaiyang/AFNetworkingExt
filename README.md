初始目的：

	不要过多的关心网络协议底层
	简化图片批量下载、下载取消操作，允许UIImageView复用下载不同网络图片
	不需要再为同一页面出现相同图片地址下载做任何处理，优化图片渲染效率
	强化图片缓存方案
	  
Podfile
如果无法编译，指定下面依赖版本
	
	pod 'AFNetworking', '~> 2.3.1'
	pod 'AFNetworkActivityLogger', '~> 2.0.3'
	pod 'AFOnoResponseSerializer', '~> 1.0.0'
	pod 'AFgzipRequestSerializer', '~> 0.0.1'
	pod 'Ono', '~> 1.1.1'
	pod 'Godzippa', '~> 1.0.0'

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
        	
        	self.requestType =RequestProtocolTypeNormal; //默认请求
        	self.requestType =RequestProtocolTypeJSON; //JSON body 请求 
        
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

	[request finishedBlock:^(AFNetworkingBaseRequest *request, StatusCode errorCode, NSInteger httpStatusCode) {
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
	
	
	
	
UIImageView+DYLoading:缓存图片到本地文件系统，并且出现相同下载地址时会自动忽略并在原来请求成功后绘制所有相同图片地址的view

使用network
	
	
    self.imageView.defaultLoadingImage = [UIImage imageNamed:@"icon"]; 
    imageView.loadingImagePathType = @"icon"; 
    imageView.loadingImagePathKey = [NSString stringWithFormat:@"%lld", user.uid]; 
    imageView.loadingQueueId = queueId;
    
    [imageView loadingAsyncImage:imagePath];
    //[imageView loadingSyncImage:imagePath];
    
    
 local
 
 	
    self.imageView.defaultLoadingImage = [UIImage imageNamed:@"icon"]; 
    imageView.loadingResourcePath = recourcePath;
    [imageView loadingSyncLocalImage];
    //[imageView loadingAsyncLocalImage];
    
    
    
 cacle loading
 
 	[self.imageView recycleLoading];

local chache path:    .....APP CACHE DIR/$loadingImagePathType/$loadingImagePathKey/$urlencoding.png
	
	+(NSString *)parseImagePath:(NSString *)imagePathType imageKey:(NSString *)imageKey url:(NSURL *)url;
    
 clear local cache path
   
  	+(void)clearImageCache:(NSString *)imagePathType imageKey:(NSString *)imageKey;
  	
  	
  	
    
  
