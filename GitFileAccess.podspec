Pod::Spec.new do |s|
  s.name             = 'GitFileAccess'
  s.version          = '0.1.0'
  s.summary          = 'Use github as a fileserver'
  s.swift_version    = '5.0'

  s.description      = <<-DESC
  Use github as a fileserver.
                       DESC

  s.homepage         = 'https://github.com/anconaesselmann/GitFileAccess'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'anconaesselmann' => 'axel@anconaesselmann.com' }
  s.source           = { :git => 'https://github.com/anconaesselmann/GitFileAccess.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'

  s.source_files = 'GitFileAccess/Classes/**/*'

  s.dependency 'RxSwift'
  s.dependency 'LoadableResult'
  s.dependency 'RxLoadableResult'
end
