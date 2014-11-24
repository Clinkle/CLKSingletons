Pod::Spec.new do |s|
  s.name             = "CLKSingletons"
  s.version          = "0.1.0"
  s.summary          = "CLKSingletons provides an elegant macro for declaring singletons in your iOS app."
  s.homepage         = "https://github.com/Clinkle/CLKSingletons"
  s.license          = 'MIT'
  s.author           = { "tsheaff" => "tyler@clinkle.com" }
  s.source           = { :git => "https://github.com/Clinkle/CLKSingletons.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes'
end
