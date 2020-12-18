
Pod::Spec.new do |s|

  s.name         = "RMNetworkKit"
  s.version      = "1.0"
  s.summary      = "RMNetworkKit."
  s.description  = <<-DESC
                    this is RMNetworkKit
                   DESC
  s.homepage     = "https://gitlab.com/RMNetworkKit"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "RMNetworkKit" => "RMNetworkKit@msn.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://gitlab.com/RMNetworkKit.git", :tag => s.version.to_s }
  s.source_files  = "RMNetworkKit/RMNetworkKit/**/*.{h,m,swift}"
  s.requires_arc = true
    s.dependency "Alamofire"
    s.dependency "PINCache"
    s.dependency "SwiftyJSON"
    s.dependency "Kingfisher"


end
