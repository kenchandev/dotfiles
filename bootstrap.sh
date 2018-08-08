#!/bin/sh

EXCLUDED_SYMLINK_DIRS=(\
  fonts \
  .setup \
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

function dot_path () {
    echo "$HOME/.$1"
}

# Links the passed filename to its new location
function link () {
    local filename=$1
    if [[ ! -e $filename ]]; then
        echo "$filename doesn't exist"
        return
    fi

    local path=$(dot_path $filename)
    if [[ -f $path ]] && [[ ! -L $path ]]; then
        local localpath=$(local_path $filename)
        mv $path $localpath
        echo "Moved: $path to $localpath"
    fi

    if [[ -L $path ]]; then
        echo "Ok: $path"
    elif [[ ! -e $path ]]; then
        echo "Linking: $filename to $path"
        ln -s $PWD/$filename $path
    fi
}

# Loops through and link all files without links
function installLinks () {
  echo "Linking dotfiles into place:\n"

  find . -type d \( $(for DIR in ${EXCLUDED_SYMLINK_DIRS[@]}; do printf " -path */$DIR -o "; done) -false \) -prune -a -o -type f \( $(for FILE in ${EXCLUDED_SYMLINK_FILES[@]}; do printf " ! -iname $FILE "; done) \) -prune | while read FILE; do
    echo $FILE
  done

  for FILE in ${FILES[@]}
  do
    link $FILE
  done
}

# If the operating system name is "Darwin", install and setup homebrew.
if [ "$(uname -s)" == "Darwin" ]
then
  printInfo "Installing Dependencies"

  installHomebrew

  if source install | while read -r data; do info "$data"; done
  then
    printSuccess "Dependencies Installed"

    installLinks
  else
    printFail "Error Installing Dependencies"
  fi
fi