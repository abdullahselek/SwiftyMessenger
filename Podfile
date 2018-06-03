platform :ios, '9.0'

def product_pods
	pod 'SwiftyMessenger', :path => '.'
end

workspace 'SwiftyMessenger.xcworkspace'
project 'SwiftyMessenger.xcodeproj'

target 'Sample iOS App' do
	project 'Sample iOS App/Sample iOS App.xcodeproj'
	use_frameworks!
    inherit! :search_paths
    product_pods
end
