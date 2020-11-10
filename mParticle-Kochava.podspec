Pod::Spec.new do |s|
    s.name             = "mParticle-Kochava"
    s.version          = "8.0.1"
    s.summary          = "Kochava integration for mParticle"

    s.description      = <<-DESC
                       This is the Kochava integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-kochava.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticle"
    s.static_framework = true

    s.ios.deployment_target = "10.3"
    s.ios.source_files      = 'mParticle-Kochava/*.{h,m,mm}'
    s.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 8.0'
    s.ios.dependency 'KochavaTrackeriOS', '~> 4.0'
    s.ios.pod_target_xcconfig = {
        'LIBRARY_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/KochavaTrackeriOS/**',
        'OTHER_LDFLAGS' => '$(inherited) -l"KochavaTrackeriOS"'
    }
end
