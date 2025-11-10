cask 'locmapper-app' do
  version '1.6.1'
  sha256 'e37cfc691524c69844783c18819c23731b11503b8d7bc892eda457ee7d47cd8a'

  url "https://github.com/xcode-actions/LocMapper/releases/download/LocMapper%2Frelease%2F#{version}/LocMapperApp.zip"
  name 'LocMapper'
  homepage 'https://github.com/xcode-actions/LocMapper'

  app 'LocMapper.app'

  zap trash: [
               '~/Library/Containers/com.xcode-actions.LocMapperApp/',
             ]
end
