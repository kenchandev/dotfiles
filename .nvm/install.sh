#!/bin/sh
#
# Node Version Manager (nvm)
#
# This executes the installation script for nvm.
# https://github.com/creationix/nvm

# Check for Node Version Manager
if [[ ! $(which nvm) ]]; then
  echo "  Installing nvm..."

  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash

  NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm.
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion.
fi