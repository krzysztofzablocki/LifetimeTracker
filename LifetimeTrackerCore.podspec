Pod::Spec.new do |s|
  s.name         = "LifetimeTrackerCore"
  s.version      = "1.8.3"
  s.summary      = "Framework that warns you when retain cycle / leak happens."
  s.description  = <<-DESC
    Mini framework that can surface retain cycle issues sooner.
  DESC
  s.homepage     = "https://github.com/krzysztofzablocki/LifetimeTracker"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Krzysztof Zablocki" => "krzysztof.zablocki@pixle.pl" }
  s.social_media_url   = "http://twitter.com/merowing_"
  s.ios.deployment_target = "12.0"
  s.osx.deployment_target = '10.13'
  s.source       = { :git => "https://github.com/krzysztofzablocki/LifetimeTracker.git", :tag => s.version.to_s }
  s.source_files  = "Sources/LifetimeTrackerCore/*.swift"
  s.frameworks  = ["Foundation"]
  s.swift_version = "5.0"
end
