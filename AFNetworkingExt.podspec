 
Pod::Spec.new do |s|
 

  s.name         = "AFNetworkingExt"
  s.version      = "1.0.0"
  s.summary      = "AFNetworking的封装"
 

  s.homepage     = "https://github.com/junhaiyang/AFNetworkingExt"
 
  s.license      = "MIT"
 
  s.author             = { "yangjunhai" => "junhaiyang@gmail.com" } 
  s.ios.deployment_target = "6.0" 

 
  s.source = { :git => 'https://github.com/junhaiyang/AFNetworkingExt.git' } 
 
  s.requires_arc = true
   
  s.source_files = 'Ext/*.{h,m,mm}' 
      
  s.subspec 'AFCustomRequestOperation' do |ds|
    
    ds.source_files = 'AFCustomRequestOperation/*.{h,m,mm}' 
    		 
  end
  
  s.subspec 'AFDownloadRequestOperation' do |ds|
    
    ds.source_files = 'AFDownloadRequestOperation/*.{h,m,mm}' 
    		 
  end
  
  
  s.subspec 'AFTextResponseSerializer' do |ds|
    
    ds.source_files = 'AFTextResponseSerializer/*.{h,m,mm}' 
    		 
  end
  
  
  s.subspec 'example' do |ds|
    
    ds.source_files = '*.{h,m,mm}' 
    		 
  end
  
  s.dependency 'AFNetworking'
  s.dependency 'AFNetworkActivityLogger'
  s.dependency 'AFgzipRequestSerializer'
  s.dependency 'AFOnoResponseSerializer'
  s.dependency 'Godzippa'
   
 
end
