Pod::Spec.new do |s|

    s.name                  = 'SwiftyMessenger'
    s.version               = '0.1'
    s.summary               = 'Swift toolkit for passing messages between iOS apps and extensions.'
    s.homepage              = 'hhttps://github.com/abdullahselek/SwiftyMessenger'
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
    s.ios.deployment_target = '9.0'
    s.source_files          = 'SwiftyMessenger/*.swift'
    s.requires_arc          = true

end
