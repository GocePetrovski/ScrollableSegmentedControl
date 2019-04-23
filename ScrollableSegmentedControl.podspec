Pod::Spec.new do |s|
  s.name = 'ScrollableSegmentedControl'
  s.version = '1.5.0'
  s.license = 'MIT'
  s.summary = 'Scrollable Segmented Control for when UISegmentedControl is not sufficient'
  s.homepage = 'https://github.com/GocePetrovski/ScrollableSegmentedControl'
  s.social_media_url = 'http://twitter.com/GocePetrovski'
  s.authors = { 'Goce Petrovski' => 'goce.petrovski@gmail.com' }
  s.source = { :git => 'https://github.com/GocePetrovski/ScrollableSegmentedControl.git', :tag => s.version }

  s.platform = :ios, '9.0'
  s.swift_version = '5.0'

  s.source_files = 'ScrollableSegmentedControl/*.swift'
end
