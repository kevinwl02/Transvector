Pod::Spec.new do |s|
  s.name         = "Transvector"
  s.version      = "0.0.1"
  s.summary      = ""
  s.homepage     = "https://github.com/kevinwl02/Transvector"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors      = {'Kevin Wong' => 'kevin.wl.02@gmail.com'}
  s.ios.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/kevinwl02/Transvector.git", :tag => "#{s.version}" }
  s.source_files  = "Transvector/Source/*.{swift,h,m}", "Transvector/Transvector/*.{swift,h,m}", "Transvector/libxml2/*.{swift,h,m}"

  s.requires_arc = true

  s.module_map = 'Transvector/module/module.map'
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
end