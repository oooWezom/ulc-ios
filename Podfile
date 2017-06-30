# Uncomment this line to define a global platform for your project
platform :ios, '9.0'

target 'ULC' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

pod 'R.swift', '~> 2.3'
pod 'Moya', '~> 6.5'
pod 'Moya/ReactiveCocoa'
#pod 'Swinject', '~> 1.1'
pod 'SnapKit', '~> 0.20'
pod 'MBProgressHUD', '~> 0.9'
pod 'ReachabilitySwift', '~> 2.3'
pod 'RealmSwift', '2.3.0'
pod 'ReactiveCocoa', '~> 4.2'
pod 'Box', '~> 2.0'
pod 'SwiftKeychainWrapper', '~> 1.0'
pod 'ObjectMapper', '~> 1.3'
pod 'Kingfisher', '~> 2.4'
pod 'RSKImageCropper'
pod 'SwiftDate', '~> 3.0'
pod 'JSQMessagesViewController'
pod 'DateTools'
pod 'Starscream', '1.1.3'
pod 'REFrostedViewController', '~> 2.4'
pod "TTRangeSlider"
pod 'VideoCore/Swift', :git => 'https://github.com/NeoApostol/VideoCore.git'
pod 'glm', :git => 'https://github.com/NeoApostol/glm.git'
pod 'Fabric'
pod 'Crashlytics'
pod 'KSYMediaPlayer_iOS', :git => 'https://github.com/ksvc/KSYMediaPlayer_iOS.git', :tag => 'v2.3.0'

#pod 'glm', :git => 'https://github.com/maxcampolo/glm.git'
#pod 'PLPlayerKit', '2.2.4'
#pod 'AsyncSwift', '~> 1.7'
#pod 'Realm-EasyBackground', '~> 0.5.0'
#pod 'FFmpeg', '~> 2.8.3'
#pod 'Interstellar', '~> 1.4.0'
#pod 'Rex', '~> 0.10.0'
#pod 'SwiftFetchedResultsController'
#pod 'Marshroute', :git => 'https://github.com/avito-tech/Marshroute.git', :tag => '0.3.0'

  # Pods for ULC
  target 'ULCTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ULCUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end

post_install do |installer|
  Dir.glob(installer.sandbox.target_support_files_root + "Pods-*/*.sh").each do |script|
    flag_name = File.basename(script, ".sh") + "-Installation-Flag"
    folder = "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
    file = File.join(folder, flag_name)
    content = File.read(script)
    content.gsub!(/set -e/, "set -e\nKG_FILE=\"#{file}\"\nif [ -f \"$KG_FILE\" ]; then exit 0; fi\nmkdir -p \"#{folder}\"\ntouch \"$KG_FILE\"")
    File.write(script, content)
  end
end
