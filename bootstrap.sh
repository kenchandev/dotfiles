#!/bin/sh

set -e

EXCLUDED_SYMLINK_DIRS=(\
  fonts \
  .nvm \
  .homebrew \
  .git \
)

EXCLUDED_SYMLINK_FILES=(\
  .DS_Store \
  .editorconfig \
  .gitignore \
  Brewfile \
  dotfiles.svg \
  LICENSE.md \
  README.md \
  bootstrap.sh \
  install.sh \
)

function printInfo () {
  printf "\r  [ \033[00;34m...\033[0m ] $1\n"
}

function printSuccess () {
  printf "\r\033[2K  [ \033[00;32mSUCCESS\033[0m ] $1\n"
}

function printFail () {
  printf "\r\033[2K  [ \033[0;31mFAIL\033[0m ] $1\n"
}

function installFonts () {
  printInfo "Installing Fonts..."
  find $PWD/fonts -mindepth 1 -name \*.ttf -exec cp {} $HOME/Library/Fonts \;
  printSuccess "Installed Fonts"
}

function installHomebrew () {
  if [[ ! $(which brew) ]]; then
    printInfo "Installing Homebrew..."

    # Install the correct homebrew for each OS type
    if [[ "$(uname -s)" == "Darwin" ]]; then
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
    fi

    printSuccess "Installed Homebrew"
  else
    printInfo "Updating Homebrew..."
    brew update
    printSuccess "Updated Homebrew"
  fi
}

function installOhMyZsh () {
  # oh-my-zsh
  #
  # This executes the installation script for oh-my-zsh, a framework for managing zsh configuration.

  # Check for zsh
  if [[ ! $(grep /zsh$ /etc/shells | wc -l) ]]; then
    printInfo "Installing ZSH..."
    brew install zsh zsh-completions
    printSuccess "Installed ZSH"
  fi

  # Check for oh-my-zsh
  if [[ ! -n "$ZSH" ]] && [[ ! -d "$ZSH" ]]; then
    printInfo "Installing oh-my-zsh..."
    curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash
    printSuccess "Installed oh-my-zsh"
  fi

  printInfo "Changing Shell to ZSH..."
  chsh -s `which zsh`
  printSuccess "Changed Shell to ZSH"
}

function installSpaceshipTheme () {
  local themesDirectory=$HOME/.oh-my-zsh/themes

  if [[ -d $themesDirectory ]]; then
    if [[ -d $themesDirectory/spaceship-prompt ]]; then
      rm -rf $themesDirectory/spaceship-prompt
    fi

    printInfo "Installing Spaceship Theme..."
    git clone https://github.com/denysdovhan/spaceship-prompt.git $themesDirectory/spaceship-prompt
    ln -sf $themesDirectory/spaceship-prompt/spaceship.zsh-theme $themesDirectory/spaceship.zsh-theme
    printSuccess "Installed Spaceship Theme"
  else
    printFail "oh-my-zsh Not Installed"
  fi
}

function linkPath () {
  echo "$HOME/$1"
}

function installVundlePlugins () {
  local bundleDir=$HOME/.vim/bundle

  if [[ ! -d $bundleDir ]]; then
    printInfo "Installing Vundle..."
    git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
    printSuccess "Installed Vundle"
  fi

  vim +PluginInstall +qall
}

# Links the passed filename to its new location.
function link () {
  local filepath=$1
  local filename=$(basename $1)

  if [[ ! -e $filepath ]]; then
    printFail "$filepath Not Found"
    return
  fi

  if [[ -d $filepath ]]; then
    printInfo "Directory Skipped"
    return
  fi

  local path=$(linkPath $filepath)

  if [[ ! -f $path ]]; then
    printInfo "Copying $filepath to $path..."
    rsync -R $filepath $HOME/
    printSuccess "Copied: $filepath to $path"
  fi

  if [[ -L $path ]]; then
    printInfo "Already Linked: $path"
  elif [[ -f $path ]] && [[ ! -L $path ]]; then
    printInfo "Linking $filepath to $path..."
    ln -sf $PWD/$filepath $path
    printSuccess "Linked: $filepath to $path"
  fi
}

# Loops through and link all files without links.
function installLinks () {
  printInfo "Linking dotfiles..."

  find . -type d \( $(for DIR in ${EXCLUDED_SYMLINK_DIRS[@]}; do printf " -path */$DIR -o "; done) -false \) -prune -a -o -type f \( $(for FILE in ${EXCLUDED_SYMLINK_FILES[@]}; do printf " ! -iname $FILE "; done) \) -prune | while read FILE_PATH; do
    link $FILE_PATH
  done

  printSuccess "Linked dotfiles"
}

# If the operating system name is "Darwin", install and setup homebrew.
if [ "$(uname -s)" == "Darwin" ]; then
  printInfo "Installing Dependencies..."

  installFonts
  installHomebrew
  installOhMyZsh

  if source ./install.sh | while read -r DATA; do printInfo "$DATA"; done; then
    printSuccess "Dependencies Installed"

    installSpaceshipTheme
    installLinks
    installVundlePlugins
  else
    printFail "Could Not Install Dependencies"
  fi
fi

exit 1