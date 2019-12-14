tap 'homebrew/cask'
tap 'prisma/prisma'

brew 'awscli'
brew 'flow'
brew 'git'
brew 'jq'
brew 'libomp'
# Override default Vim installation.
# By default, OSX has an older version of Vim installed.
brew 'macvim', args: [ '--override-system-vim' ]
brew 'postgresql'
brew 'prisma'
brew 'python@2'
brew 'python3'
brew 'tmux'
brew 'watchman'
# Install yarn using nvm's version of Node.js.
brew 'yarn', args: [ '--ignore-dependencies' ]

cask_args appdir: '/Applications'

cask 'adobe-acrobat-reader'
cask 'anaconda'
cask 'android-platform-tools'
cask 'android-sdk'
cask 'android-studio'
cask 'atom'
cask 'codekit'
cask 'docker'
cask 'dropbox'
cask 'firefox'
cask 'framer'
cask 'gimp'
cask 'google-chrome'
cask 'google-backup-and-sync'
cask 'graphql-playground'
cask 'hyper'
cask 'inkscape'
cask 'iterm2'
cask 'java'
cask 'mysqlworkbench'
cask 'pgadmin4'
cask 'postman'
cask 'sketch'
cask 'sketch-toolbox'
cask 'slack'
cask 'sublime-text'
cask 'typora'
cask 'vagrant'
# Omitting due to known High Sierra installation issue. See https://github.com/Homebrew/homebrew-cask/issues/39369.
# cask 'virtualbox'
cask 'visual-studio-code'
# Required for Inkscape installation.
cask 'xquartz'

# Requires 'virtualbox' Cask dependency to be installed prior.
# cask 'docker-toolbox'
