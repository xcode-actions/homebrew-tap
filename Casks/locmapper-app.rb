cask 'locmapper-app' do
  version '1.5.0'
  sha256 '38ac4255b97a53d30c29c70921405e6be88fe272839dceadac5bcbd604b1bc7f'

  url "https://github.com/xcode-actions/LocMapper/releases/download/LocMapper%2Frelease%2F#{version}/LocMapperApp.zip"
  name 'LocMapper'
  homepage 'https://github.com/xcode-actions/LocMapper'

  app 'LocMapper.app'

  zap trash: [
               '~/Library/Containers/com.xcode-actions.LocMapperApp/',
             ]
end
