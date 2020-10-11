#
# Be sure to run `pod lib lint GoogleSignInSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GoogleSignInSwift'
  s.version          = '0.3.2'
  s.summary          = 'Google Sign In allows users to sign in with their Google account.'
  s.swift_versions   = '5.0'
  s.framework        = 'AuthenticationServices'

  s.description      = <<-DESC
  GoogleSignInSwift allows users to sign in with their Google account. A more up-to-date Google Sign In written completely in Swift!
                       DESC

  s.homepage         = 'https://github.com/J0shK/GoogleSignInSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Josh Kowarsky' => 'josh.kowarsky@gmail.com' }
  s.source           = { :git => 'https://github.com/J0shK/GoogleSignInSwift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.source_files = 'GoogleSignInSwift/Classes/**/*'
end
