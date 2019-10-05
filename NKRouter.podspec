Pod::Spec.new do |s|
  s.name	= "NKRouter"
  s.version 	= "1.0.2"
  s.license	= 'MIT'
  s.summary 	= "NKRouter is a powerful URL routing library with simple block-based  and senior operability session API."
  s.homepage	= "https://github.com/NearKXH/NKRouter"
  s.author   	= { "Nate Kong" => "near.kongxh@gmail.com" }
  s.source   	= { :git => "https://github.com/NearKXH/NKRouter.git", :tag => s.version }
  s.platform   	= :ios, "8.0"  
  s.requires_arc 	= true
  s.source_files 	= 'NKRouter/Classes/NKRouter.{h,m}'

  s.subspec 'RouterRequest' do |ss|
    ss.source_files = 'NKRouter/Classes/RouterSession/{NKRouterRequest,NKRouterResponse}.{h,m}'
  end

  s.subspec 'CategoryPrivate' do |ss|
    ss.source_files = 'NKRouter/Classes/RouterSession/Category/**/*.{h,m}'
    ss.dependency 'NKRouter/RouterRequest'
  end

  s.subspec 'Sessiones' do |ss|
    ss.source_files = 'NKRouter/Classes/RouterSession/NKRouterSession.{h,m}', 'NKRouter/Classes/RouterSession/Sessiones/**/*.{h,m}'
    ss.dependency 'NKRouter/RouterRequest'
    ss.dependency 'NKRouter/CategoryPrivate'
  end

end
