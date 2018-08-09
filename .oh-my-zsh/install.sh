#!/bin/sh
#
# oh-my-zsh
#
# This executes the installation script for oh-my-zsh, a framework for managing zsh configuration.

# Check for zsh
if test ! $(grep /zsh$ /etc/shells | wc -l)
then
  # Check for oh-my-zsh
  if test ! $($ZSH)
  then
    echo "  Installing oh-my-zsh..."

    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  fi

  echo "Changing Shell to ZSH"
  chsh -s `which zsh`
fi