# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

use_frameworks!
inhibit_all_warnings!

target 'SwifthubTPS' do
    pod 'ObjectMapper' # https://github.com/ninjaprox/NVActivityIndicatorView
    pod 'UIColor_Hex_Swift' # https://github.com/yeahdongcn/UIColor-Hex-Swift
    pod 'MessageKit' # https://github.com/MessageKit/MessageKit
    pod 'InputBarAccessoryView' # https://github.com/nathantannar4/InputBarAccessoryView
    pod 'Toast-Swift' # https://github.com/scalessec/Toast-Swift
    pod 'SwiftDate' # https://github.com/malcommac/SwiftDate
    pod 'Kingfisher' # https://github.com/onevcat/Kingfisher
end


post_install do |installer|
    # Cocoapods optimization, always clean project after pod updating
    Dir.glob(installer.sandbox.target_support_files_root + "Pods-*/*.sh").each do |script|
        flag_name = File.basename(script, ".sh") + "-Installation-Flag"
        folder = "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
        file = File.join(folder, flag_name)
        content = File.read(script)
        content.gsub!(/set -e/, "set -e\nKG_FILE=\"#{file}\"\nif [ -f \"$KG_FILE\" ]; then exit 0; fi\nmkdir -p \"#{folder}\"\ntouch \"$KG_FILE\"")
        File.write(script, content)
    end
    
    # Enable tracing resources
    installer.pods_project.targets.each do |target|
      if target.name == 'RxSwift'
        target.build_configurations.each do |config|
          if config.name == 'Debug'
            config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
          end
        end
      end
    end
end
