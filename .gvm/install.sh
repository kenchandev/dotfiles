#!/bin/sh
#
# Go Version Manager (gvm)
#
# This executes the installation script for gvm.

# Check for Go Version Manager
if test ! $(which gvm)
then
  echo "  Installing gvm..."

  curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer | bash

  source $HOME/.gvm/scripts/gvm
fi