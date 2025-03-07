Pod::Spec.new do |s|
  s.name         = "LifetimeTracker"
  s.version      = "1.8.3"
  s.summary      = "Framework to visually warn you when retain cycle / leak happens."
  s.description  = <<-DESC
    Mini framework that can surface retain cycle issues sooner.
  DESC
  s.homepage     = "https://github.com/krzysztofzablocki/LifetimeTracker"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Krzysztof Zablocki" => "krzysztof.zablocki@pixle.pl" }
  s.social_media_url   = "http://twitter.com/merowing_"

  s.ios.deployment_target = "12.0"
  s.source       = { :git => "https://github.com/krzysztofzablocki/LifetimeTracker.git", :tag => s.version.to_s }
  s.ios.source_files  = "Sources/LifetimeTracker/*.swift", "Sources/LifetimeTracker/iOS/**/*.swift"
  s.ios.resources     = "Sources/LifetimeTracker/Resources/**/*.{xib,storyboard}"
  s.ios.resource_bundle = { "LifetimeTracker" => ["Sources/LifetimeTracker/*.{strings}"] }
  s.ios.frameworks  = ["Foundation", "UIKit"]
  s.swift_version = "5.0"

  s.ios.dependency 'LifetimeTrackerCore'
end
