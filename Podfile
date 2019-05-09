# Disable sending stats
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

source 'https://github.com/CocoaPods/Specs.git'
source 'ssh://git@git.triple-it.nl/ios/cocoapods.git'

inhibit_all_warnings!

platform :ios, '10.0'

def shared_pods
    # Image fetching
    pod 'Nuke'

    # Helpers
    pod 'KeychainAccess'

    # Extensions
    pod 'TIFUIElements', :subspecs => ['RxSwift']
    pod 'TIFExtensions'
    pod 'TIFNetwork', :subspecs => ['RxSwift']
    pod 'Alamofire'
    pod 'Moya'
    
    # Code optimalisation
    pod 'SwiftLint', :configurations => ['Debug']

    # Layout swift
    pod 'EasyPeasy'
end

target 'Madpac' do
  	# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
	use_frameworks!

	# Pods for film1
	shared_pods
end
