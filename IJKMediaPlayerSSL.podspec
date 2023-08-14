Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "IJKMediaPlayerSSL"
  s.version      = "0.0.1"
  s.summary      = "IJKMediaPlayer with SSL"
  s.description  = "IJKMediaPlayer with SSL"
  s.homepage     = "https://github.com/thula-belive/IJKMediaPlayer"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = { :type => "MIT", :file => "LICENSE" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = "Thu Le (Tommy)"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform     = :ios, "11.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/thula-belive/IJKMediaPlayer.git", :tag => "0.0.1" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "Classes", "Classes/**/*.{h,m,swift}"
  s.requires_arc = true
  s.frameworks  = "AudioToolbox", "AVFoundation", "CoreGraphics", "CoreMedia", "CoreVideo", "MobileCoreServices", "OpenGLES", "QuartzCore", "VideoToolbox", "Foundation", "UIKit", "MediaPlayer"
  s.libraries   = "bz2", "z", "stdc++"
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC -all_load' }
  s.vendored_framework = "IJKMediaFrameworkWithSSL/IJKMediaFrameworkWithSSL.xcframework"
end
