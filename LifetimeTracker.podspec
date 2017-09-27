Pod::Spec.new do |s|
  s.name         = "LifetimeTracker"
  s.version      = "1.0.1"
  s.summary      = "Framework to visually warn you when retain cycle / leak happens."
  s.description  = <<-DESC
    Mini framework that can surface retain cycle issues sooner.
  DESC
  s.homepage     = "https://github.com/krzysztofzablocki/LifetimeTracker"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Krzysztof Zablocki" => "krzysztof.zablocki@pixle.pl" }
  s.social_media_url   = "http://twitter.com/merowing_"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/krzysztofzablocki/LifetimeTracker.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*.swift"
  s.resources     = "Sources/**/*.xib"
  s.frameworks  = ["Foundation", "UIKit"]
end
