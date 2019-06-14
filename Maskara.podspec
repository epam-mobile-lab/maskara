##
#

Pod::Spec.new do |s|

  s.name         = "Maskara"
  s.version      = "1.0.0"
  s.summary      = "Framework for guiding and validating user input using masked editor"
  s.description  = "Framework for guiding and validating user input using masked editor, written in Swift"
  s.homepage     = "https://github.com/epam-mobile-lab/maskara"
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = #{ "[author]" => "[email]" }
  s.platform     = :ios, :osx
  s.swift_version = "4.2"

  s.ios.deployment_target = "10.1"
   
  s.source       = { :git => "https://github.com/epam-mobile-lab/maskara.git", :tag => "1.0.0" }
  s.source_files  = "Maskara", "Maskara/**/*.{h,swift}"

end
