#!/bin/sh

set -e

EXCLUDED_SYMLINK_DIRS=(\
  fonts \
  .nvm \
  .homebrew \
  .git \
  vscode \
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

# $ code --list-extensions
VSCODE_EXTS=(\
  dbaeumer.vscode-eslint \
  denoland.vscode-deno \
  dunstontc.viml \
  EditorConfig.EditorConfig \
  eg2.tslint \
  esbenp.prettier-vscode \
  GrapeCity.gc-excelviewer \
  jakeboone02.cypher-query-language \
  jamesbirtles.svelte-vscode \
  joelday.docthis \
  jpoissonnier.vscode-styled-components \
  matklad.rust-analyzer \
  mgmcdermott.vscode-language-babel \
  mikestead.dotenv \
  ms-vsliveshare.vsliveshare \
  orta.vscode-jest \
  prisma.vscode-graphql \
  robertohuertasm.vscode-icons \
  robinbentley.sass-indented \
  serayuzgur.crates \
  tamasfe.even-better-toml \
  vadimcn.vscode-lldb \
  zhuangtongfa.Material-theme \
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

function installVirtualEnv () {
  printInfo "Installing virtualenv..."
  pip install virtualenv
  pip install virtualenvwrapper
  printSuccess "Installed virtualenv"
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

function setupVsCode () {
  local vsCodeDir="$HOME/Library/Application Support/Code/User"

  if [[ ! $(which code) ]]; then
    printFail "VSCode CLI Not Installed"
    printFail "Please Install Before Installing Extensions"
    return
  fi

  printInfo "Installing VSCode Extensions..."

  for EXT in ${VSCODE_EXTS[@]}; do
    code --install-extension $EXT
  done

  printSuccess "VSCode Extensions Installed"

  printInfo "Linking VSCode Configurations..."

  pushd "vscode"

  find . | while read FILE_PATH; do
    link "$vsCodeDir" "$FILE_PATH"
  done

  popd

  printSuccess "Linked VSCode Configurations"
}

# Links the passed filename to its new location.
function link () {
  local filepath=$2
  local filename=$(basename $2)

  if [[ ! -e $filepath ]]; then
    printFail "$filepath Not Found"
    return
  fi

  if [[ -d $filepath ]]; then
    printInfo "Directory Skipped"
    return
  fi

  local path=$1/$2

  if [[ ! -f $path ]]; then
    printInfo "Copying $filepath to $path..."
    rsync -R "$filepath" "$1/"
    printSuccess "Copied: $filepath to $path"
  fi

  if [[ -L $path ]]; then
    printInfo "Already Linked: $path"
  elif [[ -f $path ]] && [[ ! -L $path ]]; then
    printInfo "Linking $filepath to $path..."
    ln -sf "$PWD/$filepath" "$path"
    printSuccess "Linked: $filepath to $path"
  fi
}

function installGitLfs () {
  if [[ ! $(which git) ]]; then
    printFail "Git Not Installed"
    printFail "Please Install Before Installing Git LFS"
    return
  fi

  printInfo "Installing Git LFS..."

  git lfs install

  printSuccess "Git LFS Installed"
}

# Loops through and link all files without links.
function installLinks () {
  printInfo "Linking dotfiles..."

  find . -type d \( $(for DIR in ${EXCLUDED_SYMLINK_DIRS[@]}; do printf " -path */$DIR -o "; done) -false \) -prune -a -o -type f \( $(for FILE in ${EXCLUDED_SYMLINK_FILES[@]}; do printf " ! -iname $FILE "; done) \) -prune | while read FILE_PATH; do
    link "$HOME" "$FILE_PATH"
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

    installGitLfs
    installSpaceshipTheme
    installLinks
    installVundlePlugins
    installVirtualEnv
    setupVsCode

    rustup-init -y
    source $HOME/.cargo/env
    rustup completions zsh cargo > ~/.zfunc/_cargo
    rustup completions zsh > ~/.zfunc/_rustup
    rustup install nightly # cargo-expand requires a nightly toolchain.
    exec zsh
    cargo install cargo-workspaces cargo-expand
  else
    printFail "Could Not Install Dependencies"
  fi
fi

exit 1