Pod::Spec.new do |s|
  s.name     = 'IOSLinkedInAPI'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'A delightful iOS and OS X networking framework.'
  s.homepage = 'https://github.com/jeyben/IOSLinkedInAPI'
  s.authors  = { 'Jacob von Eyben' => 'jacobvoneyben@gmail.com' }
  s.source   = { :git => 'https://github.com/jeyben/IOSLinkedInAPI.git', :tag => '0.0.1' }
  s.source_files = 'IOSLinkedInAPI'
  s.requires_arc = true

  s.ios.deployment_target = '5.0'

end
