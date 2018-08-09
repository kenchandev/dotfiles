#!/bin/sh

EXCLUDED_SYMLINK_DIRS=(\
  fonts \
  .nvm \
  .homebrew \
  .git \
)

EXCLUDED_SYMLINK_FILES=(\
  .gitignore \
  .DS_Store \
  dotfiles-logo.svg \
  LICENSE.md \
  README.md \
  Brewfile \
  .editorconfig \
  bootstrap.sh \
  install.sh \
)

function printInfo () {
  printf "\r  [ \033[00;34m...\033[0m ] $1\n"
}

function printSuccess () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

function printFail () {
  printf "\r\033[2K  [ \033[0;31mFAIL\033[0m ] $1\n"
}

function installHomebrew () {
  if test ! $(which brew)
  then
    printInfo "Installing Homebrew"

    # Install the correct homebrew for each OS type
    if test "$(uname -s)" === "Darwin"
    then
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    elif test "$(expr substr $(uname -s) 1 5)" = "Linux"
    then
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
    fi
  else
    printInfo "Updating Homebrew"

    brew update
  fi
}

function installSoftware () {
  echo "> $PWD/install"
  $PWD/install
}

function linkPath () {
  echo "$HOME/$1"
}

# Links the passed filename to its new location.
function link () {
  local filepath=$1
  local filename=$(basename $1)

  if [[ ! -e $filepath ]]; then
    echo "$filepath doesn't exist..."
    return
  fi

  local path=$(linkPath $filepath)

  if [[ -f $path ]] && [[ ! -L $path ]]; then
    rsync -R $filepath $HOME/

    echo "Copied: $filepath to $path"
  fi

  if [[ -L $path ]]; then
    echo "Ok: $path"
  elif [[ ! -e $path ]]; then
    echo "Linking: $filename to $path"
    ln -s $filepath $path
  fi
}

# Loops through and link all files without links.
function installLinks () {
  echo "Linking dotfiles into place:\n"

  find . -type d \( $(for DIR in ${EXCLUDED_SYMLINK_DIRS[@]}; do printf " -path */$DIR -o "; done) -false \) -prune -a -o -type f \( $(for FILE in ${EXCLUDED_SYMLINK_FILES[@]}; do printf " ! -iname $FILE "; done) \) -prune | while read FILE_PATH; do
    rsync -R $FILE_PATH $HOME/

    link $FILE_PATH
  done
}

# If the operating system name is "Darwin", install and setup homebrew.
if [ "$(uname -s)" == "Darwin" ]
then
  printInfo "Installing Dependencies"

  installHomebrew

  if source install | while read -r DATA; do info "$DATA"; done
  then
    printSuccess "Dependencies Installed"

    installLinks
  else
    printFail "Error Installing Dependencies"
  fi
fi