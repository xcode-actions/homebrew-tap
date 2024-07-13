cask 'locmapper-app' do
  version '1.4.0'
  sha256 'bc54f80097854326405361ec2f90af8e094f9147eddd2a0731f00f8828a52ee5'

  url "https://github.com/xcode-actions/LocMapper/releases/download/LocMapper%2Frelease%2F#{version}/LocMapperApp.zip"
  name 'LocMapper'
  homepage 'https://github.com/xcode-actions/LocMapper'

  app 'LocMapper.app'

  zap trash: [
               '~/Library/Containers/com.xcode-actions.LocMapperApp/',
             ]
end
