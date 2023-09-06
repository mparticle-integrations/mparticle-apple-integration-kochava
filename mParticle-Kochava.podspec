Pod::Spec.new do |s|
    s.name             = "mParticle-Kochava"
    s.version          = "8.3.1"
    s.summary          = "Kochava integration for mParticle"

    s.description      = <<-DESC
                       This is the Kochava integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-kochava.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticle"

    s.ios.deployment_target = "12.4"
    s.ios.source_files      = 'mParticle-Kochava/*.{h,m,mm}'
    s.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 8.9'
    s.ios.dependency 'Apple-Cocoapod-KochavaTracker', '~> 7.0'
end
