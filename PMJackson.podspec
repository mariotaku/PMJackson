Pod::Spec.new do |s|
  s.name         = "PMJackson"
  s.version      = "1.0.6"
  s.summary      = "Extension for PMJSON to acheieve Jackson-style parsing"
  s.description  = "PMJackson provides a JsonParser like Jackson's com.fasterxml.jackson.core.JsonParser"

  s.homepage     = "https://github.com/mariotaku/PMJackson"

  s.license      = "MIT & Apache License, Version 2.0"

  s.author             = { "Mariotaku Lee" => "mariotaku.lee@gmail.com" }
  s.social_media_url   = "https://twitter.com/mariotaku"

  s.source       = { :git => "https://github.com/mariotaku/PMJackson.git", :tag => "#{s.version}" }

  s.source_files  = "Sources/*.{swift,h,m}",

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'

  s.dependency 'PMJSON', '~> 2.0'
end
