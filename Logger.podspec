Pod::Spec.new do |s|
  s.name             = 'Logger'
  s.version          = '1.0.7'
  s.summary          = 'Configurable logging for Swift.'

  s.description      = <<-DESC
  Configurable logging for Swift.

  Declare multiple log channels. Log messages and objects to them. Enable individual channels with minimal overhead for the disabled ones.
                         DESC

  s.homepage         = 'https://github.com/elegantchaos/Logger'
  s.license          = { :type => 'custom', :file => 'LICENSE.md' }
  s.author           = { 'Sam Deane' => 'sam@elegantchaos.com' }
  s.source           = { :git => 'https://github.com/elegantchaos/Logger.git', :tag => s.version.to_s }

  s.platform = :osx
  s.swift_version = "4.1"
  s.osx.deployment_target = "10.12"

  s.source_files = 'Sources/Logger/**/*'
end
