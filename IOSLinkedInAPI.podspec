Pod::Spec.new do |s|
  s.name     = 'IOSLinkedInAPI'
  s.version  = '1.0.2'
  s.license  = 'MIT'
  s.summary  = 'IOS LinkedIn API capable of accessing LinkedIn using oauth2. Using a UIWebView to fetch the authorization code.'
  s.homepage = 'https://github.com/jeyben/IOSLinkedInAPI'
  s.authors  = { 'Jacob von Eyben' => 'jacobvoneyben@gmail.com', 'Eduardo Fonseca' => 'hello@eduardo-fonseca.com' }
  s.source   = { :git => 'https://github.com/ebfaed/IOSLinkedInAPI.git', :tag => '1.0.0' }
  s.source_files = 'IOSLinkedInAPI'
  s.requires_arc = true

  s.platform     = :ios, '6.0'

  s.dependency 'AFNetworking', '>= 2.0.0'

end
