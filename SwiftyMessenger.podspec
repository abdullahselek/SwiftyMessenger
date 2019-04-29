Pod::Spec.new do |s|

    s.name                  = 'SwiftyMessenger'
    s.version               = '0.3'
    s.summary               = 'Swift toolkit for passing messages between iOS apps and extensions.'
    s.homepage              = 'https://github.com/abdullahselek/SwiftyMessenger'
    s.license               = {
        :type => 'MIT',
        :file => 'LICENSE'
    }
    s.author                = {
        'Abdullah Selek' => 'abdullahselek@gmail.com'
    }
    s.source                = {
        :git => 'https://github.com/abdullahselek/SwiftyMessenger.git',
        :tag => s.version.to_s
    }
    s.ios.deployment_target = '10.0'
    s.watchos.deployment_target = '3.0'
    s.source_files          = 'Source/*.swift'
    s.requires_arc          = true
    s.swift_version         = '5.0'

end
