def product_pods
	pod 'SwiftyMessenger', :path => '.'
end

workspace 'SwiftyMessenger.xcworkspace'
project 'SwiftyMessenger.xcodeproj'

target 'Sample iOS App' do
	platform :ios, '10.0'
	project 'Sample iOS App/Sample iOS App.xcodeproj'
	use_frameworks!
    inherit! :search_paths
    product_pods
end

target 'Sample WatchOS App Extension' do
	platform :watchos, '3.0'
	project 'Sample iOS App/Sample iOS App.xcodeproj'
	use_frameworks!
    inherit! :search_paths
    product_pods
end

target 'Sample Today Extension' do
	platform :ios, '10.0'
	project 'Sample iOS App/Sample iOS App.xcodeproj'
	use_frameworks!
    inherit! :search_paths
    product_pods
end
