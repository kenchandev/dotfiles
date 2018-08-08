#!/bin/sh

# Run Homebrew through the Brewfile
echo "› brew bundle"
brew bundle

# Find the installers and run them iteratively.
find . -mindepth 2 -name install.sh | while read INSTALLER ; do printf "${INSTALLER}" ; done