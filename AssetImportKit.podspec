Pod::Spec.new do |s|
  s.name = 'AssetImportKit'
  s.version = '1.1.1'
  s.summary = 'Swifty cross platform library (macOS, iOS) that converts Assimp supported models to SceneKit scenes.'
  s.description = 'AssetImportKit allows you to import Assimp supported file formats directly in SceneKit at runtime. The library supports: geometry, materials (with color, embedded textures and external textures), cameras, skeletal animations, serialization to .scn format.'
  s.homepage = 'https://github.com/eugenebokhan/asset-import-kit'
  s.source = { :git => 'https://github.com/eugenebokhan/asset-import-kit.git', :tag => s.version.to_s }
  s.author = { 'Eugene Bokhan' => 'eugenebokhan@protonmail.com' }
  s.social_media_url = 'http://twitter.com/eugenebokhan'
  s.license = { :file => 'LICENSE' }

  s.ios.deployment_target = '10.3'
  s.osx.deployment_target = '10.12'

  s.source_files = 'Sources/**/*.{swift}'

  s.dependency 'Assimp', '~> 5.0.1'
  
  s.swift_version = '5.0'
end
