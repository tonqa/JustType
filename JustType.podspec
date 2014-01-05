#
# Be sure to run `pod spec lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://docs.cocoapods.org/specification.html
#
Pod::Spec.new do |s|
  s.name         = "JustType"
  s.version      = "0.1.0"
  s.summary      = "The iOS keyboard for everyone"
  s.description  = <<-DESC
                    An improved keyboard for iOS supporting gestures, highlighting and suggestions.
                   DESC
  s.homepage     = "http://www.eglador.de"
  s.screenshots  = "http://dl.dropboxusercontent.com/u/82016/justtype_1.png", "http://dl.dropboxusercontent.com/u/82016/justtype_2.png"
  s.license      = 'Creative Commons'
  s.author       = { "Alexander Koglin" => "tonqa@gmx.de" }
  s.source       = { :git => "http://bitbucket.org/tonqa/justtype.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '6.0'
  s.requires_arc = true

  s.source_files = 'JustType'
  # s.ios.exclude_files = 'JustType/private'

  # s.public_header_files = 'JustType/**/*.h'
  # s.frameworks = 'QuartzCore', 'AnotherFramework'
  # s.dependency 'lib', '~> 1.4'
end
