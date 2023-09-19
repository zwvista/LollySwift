workspace 'LollySwift'

source 'https://cdn.cocoapods.org/'
use_frameworks!

target 'LollySwiftiOS' do
platform :ios, '16.0'
project 'LollySwiftiOS/LollySwiftiOS'
pod 'AKSideMenu'
pod 'Then'
end

target 'LollySwiftiOSTests' do
platform :ios, '16.0'
project 'LollySwiftiOS/LollySwiftiOS'
pod 'Then'
end

target 'LollySwiftMac' do
platform :osx, '13.0'
project 'LollySwiftMac/LollySwiftMac'
pod 'Then'
end

target 'LollySwiftMacTests' do
platform :osx, '13.0'
project 'LollySwiftMac/LollySwiftMac'
pod 'Then'
end

target 'LollySwiftUIiOS' do
platform :ios, '16.0'
project 'LollySwiftUIiOS/LollySwiftUIiOS'
pod 'Then'
end

target 'LollySwiftUIiOSTests' do
platform :ios, '16.0'
project 'LollySwiftUIiOS/LollySwiftUIiOS'
pod 'Then'
end

target 'LollySwiftUIMac' do
platform :osx, '13.0'
project 'LollySwiftUIMac/LollySwiftUIMac'
pod 'Then'
end

target 'LollySwiftUIMacTests' do
platform :osx, '13.0'
project 'LollySwiftUIMac/LollySwiftUIMac'
pod 'Then'
end

post_install do |installer|
  xcode_version = `xcodebuild -version | grep 'Xcode' | awk '{print $2}'`

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if xcode_version.strip == '15.0'
        xcconfig_path = config.base_configuration_reference.real_path
        xcconfig = File.read(xcconfig_path)
        xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
        File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
      end
    end
  end
end
